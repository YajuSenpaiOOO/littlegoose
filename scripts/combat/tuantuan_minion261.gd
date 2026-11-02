extends "res://scripts/combat/tuantuan_minion260.gd"
var entry_route261 := PackedVector2Array()
var entry_name261 := ""
var entry_length261 := 0.
var entry_step261 := 0.
var entry_stuck261 := 0.
var entry_last261 := Vector2.ZERO
var rustle261: Node3D
var blocked261 := 0.
var detour_left261 := 0.
var detour_sign261 := 1.
func _ready() -> void:
 super._ready();state260="rustle";clock260=0.;collision_mask=1|2;visual.hide()
 rustle261=preload("res://scripts/combat/arrival_rustle261.gd").new();rustle261.camera261=battle.camera;add_child(rustle261)
 entry_last261=Vector2(position.x,position.z);detour_sign261=1. if role110%2 else -1.
func rest_with_boss260() -> bool:return false
func _steer110(wish: Vector2) -> Vector2:
 var direction=super._steer110(wish)
 if detour_left261>0.:return (direction*.3+direction.orthogonal()*detour_sign261*.9).normalized()
 return direction
func _physics_process(delta: float) -> void:
 if battle.combat_paused:return
 if not battle.active114:return
 if state260=="rustle":
  clock260+=delta;visual.hide();health_fill.hide();cue.hide();small_cue.hide();shadow.hide()
  if is_instance_valid(projection260):projection260.hide()
  rustle261.sample261(clock260/.55)
  if clock260>=.55:
   rustle261.hide();state260="arrive";clock260=0.;visual.show()
   if is_instance_valid(projection260):projection260.show()
  return
 if state260=="arrive":
  clock260+=delta;_step_response121(delta)
  var at=Vector2(position.x,position.z)
  while not entry_route261.is_empty() and at.distance_to(entry_route261[0])<.28:entry_route261.remove_at(0)
  if entry_route261.is_empty():
   ground260();battle.entry_complete261(self);return
  var previous=fmod(entry_step261,.52)
  entry_step261+=delta
  var cycle=fmod(entry_step261,.52);hopping=cycle<.4;hop_clock=cycle
  if cycle<previous and is_instance_valid(battle.jelly_fx):battle.jelly_fx._play(battle.jelly_fx.landing_clip,position,-18.,1.1)
  var direction=(entry_route261[0]-at).normalized()
  var speed=3.5*sin(clampf(cycle/.4,0.,1.)*PI) if hopping else 0.
  var motion=direction*minf(speed,at.distance_to(entry_route261[0])/maxf(delta,.001))
  velocity=Vector3(motion.x,-.3 if is_on_floor() else velocity.y-20.*delta,motion.y);move_and_slide()
  _render_legacy(sin(clampf(cycle/.4,0.,1.)*PI)*.24 if hopping else 0.);shadow.hide();health_fill.hide()
  at=Vector2(position.x,position.z)
  if at.distance_to(entry_last261)>.15:entry_last261=at;entry_stuck261=0.
  else:entry_stuck261+=delta
  if clock260>6. or entry_stuck261>1.5:battle.cancel_entry261(self)
  return
 var before=Vector2(position.x,position.z)
 detour_left261=maxf(0.,detour_left261-delta)
 super._physics_process(delta)
 if not dead and state260=="ground" and attack_phase=="approach" and Vector2(position.x-battle.hero.position.x,position.z-battle.hero.position.z).length()>1.3:
  if hopping and before.distance_to(Vector2(position.x,position.z))<.015:blocked261+=delta
  elif before.distance_to(Vector2(position.x,position.z))>.04:blocked261=0.
  if blocked261>.45:
   detour_left261=.9;detour_sign261=-detour_sign261;blocked261=0.
