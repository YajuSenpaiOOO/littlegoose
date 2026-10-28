extends "res://scripts/combat/tuantuan120.gd"
# All poses pass through the renderer so the soft-body shader samples the same art.
func rest119() -> void:
 mode119="resting";active_ai=false;hit_area.collision_layer=0;collision_layer=0
 hopping=false;parry_stun=0.;health_fill.hide()
 if is_instance_valid(cue): cue.hide()
 if is_instance_valid(small_cue): small_cue.hide()
func receive_hit(damage: float,direction: Vector3) -> void:
 if dead: return
 super.receive_hit(damage,direction)
 if dead: set_physics_process(true)
func play119() -> void:
 super.play119();attack_phase="approach";hopping=false;velocity=Vector3.ZERO
func _step_response121(delta: float) -> void:
 age+=delta;_step_soft_response(delta);_step_squeeze(delta)
 for key in ["hit_left","hit_rearm","landing_left","flash","health_time","juice_gate","parry_stun"]:
  set(key,maxf(0.,float(get(key))-delta))
func _physics_process(delta: float) -> void:
 if battle.combat_paused: return
 if dead:
  _step_response121(delta);defeat_age+=delta
  var progress := clampf(defeat_age/Profile.DEFEAT_TIME,0.,1.)
  var lift := defeat_start_lift*(1.-progress)+sin(progress*PI)*8./Profile.PPM
  velocity=Vector3(impulse.x,-.3 if is_on_floor() else velocity.y-20.*delta,impulse.y)
  impulse*=maxf(0.,1.-6.*delta);move_and_slide();_render_legacy(lift)
  if defeat_age>=.6:
   impulse=Vector2.ZERO;velocity=Vector3.ZERO;squeeze=0.;tuft=0.;visual.transparency=0.
   _render_legacy(0.);set_physics_process(false)
  return
 if mode119=="ambient":
  if position.distance_squared_to(battle.hero.position)>625.: return
  _step_response121(delta);idle119+=delta;_render_legacy(absf(sin(idle119*1.7+role110))*.035);health_fill.hide();return
 if mode119=="entering":
  _step_response121(delta);entry_age119+=delta
  var at := Vector2(position.x,position.z)
  while not entry119.is_empty() and at.distance_to(entry119[0])<.4: entry119.remove_at(0)
  if entry119.is_empty() or entry_age119>7.: play119();_render_legacy(0.);return
  var phase := fmod(entry_age119,.56)
  hopping=phase<.4;hop_clock=phase;attack_phase="approach"
  var progress := clampf(phase/.4,0.,1.)
  var direction := (entry119[0]-at).normalized()
  var motion := direction*3.5*sin(progress*PI) if hopping else Vector2.ZERO
  velocity=Vector3(motion.x+impulse.x,-.3 if is_on_floor() else velocity.y-20.*delta,motion.y+impulse.y)
  impulse*=maxf(0.,1.-Profile.KNOCK_DECAY*delta);move_and_slide()
  landing_left=.07 if not hopping else 0.
  _render_legacy(sin(progress*PI)*.24 if hopping else 0.);return
 super._physics_process(delta)
