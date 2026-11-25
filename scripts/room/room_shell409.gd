extends "res://scripts/room/room_shell403.gd"
func relocate409(row: Dictionary) -> void:
 var old: Vector3=row.root.position
 var gain: float=.87 if absf(old.x)>5. else .9
 row.root.position=Vector3(old.x*gain,old.y,old.z*.9)
 row.at=Vector2(row.root.position.x,row.root.position.z);row.approach*=.9
func build_furniture() -> void:
 super.build_furniture()
 var furniture: Array=[]
 for row in footprints:furniture.append(row.root);relocate409(row)
 for node in get_children():
  if not node is Node3D or node in furniture:continue
  if node==foreground402:
   for prop in node.get_children():
    if prop is Node3D:prop.position.x*=.9;prop.position.z*=.9
   continue
  node.position.x*=.9;node.position.z*=.9
  if node is StaticBody3D:
   var collision: CollisionShape3D=node.get_child(0)
   collision.shape=collision.shape.duplicate();collision.shape.size.x*=.9;collision.shape.size.z*=.9
  else:
   node.scale.x*=.9;node.scale.z*=.9
   # Flat illustrations keep their source aspect while architectural meshes
   # compress only in plan. Do not squeeze the curtains or window landscape.
   if node is Sprite3D or (node is MeshInstance3D and node.mesh is QuadMesh):node.scale.y*=.9
 for row in furniture394:row.sprite.material_override.set_shader_parameter("foot394",row.sprite.global_position)
func build_hourglass() -> void:
 super.build_hourglass();relocate409(item356("hourglass"))
