extends "res://scripts/combat/paper_card306.gd"

const AIM_LOCK307 := 1.15
var pivot307 := Vector3.ZERO

func enter301(next: String) -> void:
 if ready303 and kind301 == "knight":
  if next == "warn":
   pivot307 = global_position + Vector3(0, 3.55, .02)
  elif next == "rest" and state301 in ["recover", "stunned"]:
   var at := Vector2(global_position.x, global_position.z) + ring304
   global_position = Vector3(at.x, battle.floor_height(at) + .04, at.y)
   ring304 = Vector2.ZERO
 super.enter301(next)

func _physics_process(delta: float) -> void:
 if ready303 and kind301 == "knight" and not dead and battle.active114 and not battle.combat_paused and state301 == "warn" and clock301 < aim_lock307():
  track_pivot307(delta)
 super._physics_process(delta)

func pose302() -> void:
 super.pose302()
 if kind301 != "knight" or not ready303 or state301 not in ["warn", "attack", "recover", "stunned"]:
  return
 operator301.global_position = pivot307
 # Reattach the line after moving the operator to its world-space support.
 operator_anchor306 = operator301.transform * (Vector3.UP * .08)

func charge_pose306(drift_pose: String) -> String:
 return "attack1" if clock301 >= AIM_LOCK307 else drift_pose

func step_ring304(delta: float) -> void:
 var root_at := Vector2(global_position.x, global_position.z)
 var centre := Vector2(pivot307.x, pivot307.z) - root_at
 var previous := ring304
 var steps := maxi(1, int(ceil(delta * 120.)))
 var dt := delta / steps
 for i in steps:
  ring_velocity304 += ((centre - ring304) * 28. - ring_velocity304 * 2.5) * dt
  ring304 += ring_velocity304 * dt
 var goal := centre + (ring304 - centre).limit_length(ring_limit304)
 var bounded := bound_swing307(root_at + previous, root_at + goal)
 var reached := clear_swing307(root_at + previous, bounded)
 if reached.distance_squared_to(root_at + ring304) > .000001:
  ring_velocity304 *= -.25
 ring304 = reached - root_at

func clear_swing307(from: Vector2, to: Vector2) -> Vector2:
 if from.is_equal_approx(to):
  return to
 var start := Vector3(from.x, global_position.y + .8, from.y)
 var end := Vector3(to.x, start.y, to.y)
 var wall := get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(start, end, 1 | 2))
 if wall.is_empty():
  return to
 var offset := Vector2(wall.position.x, wall.position.z) - from
 return from + offset.limit_length(maxf(0., offset.length() - .15))

func launch_speed304() -> float:
 var offset := Vector2(pivot307.x - global_position.x, pivot307.z - global_position.z)
 ring_limit304 = 7.
 return clampf(offset.length() * 7.5, 23., 42.)

func settle_ring304(delta: float) -> void:
 var at := Vector2(global_position.x, global_position.z)
 var centre := Vector2(pivot307.x, pivot307.z)
 var next := (at + ring304).lerp(centre, 1. - exp(-delta * 4.))
 ring304 = clear_swing307(at + ring304, next) - at

func aim_lock307() -> float:return AIM_LOCK307

func track_pivot307(delta: float) -> void:
 var lead := Vector2(battle.hero.velocity.x, battle.hero.velocity.z).limit_length(4.) * .16
 var target: Vector2 = battle.paper_clamp301(Vector2(battle.hero.position.x, battle.hero.position.z) + lead)
 var start := Vector2(global_position.x, global_position.z)
 var travel := target - start
 var reachable := clear_swing307(start, start + travel.limit_length(6.))
 var goal := Vector3(reachable.x, battle.floor_height(reachable) + 3.9, reachable.y)
 pivot307 = pivot307.move_toward(goal, delta * 10.)

func bound_swing307(_from: Vector2, to: Vector2) -> Vector2:
 return battle.paper_clamp301(to)
