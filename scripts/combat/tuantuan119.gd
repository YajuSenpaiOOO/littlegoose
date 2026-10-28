extends "res://scripts/combat/tuantuan110.gd"
var mode119 := "ambient"
var idle119 := 0.
var entry119 := PackedVector2Array()
var entry_age119 := 0.
func _ready() -> void:
 super._ready();active_ai=false;hit_area.collision_layer=0
func join119(destination: Vector2) -> void:
 mode119="entering";entry_age119=0.;entry119=battle.navigation.path(Vector2(position.x,position.z),destination);hit_area.collision_layer=8;rest=.8;attack_wait110=1.
func play119() -> void:
 mode119="playing";active_ai=true;hit_area.collision_layer=8;phase_clock=-.65
func rest119() -> void:
 mode119="resting";active_ai=false;hit_area.collision_layer=0;collision_layer=0;velocity=Vector3.ZERO;visual.transparency=0.;visual.scale=Vector3.ONE
 _pose("landing",0.);health_fill.hide()
func receive_hit(damage: float,direction: Vector3) -> void:
 super.receive_hit(damage,direction)
 if dead: rest119()
func _physics_process(delta: float) -> void:
 if battle.combat_paused: return
 if dead:
  rest119();return
 if mode119=="ambient":
  if position.distance_squared_to(battle.hero.position)>625.: return
  idle119+=delta;_pose("idle",absf(sin(idle119*1.7+role110))*.035);health_fill.hide();return
 if mode119=="entering":
  entry_age119+=delta;var at := Vector2(position.x,position.z)
  while not entry119.is_empty() and at.distance_to(entry119[0])<.4: entry119.remove_at(0)
  if entry119.is_empty() or entry_age119>7.: play119();return
  var direction := (entry119[0]-at).normalized();velocity.x=direction.x*1.8;velocity.z=direction.y*1.8;velocity.y-=12.*delta;move_and_slide()
  _pose("airborne",absf(sin(entry_age119*7.))*.07);return
 super._physics_process(delta)
