extends "res://scripts/combat/paper_card306.gd"

const SLAM_RADIUS323 := 1.5

func enter301(next: String) -> void:
 super.enter301(next)
 if not ready303 or next != "attack" or kind301 != "dinosaur":
  return
 var player: Vector3 = battle.hero.global_position
 visual.flip_h = player.x >= global_position.x
 pose302()
 var mouth := mouth303()
 var toward := Vector2(player.x - mouth.x, player.z - mouth.z)
 if not toward.is_zero_approx():
  direction301 = toward.normalized()

func dinosaur_motion305(player: Vector2, at: Vector2) -> Vector2:
 if state301 == "attack":
  return Vector2.ZERO
 return super.dinosaur_motion305(player, at) * 1.55

func monster_attack_duration304() -> float:
 return 3.1

func tracks_monster305() -> bool:
 return state301 == "warn" or phase303 == "pull"

func vertical_step303(delta: float) -> void:
 if state301 == "attack" and phase303 == "drop":
  vertical303 -= 24. * delta
  height303 = maxf(.12, height303 + vertical303 * delta)
  if height303 <= .12:
   land323()
  return
 # Lift to a readable apex, then let the next fall start with a fresh velocity.
 var raised := state301 == "warn" or (state301 == "attack" and phase303 == "pull")
 height303 = move_toward(height303, 1.25 if raised else HOVER302, delta * 4.)
 vertical303 = 0.

func land323() -> void:
 phase303 = "catch"
 phase_clock303 = 0.
 landings303 += 1
 pose302()
 var at := attack_at301()
 var floor_y := contact_height303()
 battle.legacy_contact_art(Vector3(at.x, floor_y + .12, at.y), Vector3.UP, false)
 battle.Audio.play("crack", .68)
 battle.trauma = maxf(battle.trauma, .07)
 var player: Vector3 = battle.hero.global_position
 if Vector2(player.x, player.z).distance_to(at) <= SLAM_RADIUS323:
  contact303(at)

func contact_height303() -> float:
 if kind301 == "monster":
  return battle.floor_height(attack_at301())
 return super.contact_height303()

func attack_origin301() -> Vector3:
 if kind301 == "monster":
  var at := attack_at301()
  return Vector3(at.x, contact_height303() + .68, at.y)
 return super.attack_origin301()

func can_release303() -> bool:
 return kind301 != "monster" or battle.can_heavy324(self)

func boss_recoil325() -> bool:
 return true
