extends "res://scripts/art/forest_lighting194.gd"
var upload_state201 := Vector3.INF
var upload_enabled201 := false
func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(world.forest_mood188): return
 # New accent lamps share the existing real-light/grade pipeline. Upload
 # the nearest volumes when fixtures exceed the postprocess array capacity.
 # The array only changes when the hero moves or lamps toggle; skip the
 # re-sort and upload while idle.
 var hero_at: Vector3=world.hero.global_position
 if enabled==upload_enabled201 and hero_at.distance_squared_to(upload_state201)<=.0625: return
 upload_enabled201=enabled;upload_state201=hero_at
 var ordered: Array=lamps.duplicate()
 ordered.sort_custom(func(a,b): return a.global_position.distance_squared_to(hero_at)<b.global_position.distance_squared_to(hero_at))
 var upload := PackedVector4Array()
 if enabled:
  for i in mini(20,ordered.size()):
   var light: OmniLight3D=ordered[i];var p := light.global_position
   upload.append(Vector4(p.x,p.y,p.z,light.omni_range))
 var focus: ShaderMaterial=world.atmosphere41.focus_material
 focus.set_shader_parameter("light_count191",upload.size());upload.resize(20);focus.set_shader_parameter("lights191",upload)
