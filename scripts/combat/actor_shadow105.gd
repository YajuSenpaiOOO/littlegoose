extends "res://scripts/combat/actor_shadow25.gd"
# Keep the nine-point grounded silhouette, but reuse its vertex buffer and update
# once per rendered frame instead of rebuilding a SurfaceTool on every physics tick.
var dynamic_mesh105: ArrayMesh
var vertex_bytes105 := PackedFloat32Array()
var geometry_key105: Array=[]
var uploads105 := 0
func _ready() -> void:
 super._ready();process_priority=100
 physics_interpolation_mode=Node.PHYSICS_INTERPOLATION_MODE_OFF
 var arrays := [];arrays.resize(Mesh.ARRAY_MAX)
 var vertices := PackedVector3Array();vertices.resize(24)
 var uvs := PackedVector2Array()
 for y in 2:
  for x in 2:
   for offset in [Vector2i(0,0),Vector2i(1,0),Vector2i(1,1),Vector2i(0,0),Vector2i(1,1),Vector2i(0,1)]: uvs.append(Vector2(Vector2i(x,y)+offset)*.5)
 arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_TEX_UV]=uvs
 dynamic_mesh105=ArrayMesh.new();dynamic_mesh105.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays,[],{},Mesh.ARRAY_FLAG_USE_DYNAMIC_UPDATE)
 vertex_bytes105.resize(72);mesh=dynamic_mesh105
func _physics_process(delta: float) -> void:
 if not battle.combat_budget105: super._physics_process(delta)
func _process(_delta: float) -> void:
 if not battle.combat_budget105: geometry_key105.clear();return
 visible=enabled and is_instance_valid(visual) and visual.is_visible_in_tree() and battle.contact_enabled
 if not visible or visual.texture==null: return
 var source: Texture2D=visual.texture
 if source!=last_texture:
  last_texture=source
  var region := Vector4(0,0,1,1);var texture: Texture2D=source
  if source is AtlasTexture:
   texture=source.atlas;var dimensions := texture.get_size()
   region=Vector4(source.region.position.x/dimensions.x,source.region.position.y/dimensions.y,source.region.size.x/dimensions.x,source.region.size.y/dimensions.y)
  ink.set_shader_parameter("silhouette",texture);ink.set_shader_parameter("region",region)
 ink.set_shader_parameter("flipped",visual.flip_h);ink.set_shader_parameter("opacity",.27*visual.modulate.a*opacity_scale)
 var pose := visual.get_global_transform_interpolated()
 var key := [pose,source.get_instance_id(),visual.offset,visual.pixel_size,light_direction,global_transform]
 if key==geometry_key105 and mesh==dynamic_mesh105: return
 geometry_key105=key;mesh=dynamic_mesh105
 var points := PackedVector3Array();var dimensions := source.get_size()
 var origin: Vector3=get_parent().get_global_transform_interpolated().origin
 var base: float=battle.floor_height(Vector2(origin.x,origin.z))
 for y in 3:
  for x in 3:
   var uv := Vector2(x,y)*.5;var pixel := uv*dimensions
   var local := Vector3((pixel.x-dimensions.x*.5+visual.offset.x)*visual.pixel_size,(dimensions.y*.5-pixel.y+visual.offset.y)*visual.pixel_size,0)
   var point := pose*local;var projected := point+light_direction*((base-point.y)/light_direction.y)
   for i in 2:
    var height: float=battle.floor_height(Vector2(projected.x,projected.z));projected=point+light_direction*((height-point.y)/light_direction.y)
   projected.y=battle.floor_height(Vector2(projected.x,projected.z))+.022;points.append(to_local(projected))
 var index := 0
 for y in 2:
  for x in 2:
   for offset in [Vector2i(0,0),Vector2i(1,0),Vector2i(1,1),Vector2i(0,0),Vector2i(1,1),Vector2i(0,1)]:
    var cell: Vector2i=Vector2i(x,y)+offset;var point: Vector3=points[cell.y*3+cell.x]
    vertex_bytes105[index]=point.x;vertex_bytes105[index+1]=point.y;vertex_bytes105[index+2]=point.z;index+=3
 dynamic_mesh105.surface_update_vertex_region(0,0,vertex_bytes105.to_byte_array());uploads105+=1
 var bounds := AABB(points[0],Vector3.ZERO)
 for point in points: bounds=bounds.expand(point)
 custom_aabb=bounds.grow(.02)
