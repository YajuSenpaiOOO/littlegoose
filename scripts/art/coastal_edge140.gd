extends Node3D
## A visual coastline for the unused northern buffer, outside the fenced hill.
## Original terrain data, collision, floor tiles and all material uniforms stay
## intact. A clipped visual copy shares materials; a real rock skirt closes it.
var world: Node3D
var clipped_triangles140 := 0
var changed_max_z140 := -INF
var changed_min_radius140 := INF
var visual140: MeshInstance3D
var rock_visual140: MeshInstance3D
const COAST140 := [Vector2(-35.,-20.),Vector2(-34.1,-24.),Vector2(-32.,-27.),Vector2(-29.,-30.5),Vector2(-26.,-32.5),Vector2(-23.5,-34.2),Vector2(-21.5,-35.),Vector2(-20.,-36.5),Vector2(-18.8,-39.),Vector2(-19.2,-42.),Vector2(-17.6,-46.),Vector2(-18.1,-50.),Vector2(-16.5,-57.)]
func coastline140() -> Array: return COAST140
func score140(at: Vector3) -> float:
 var g: Vector2=world.meadow.landmarks.grove
 var p := Vector2(at.x,at.z)-g
 if p.y>=coastline140()[0].y: return p.y-coastline140()[0].y+.001
 for i in coastline140().size()-1:
  var a: Vector2=coastline140()[i];var b: Vector2=coastline140()[i+1]
  if p.y>=b.y:
   var t := (p.y-a.y)/(b.y-a.y)
   return p.x-lerpf(a.x,b.x,t)
 return p.x-coastline140()[-1].x
func clipped140(source: ArrayMesh) -> ArrayMesh:
 var result := ArrayMesh.new()
 for surface in source.get_surface_count():
  var data: Array=source.surface_get_arrays(surface)
  var vertices: PackedVector3Array=data[Mesh.ARRAY_VERTEX]
  var normals: PackedVector3Array=data[Mesh.ARRAY_NORMAL]
  var uvs := PackedVector2Array()
  if data[Mesh.ARRAY_TEX_UV]!=null: uvs=data[Mesh.ARRAY_TEX_UV]
  var colors := PackedColorArray()
  if data[Mesh.ARRAY_COLOR]!=null: colors=data[Mesh.ARRAY_COLOR]
  var indices := PackedInt32Array()
  if data[Mesh.ARRAY_INDEX]!=null: indices=data[Mesh.ARRAY_INDEX]
  var scores := PackedFloat32Array();var touched := false
  for at in vertices:
   var score := score140(at);scores.append(score);touched=touched or score<0.
  if not touched:
   result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,data);result.surface_set_material(surface,source.surface_get_material(surface));continue
  var keep := PackedInt32Array()
  var count := indices.size() if not indices.is_empty() else vertices.size()
  for i in range(0,count,3):
   var tri: Array[int]=[i,i+1,i+2]
   if not indices.is_empty(): tri=[indices[i],indices[i+1],indices[i+2]]
   if scores[tri[0]]>=0. and scores[tri[1]]>=0. and scores[tri[2]]>=0.:
    keep.append_array(PackedInt32Array(tri));continue
   clipped_triangles140+=1
   for index in tri:
    var local := Vector2(vertices[index].x,vertices[index].z)-Vector2(world.meadow.landmarks.grove)
    changed_max_z140=maxf(changed_max_z140,local.y)
    changed_min_radius140=minf(changed_min_radius140,preload("res://scripts/world/park_layout140.gd").radius140(local))
   var ring: Array[int]=[]
   for j in 3:
    var a: int=tri[j];var b: int=tri[(j+1)%3]
    if scores[a]>=0.: ring.append(a)
    if (scores[a]>=0.)!=(scores[b]>=0.):
     var t: float=scores[a]/(scores[a]-scores[b]);var next := vertices.size()
     vertices.append(vertices[a].lerp(vertices[b],t));normals.append(normals[a].lerp(normals[b],t).normalized())
     if not uvs.is_empty(): uvs.append(uvs[a].lerp(uvs[b],t))
     if not colors.is_empty(): colors.append(colors[a].lerp(colors[b],t))
     scores.append(0.);ring.append(next)
   for j in range(1,ring.size()-1): keep.append_array(PackedInt32Array([ring[0],ring[j],ring[j+1]]))
  if keep.is_empty(): keep=PackedInt32Array([0,0,0])
  data[Mesh.ARRAY_VERTEX]=vertices;data[Mesh.ARRAY_NORMAL]=normals;data[Mesh.ARRAY_INDEX]=keep;data[Mesh.ARRAY_TANGENT]=null
  if not uvs.is_empty(): data[Mesh.ARRAY_TEX_UV]=uvs
  if not colors.is_empty(): data[Mesh.ARRAY_COLOR]=colors
  result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,data);result.surface_set_material(surface,source.surface_get_material(surface))
 return result
func skirt140(st: SurfaceTool,a: Vector2,b: Vector2) -> void:
 var g: Vector2=world.meadow.landmarks.grove
 a+=g;b+=g
 var a_top := Vector3(a.x,world.floor_height(a)-.015,a.y)
 var b_top := Vector3(b.x,world.floor_height(b)-.015,b.y)
 var a_bottom := Vector3(a.x,-8.,a.y);var b_bottom := Vector3(b.x,-8.,b.y)
 var normal := Vector3((b-a).y,0.,-(b-a).x).normalized()
 # Both windings keep the closed rock face visible from the sea and land.
 for p in [a_top,b_top,b_bottom,a_top,b_bottom,a_bottom,a_top,b_bottom,b_top,a_top,a_bottom,b_bottom]:
  st.set_normal(normal);st.set_color(Color(1,0,0,1));st.set_uv(Vector2(p.x,p.y)/6.);st.add_vertex(p)
func material_signature140(material: Material,arrays: Array) -> String:
 # Rendering equivalence: same shader code, same uniforms, same vertex
 # layout. Per-chunk road segments make neighbours differ; empty-route
 # chunks collapse together losslessly.
 var parts := PackedStringArray([str(material.render_priority),str(arrays[Mesh.ARRAY_TEX_UV]!=null),str(arrays[Mesh.ARRAY_COLOR]!=null)])
 if material is ShaderMaterial:
  var shader: Shader=material.shader
  parts.append(str(hash(shader.code) if shader!=null else -1))
  if shader!=null:
   for uniform in shader.get_shader_uniform_list():
    var value=material.get_shader_parameter(uniform.name)
    parts.append(str(value.get_instance_id() if typeof(value)==TYPE_OBJECT and value!=null else value))
 else: parts.append(str(material.get_instance_id()))
 return "/".join(parts)

func sequential_indices140(arrays: Array) -> PackedInt32Array:
 var indices: PackedInt32Array=arrays[Mesh.ARRAY_INDEX]
 if not indices.is_empty(): return indices
 var count: int=arrays[Mesh.ARRAY_VERTEX].size()
 var sequential := PackedInt32Array();sequential.resize(count)
 for i in count: sequential[i]=i
 return sequential

func merge_surfaces140(mesh: ArrayMesh) -> ArrayMesh:
 # The compatibility renderer pays one draw call per surface per pass, so
 # the 154 painted chunks cost ~460 draws with shadow splits even where
 # their materials are identical. Group by rendering signature and keep the
 # first material instance of each group: it already lives in the world's
 # ground_materials list, so runtime footprint uploads keep reaching it.
 var groups := {};var order: Array=[]
 for surface in mesh.get_surface_count():
  var material: Material=mesh.surface_get_material(surface)
  var arrays: Array=mesh.surface_get_arrays(surface)
  var signature := material_signature140(material,arrays)
  if not groups.has(signature):
   groups[signature]={"material":material,"surfaces":[surface]};order.append(signature)
  else: groups[signature].surfaces.append(surface)
 var merged := ArrayMesh.new()
 for signature in order:
  var group: Dictionary=groups[signature]
  var arrays: Array=mesh.surface_get_arrays(group.surfaces[0])
  if group.surfaces.size()==1:
   merged.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
   merged.surface_set_material(merged.get_surface_count()-1,group.material)
   continue
  var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX].duplicate()
  var normals: PackedVector3Array=arrays[Mesh.ARRAY_NORMAL].duplicate()
  var uvs: PackedVector2Array=arrays[Mesh.ARRAY_TEX_UV].duplicate() if arrays[Mesh.ARRAY_TEX_UV]!=null else PackedVector2Array()
  var colors: PackedColorArray=arrays[Mesh.ARRAY_COLOR].duplicate() if arrays[Mesh.ARRAY_COLOR]!=null else PackedColorArray()
  var indices: PackedInt32Array=sequential_indices140(arrays)
  for which in group.surfaces.slice(1):
   var more: Array=mesh.surface_get_arrays(which)
   var base: int=vertices.size()
   vertices.append_array(more[Mesh.ARRAY_VERTEX]);normals.append_array(more[Mesh.ARRAY_NORMAL])
   if not uvs.is_empty(): uvs.append_array(more[Mesh.ARRAY_TEX_UV])
   if not colors.is_empty(): colors.append_array(more[Mesh.ARRAY_COLOR])
   var offsets: PackedInt32Array=sequential_indices140(more)
   for index in offsets: indices.append(base+index)
  var combined := [];combined.resize(Mesh.ARRAY_MAX)
  combined[Mesh.ARRAY_VERTEX]=vertices;combined[Mesh.ARRAY_NORMAL]=normals;combined[Mesh.ARRAY_INDEX]=indices
  if not uvs.is_empty(): combined[Mesh.ARRAY_TEX_UV]=uvs
  if not colors.is_empty(): combined[Mesh.ARRAY_COLOR]=colors
  merged.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,combined)
  merged.surface_set_material(merged.get_surface_count()-1,group.material)
 print("COAST140_MERGE surfaces=",mesh.get_surface_count(),"->",merged.get_surface_count())
 return merged

func _ready() -> void:
 name="ClosedNorthernCoast140"
 visual140=MeshInstance3D.new();visual140.name="NorthernBufferTrim140"
 visual140.mesh=merge_surfaces140(clipped140(world.ground.mesh));visual140.layers=world.ground.layers
 world.ground.add_child(visual140);world.ground.layers=0
 # Grass caps and stone faces share the same contour. Trimming just the cap
 # would leave the previous rock ledge and its grass tufts hanging in the sea.
 var original_rock: MeshInstance3D=world.rocks91.rock91
 rock_visual140=MeshInstance3D.new();rock_visual140.name="NorthernRockTrim140"
 rock_visual140.mesh=clipped140(original_rock.mesh);rock_visual140.material_override=original_rock.material_override
 rock_visual140.layers=original_rock.layers;original_rock.add_child(rock_visual140);original_rock.layers=0
 var rim: MultiMeshInstance3D=world.rocks91.edge_grass92
 for i in rim.multimesh.instance_count:
  var pose := rim.multimesh.get_instance_transform(i)
  if score140(rim.to_global(pose.origin))<.02:
   pose.basis=Basis(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO);rim.multimesh.set_instance_transform(i,pose)
 var g: Vector2=world.meadow.landmarks.grove
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in coastline140().size()-1:
  var a: Vector2=coastline140()[i];var b: Vector2=coastline140()[i+1]
  for j in 12: skirt140(st,a.lerp(b,float(j)/12.),a.lerp(b,float(j+1)/12.))
 var stone := MeshInstance3D.new();stone.name="ClosedNorthernCliff140";stone.mesh=st.commit()
 stone.material_override=world.rocks91.rock91.material_override;add_child(stone)
 print("COAST140_TRIM triangles=",clipped_triangles140," maximum_local_z=",changed_max_z140," minimum_meadow_radius=",changed_min_radius140)
