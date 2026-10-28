extends "res://scripts/art/grounded_prop_shadow63.gd"
# Projection uses the visible receiver (including cloth) instead of physics-only floor.
func _height145(at: Vector2) -> float:
 return world.painted_shadow_height145(at)
func update_shadow() -> void:
 if not is_instance_valid(visual): return
 var strength: float=world.sun.shadow_opacity
 visible=enabled and visual.is_visible_in_tree() and world.contact_enabled and strength>.001
 if not visible: return
 ink.set_shader_parameter("opacity",.27*strength)
 var ray: Vector3=-world.sun.global_basis.z.normalized()
 if ray.y>-.025: hide(); return
 var key := [visual.texture,visual.offset,visual.pixel_size,visual.global_transform,world.sun.global_basis]
 if key==cache_key: return
 cache_key=key
 ink.set_shader_parameter("silhouette",visual.texture)
 var size: Vector2=visual.texture.get_size()
 var points: Array[Vector3]=[]
 var subdivisions := 8
 var rows: Array[float]=[]
 for y in subdivisions+1: rows.append(float(y)/subdivisions)
 var foot_v := (size.y*.5+visual.offset.y)/size.y
 rows.append(clampf(foot_v,0.,1.))
 rows.append(clampf(foot_v+visual.position.y/visual.pixel_size/size.y,0.,1.))
 rows.sort()
 for v in rows:
  for x in subdivisions+1:
   var uv := Vector2(float(x)/subdivisions,v)
   var pixel := uv*size
   var local := Vector3((pixel.x-size.x*.5+visual.offset.x)*visual.pixel_size,(size.y*.5-pixel.y+visual.offset.y)*visual.pixel_size,0)
   var point: Vector3=visual.to_global(local)
   # Match the visible root strip: its below-foot paint folds onto the floor.
   var root_y: float=visual.get_parent().global_position.y
   if point.y<root_y:
    point.z+=(root_y-point.y)/tan(deg_to_rad(25.))
    point.y=_height145(Vector2(point.x,point.z))
   var base: float=_height145(Vector2(point.x,visual.global_position.z))
   var projected := point+ray*((base-point.y)/ray.y)
   for iteration in 2:
    var floor_y: float=_height145(Vector2(projected.x,projected.z))
    projected=point+ray*((floor_y-point.y)/ray.y)
   projected.y=_height145(Vector2(projected.x,projected.z))+.024
   points.append(to_local(projected))
 var st := SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for y in rows.size()-1:
  for x in subdivisions:
   for corner in [Vector2i(0,0),Vector2i(1,0),Vector2i(1,1),Vector2i(0,0),Vector2i(1,1),Vector2i(0,1)]:
    var index: Vector2i=Vector2i(x,y)+corner
    st.set_uv(Vector2(float(index.x)/subdivisions,rows[index.y]))
    st.add_vertex(points[index.y*(subdivisions+1)+index.x])
 mesh=st.commit()
 rebuild_count+=1
