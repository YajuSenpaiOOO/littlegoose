extends "res://scripts/combat/paper_card312.gd"

var wall_rebound321 := Vector2.ZERO

func enter301(next: String) -> void:
 super.enter301(next)
 if next != "stunned":
  wall_rebound321 = Vector2.ZERO
 if next != "attack" or not ready303 or not outgoing312:
  return
 # Give a charge a little follow-through when the player baits it near the wall.
 var past_player := target312 + direction301 * 1.75
 var from := Vector3(target312.x, battle.floor_height(target312) + .8, target312.y)
 var to := Vector3(past_player.x, battle.floor_height(past_player) + .8, past_player.y)
 var wall := get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to, 1 | 2))
 if not wall.is_empty() and wall.collider == battle.theatre314.bodies[0].get_parent():
  launch_distance312 += 1.75

func charge_wall_hit312(wall: Dictionary) -> void:
 if battle.knight_wall321(wall):
  enter301("stunned")
  var panel_x: float = battle.theatre314.panel321.global_position.x
  wall_rebound321 = Vector2(panel_x + 1.65 - global_position.x, .35)

func settle_ring304(delta: float) -> void:
 if state301 != "stunned" or wall_rebound321.is_zero_approx():
  super.settle_ring304(delta)
  return
 var release := 1. - smoothstep(.75, 1.45, clock301)
 ring304 = ring304.lerp(wall_rebound321 * release, 1. - exp(-delta * 11.))

func can_release303() -> bool:
 return battle.can_heavy324(self)

func boss_recoil325() -> bool:
 return true

func pose302() -> void:
 super.pose302()
 if not ready303 or dead or state301 not in ["stunned", "recover"]:
  return
 # In recovery, the dash offset and the hit-driven pendulum both show.
 var lateral := angle302.normalized() * sin(angle302.length()) * rope_length302
 visual.position += Vector3(lateral.x, 0., lateral.y)
 hit_area.position = visual.transform * Vector3(0., height301 * .5, 0.)
