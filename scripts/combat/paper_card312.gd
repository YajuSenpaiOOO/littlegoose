extends "res://scripts/combat/paper_card306.gd"

var target312 := Vector2.ZERO
var launch_distance312 := 0.
var outgoing312 := false
var swing_speed312 := 0.
var support312 := Vector3.ZERO
var support_velocity312 := Vector3.ZERO

func _physics_process(delta: float) -> void:
 if ready303 and not dead and battle.active114 and not battle.combat_paused:
  if state301 == "warn":
   aim312()
  elif state301 in ["attack", "recover", "stunned"]:
   step_support312(delta)
 super._physics_process(delta)

func uses_legacy_aim305() -> bool:
 return false

func aim312() -> void:
 var player: Vector3 = battle.hero.global_position
 target312 = Vector2(player.x, player.z)
 var pull := target312 - Vector2(global_position.x, global_position.z)
 if pull.length_squared() > .0025:
  direction301 = pull.normalized()

func enter301(next: String) -> void:
 if ready303 and next == "attack":
  aim312()
  pose302()
  support312 = operator301.global_position
  support_velocity312 = Vector3.ZERO
  launch_distance312 = target312.distance_to(Vector2(global_position.x, global_position.z))
  outgoing312 = launch_distance312 > .05
 super.enter301(next)
 if ready303 and next == "warn":
  aim312()
 if ready303 and next == "attack":
  ring_velocity304 = direction301 * clampf(launch_distance312 * 7.5, 23., 42.) if outgoing312 else Vector2.ZERO

func step_support312(delta: float) -> void:
 if state301 == "attack" and clock301 < .22:
  return
 var attachment := to_global(visual.transform * tab302())
 var line := attachment - support312
 var distance := line.length()
 var axis := line.normalized()
 var rope_length := lerpf(4.6, 2.0, smoothstep(.22, 1.25, clock301)) if state301 == "attack" else 2.
 var tension := maxf(0., distance - rope_length) * 22.
 var neutral := global_position + Vector3.UP * 3.55
 support_velocity312 += ((neutral - support312) * 10. + axis * tension - support_velocity312 * 5.) * delta
 support312 += support_velocity312 * delta
 if state301 == "attack" and not outgoing312:
  ring_velocity304 -= Vector2(axis.x, axis.z) * tension * .35 * delta

func step_ring304(delta: float) -> void:
 var previous := ring304
 var launched := outgoing312
 var wall: Dictionary = {}
 var steps := maxi(1, ceili(delta * 120.))
 var dt := delta / steps
 for i in steps:
  if not outgoing312:
   ring_velocity304 += (-ring304 * 28. - ring_velocity304 * 2.1) * dt
  ring304 += ring_velocity304 * dt
  if outgoing312 and ring304.dot(direction301) >= launch_distance312:
   outgoing312 = false
 var root_at := Vector2(position.x, position.z)
 var start := root_at + previous
 var end := root_at + ring304
 var from := Vector3(start.x, battle.floor_height(start) + .8, start.y)
 var to := Vector3(end.x, battle.floor_height(end) + .8, end.y)
 if not from.is_equal_approx(to):
  wall = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to, 1 | 2))
  if not wall.is_empty():
   var offset := Vector2(wall.position.x, wall.position.z) - start
   end = start + offset.limit_length(maxf(0., offset.length() - .08))
   outgoing312 = false
   ring_velocity304 *= -.25
 ring304 = end - root_at
 swing_speed312 = ring304.distance_to(previous) / maxf(delta, .001)

 if launched and not wall.is_empty():
  charge_wall_hit312(wall)

func charge_wall_hit312(_wall: Dictionary) -> void:
 pass

func can_ring_contact304() -> bool:
 return swing_speed312 > 3.

func contact_height303() -> float:
 return battle.floor_height(attack_at301())

func pose302() -> void:
 super.pose302()
 if not ready303 or dead or state301 not in ["attack", "recover", "stunned"]:
  return
 var root_at := Vector2(position.x, position.z)
 visual.position.x = ring304.x
 visual.position.z = ring304.y
 if state301 == "attack" and clock301 < .12:
  visual.position.y = lerpf(.04, visual.position.y, smoothstep(0., .12, clock301))
 visual.position.y += battle.floor_height(root_at + ring304) - battle.floor_height(root_at)
 hit_area.position = visual.transform * Vector3(0, height301 * .5, 0)
 operator301.global_position = support312
 operator_anchor306 = operator301.transform * (Vector3.UP * .08)

func attack_at301() -> Vector2:
 if ready303 and state301 in ["attack", "recover", "stunned"]:
  return Vector2(position.x, position.z) + ring304
 return super.attack_at301()

func ground_cue306() -> bool:
 return false

func contact_damage303() -> float:
 return 1.5

func contact303(at: Vector2) -> void:
 var previous: float = battle.player_hp
 super.contact303(at)
 if battle.player_hp < previous and battle.active114:
  battle.hitstop(.075, true)
  battle.punch = maxf(battle.punch, 1.15)
