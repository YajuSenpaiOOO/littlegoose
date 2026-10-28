extends "res://scripts/art/woodland_details102.gd"
var reactive_reference106 := false # Diagnostic reference only; disabled in gameplay.
func _audio_script101() -> Script: return preload("res://scripts/art/woodland_audio106.gd")
func _leaf(at: Vector2,width: float) -> void:
 if leaf_textures102.is_empty():
  _split_leaves102()
  for texture in leaf_textures102:
   var poses: Array[Transform3D]=[]
   var mat := ShaderMaterial.new();mat.shader=preload("res://scripts/art/woodland_floor101.gdshader");mat.set_shader_parameter("paint",texture);world.porch49.shade_material(mat)
   leaf_batches102.append(_batch(_leaf_mesh102(texture),poses,mat,false))
 for i in 12:
  var offset := Vector2(rng.randf_range(-.5,.5),rng.randf_range(-.4,.4))*width
  leaf_states102.append({"at":at+offset,"velocity":Vector2.ZERO,"lift":0.,"bed":float(i)*.0015,"vertical":0.,"angle":rng.randf()*TAU,"size":rng.randf_range(.23,.34),"variant":leaf_states102.size()%6,"index":leaf_states102.size()/6,"cool":0.,"moving":false})
func _physics_process(delta: float) -> void:
 if reactive_reference106: super._physics_process(delta);return
 scope_wait102-=delta
 if scope_wait102<=0.:
  scope_wait102=.25
  active102=world.hero.position.distance_to(point(Vector2(1,2)))<24. and world.effect_scope95.near_view95(point(Vector2(1,2)),14.)
 if not active102: return
 _step_cones102(delta,Vector2(world.hero.position.x,world.hero.position.z),Vector2(world.hero.velocity.x,world.hero.velocity.z))
