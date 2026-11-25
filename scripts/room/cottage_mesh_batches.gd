extends RefCounted
## Collapse immutable house meshes while leaving collision and cut controls intact.

func merge(nodes: Array, entries: Array, excluded: Dictionary, pivot: Node3D) -> int:
 var groups: Dictionary={}
 for item in nodes:
  var node: MeshInstance3D=item
  if excluded.has(node) or pivot.is_ancestor_of(node) or not node.is_visible_in_tree():continue
  var material:=node.material_override
  var material_key: Variant=ink_key(material)
  if material_key==null:continue
  collect(groups,node,{"node":node},material_key)
 for entry in entries:
  var node=entry.node
  if not node is MeshInstance3D or pivot.is_ancestor_of(node):continue
  var material_key: Variant=ink_key(entry.original)
  if material_key==null:continue
  collect(groups,node,entry,material_key)
 var saved:=0
 for group in groups.values():
  if group.size()<2:continue
  var first: MeshInstance3D=group[0].node
  var parent:=first.get_parent() as Node3D
  var inverse:=parent.global_transform.affine_inverse()
  var surface:=SurfaceTool.new()
  surface.begin(Mesh.PRIMITIVE_TRIANGLES)
  for row in group:
   var piece: MeshInstance3D=row.node
   surface.append_from(piece.mesh,0,inverse*piece.global_transform)
  var batch:=MeshInstance3D.new()
  batch.name="StaticCottageBatch"
  batch.mesh=surface.commit()
  batch.material_override=first.material_override
  batch.cast_shadow=first.cast_shadow
  batch.layers=first.layers
  parent.add_child(batch)
  for row in group:
   row.node.hide()
   if row.has("original"):
    if row==group[0]:
     row.node=batch
    else:
     entries.erase(row)
  saved+=group.size()-1
 return saved

func ink_key(material: Material) -> Variant:
 if material is StandardMaterial3D:return material
 if material is ShaderMaterial and material.shader==preload("res://scripts/room/plaster429.gdshader"):
  return [material.shader,material.get_shader_parameter("paint")]
 return null

func collect(groups: Dictionary,node: MeshInstance3D,row: Dictionary,material_key: Variant) -> void:
 if node.mesh==null or node.mesh.get_surface_count()!=1:return
 # Collider children are independent of rendering. Keep visual attachments
 # and lights on their original node and out of static batches.
 for child in node.get_children():
  if not child is CollisionObject3D:return
 var layout:=0
 var arrays:=node.mesh.surface_get_arrays(0)
 for index in arrays.size():
  if arrays[index]!=null:layout|=1<<index
 var key:=[node.get_parent(),material_key,node.cast_shadow,node.layers,layout,row.has("original")]
 if not groups.has(key):groups[key]=[]
 groups[key].append(row)
