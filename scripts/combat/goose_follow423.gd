extends "res://scripts/combat/goose_follow376.gd"

var yielding_steps:=0
var yield_side:=0.
var yield_time:=0.

func _physics_process(delta: float) -> void:
 if not ready373 or host.sleeping362:
  super._physics_process(delta)
  return
 var movement:=Vector3(host.hero.velocity.x,0,host.hero.velocity.z)
 var direction:=movement.normalized()
 var gap: Vector3=global_position-host.hero.global_position
 gap.y=0.
 var ahead:=gap.dot(direction)
 var lateral:=direction.cross(Vector3.UP)
 var offset:=gap.dot(lateral)
 var contact:=movement.length_squared()>.10 and gap.length_squared()<.60*.60 and ahead>-.09 and absf(offset)<.48
 if not contact:
  yield_time=maxf(0.,yield_time-delta)
  if is_zero_approx(yield_time):yield_side=0.
  super._physics_process(delta)
  return
 if is_zero_approx(yield_side):yield_side=signf(offset) if absf(offset)>.05 else 1.
 yield_time=.22
 # Try the nearest shoulder first. Sweep against furniture and architecture.
 var advance:=direction*.30
 for step in [lateral*yield_side+advance,-lateral*yield_side+advance,direction]:
  var motion: Vector3=step.normalized()*3.45*delta
  if move_and_collide(motion,true)!=null:continue
  move_and_collide(motion)
  velocity=Vector3.ZERO
  repath373=0.
  route373.clear()
  face373(global_position+motion)
  advance_gait373(motion.length())
  apply_frame373(frame_index373(true))
  yielding_steps+=1
  return
 super._physics_process(delta)
