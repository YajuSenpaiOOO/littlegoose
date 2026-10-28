extends "res://scripts/art/forest_lighting194.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(world.forest_mood188): return
 # New accent lamps share the existing real-light/grade pipeline. Upload
 # the nearest volumes when fixtures exceed the postprocess array capacity.
 var ordered: Array=lamps.duplicate()
 ordered.sort_custom(func(a,b): return a.global_position.distance_squared_to(world.hero.global_position)<b.global_position.distance_squared_to(world.hero.global_position))
 var upload := PackedVector4Array()
 if enabled:
  for i in mini(20,ordered.size()):
   var light: OmniLight3D=ordered[i];var p := light.global_position
   upload.append(Vector4(p.x,p.y,p.z,light.omni_range))
 var focus: ShaderMaterial=world.atmosphere41.focus_material
 focus.set_shader_parameter("light_count191",upload.size());upload.resize(20);focus.set_shader_parameter("lights191",upload)
