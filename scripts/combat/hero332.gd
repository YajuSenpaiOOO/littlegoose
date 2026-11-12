extends "res://scripts/combat/hero304.gd"

var pending_lift332 := 0.
var blast_air332 := false
var blast_tilt332 := 0.
var landing_left332 := 0.

func reset_actions() -> void:
 super.reset_actions()
 pending_lift332 = 0.
 blast_air332 = false
 blast_tilt332 = 0.
 landing_left332 = 0.

func request_dash(direction := Vector2.ZERO) -> bool:
 var accepted := super.request_dash(direction)
 if accepted:
  pending_lift332 = 0.
  blast_air332 = false
 return accepted

func _physics_process(delta: float) -> void:
 if battle.combat_paused:
  super._physics_process(delta)
  return
 landing_left332 = maxf(0.,landing_left332-delta)
 if pending_lift332>0.:
  # Break native floor contact before the ordinary controller applies gravity.
  # Only the initial vertical step is extra; horizontal movement stays native.
  var old := velocity
  velocity = Vector3(0.,pending_lift332,0.)
  pending_lift332 = 0.
  move_and_slide()
  velocity.x = old.x
  velocity.z = old.z
 super._physics_process(delta)
 if blast_air332 and is_on_floor():
  blast_air332 = false
  landing_left332 = .14
  battle.hero_landed332()

func render_pose() -> void:
 super.render_pose()
 if knocked_down or story_knocked or dash_left>0.: return
 if blast_air332:
  visual.rotation.z += blast_tilt332
  visual.scale *= Vector3(.96,1.04,1.)
 elif landing_left332>0.:
  var squash := sin(landing_left332/.14*PI)*.08
  visual.scale *= Vector3(1.+squash,1.-squash,1.)
