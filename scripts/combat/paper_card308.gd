extends "res://scripts/combat/paper_card307.gd"

const MIN_CONTACT_SPEED308 := 4.5
var swing_axis308 := Vector2.ZERO
var swing_speed308 := 0.

func charge_duration304() -> float:
 return 1.55

func aim_lock307() -> float:
 return charge_duration304() - .20

func charge_pose306(drift_pose: String) -> String:
 return "attack1" if clock301 >= aim_lock307() else drift_pose

func track_pivot307(delta: float) -> void:
 var lead := Vector2(battle.hero.velocity.x, battle.hero.velocity.z).limit_length(4.) * .16
 var target: Vector2 = battle.paper_clamp301(Vector2(battle.hero.position.x, battle.hero.position.z) + lead)
 var start := Vector2(global_position.x, global_position.z)
 var goal := start + (target - start).limit_length(7.)
 # The flying operator can cross low obstacles that still block the knight.
 var aerial_goal := Vector3(goal.x, battle.floor_height(goal) + 3.9, goal.y)
 pivot307 = pivot307.move_toward(aerial_goal, delta * 11.)
 var pull := Vector2(pivot307.x, pivot307.z) - start
 if pull.length_squared() > .01:
  direction301 = pull.normalized()
 lane_start303 = attack_at301()
 lane_end303 = start + pull

func enter301(next: String) -> void:
 if ready303 and kind301 == "knight" and next == "attack":
  var pull := Vector2(pivot307.x - global_position.x, pivot307.z - global_position.z)
  swing_axis308 = pull.normalized()
  if swing_axis308 != Vector2.ZERO:
   direction301 = swing_axis308
  swing_speed308 = 0.
  super.enter301(next)
  if pull.length() < .35:
   ring_velocity304 = Vector2.ZERO
  return
 super.enter301(next)

func step_ring304(delta: float) -> void:
 var previous := ring304
 # Keep the oscillation on the locked line, even when arena bounds clip a step.
 ring_velocity304 = swing_axis308 * ring_velocity304.dot(swing_axis308)
 super.step_ring304(delta)
 swing_speed308 = previous.distance_to(ring304) / maxf(delta, .001)

func can_ring_contact304() -> bool:
 return swing_speed308 >= MIN_CONTACT_SPEED308

func bound_swing307(from: Vector2, to: Vector2) -> Vector2:
 var clipped: Vector2 = battle.paper_clamp301(to)
 var travel := to - from
 var fraction := 1.
 for axis in 2:
  if absf(travel[axis]) > .00001:
   fraction = minf(fraction, clampf((clipped[axis] - from[axis]) / travel[axis], 0., 1.))
 return from + travel * fraction
