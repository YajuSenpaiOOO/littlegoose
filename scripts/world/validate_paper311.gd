extends "res://scripts/world/validate_paper305.gd"

class Harness311:
 extends "res://scripts/world/woodland_world311.gd"
 func export_stats226() -> Error:
  return OK

func run() -> void:
 w = Harness311.new()
 root.add_child(w)
 current_scene = w
 while not w.ready301:
  await process_frame
 var c = solo303("knight")
 await settle(3)
 c.set_physics_process(false)
 var start := Vector2(c.position.x, c.position.z)
 var target := start + Vector2(2.5, 4.)
 w._teleport15(target)
 c.enter301("warn")
 advance303(c, .35)
 var early: Vector3 = c.operator301.global_position
 advance303(c, .85)
 var pivot: Vector3 = c.operator301.global_position
 check(c.cue301.visible and c.state301 == "warn", "locked diagonal lane is visible before release")
 check(early.distance_to(pivot) > 2. and Vector2(pivot.x, pivot.z).distance_to(target) < .5, "operator approaches gradually over original charge")
 w._teleport15(start + Vector2(2., 2.))
 advance303(c, .39)
 check(c.state301 == "attack" and c.ring304.length() < .7, "long charge line does not teleport knight at release")
 advance303(c, .09)
 check(c.ring304.length() > 2. and absf(c.ring304.cross((target - start).normalized())) < .05, "first strike goes straight toward locked support")
 check(c.operator301.global_position.is_equal_approx(pivot), "operator stays at the locked location")
 var before: Vector2 = c.ring304
 var incoming: Vector2 = c.ring_velocity304.normalized()
 var hp: float = w.player_hp
 clean303()
 w.hero.parried = false
 w.hero.parry_t = .2
 w._teleport15(c.attack_at301())
 c.contact303(c.attack_at301())
 check(c.state301 == "stunned" and c.ring_velocity304.dot(incoming) < -10. and w.player_hp == hp, "actual parry reverses swing and prevents player damage")
 check(is_equal_approx(w.stop_duration, .18) and w.punch >= 2.35 and w.impact_clock.events.any(func(e): return e.group == "heavy306" and e.scale == .23), "strong stop zoom and slow-motion are scheduled")
 advance303(c, .065)
 check((c.ring304 - before).dot(incoming) < -.3 and c.operator301.global_position.is_equal_approx(pivot), "parried knight actually moves backwards with support fixed")
 check(w.player_hp == hp, "stunned reverse swing does not hit the player")
 w.restart301()
 check(Engine.time_scale == 1. and w.impact_clock.events.is_empty(), "restart clears heavy feedback")
 c = solo303("knight")
 await settle(3)
 c.set_physics_process(false)
 start = Vector2(c.position.x, c.position.z)
 w._teleport15(start + Vector2(2.5, 4.))
 c.enter301("warn")
 advance303(c, 1.61)
 before = c.ring304
 incoming = c.ring_velocity304.normalized()
 c.deflect(w.hero.position + Vector3.UP * .7)
 advance303(c, .04)
 check(before.length() < 1.5 and (c.ring304 - before).dot(incoming) < -.15, "early parry reverses even on a long line without snapping toward support")
 FileAccess.open("res://docs/paper311-validation.json", FileAccess.WRITE).store_string(JSON.stringify({"checks": checks}, "  "))
 quit(0 if checks.all(func(v): return v.pass) else 1)
