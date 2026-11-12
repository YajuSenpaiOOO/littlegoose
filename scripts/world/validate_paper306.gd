extends "res://scripts/world/validate_paper305.gd"

class Harness306:
 extends "res://scripts/world/woodland_world306.gd"
 func export_stats226() -> Error:
  return OK

func world_script301() -> Script:
 return Harness306

func report304() -> String:
 return "res://docs/paper306-validation.json"

func shot301(tag: String) -> void:
 for i in 4:
  await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/paper306-" + tag + ".png")

func extra304() -> void:
 await super.extra304()
 var c = solo303("knight")
 await settle(3)
 c.enter301("rest")
 c.render301()
 var drift: String = c.operator_pose306
 c.age += .22
 c.render301()
 check(drift.begins_with("drift") and c.operator_pose306 != drift, "upper paper cycles authored drift frames")
 c.enter301("warn")
 c.clock301 = 1.29
 c.render301()
 check(not c.cue301.visible and c.operator_pose306 == "attack1" and absf(c.visual.rotation.z) > .2, "final brace and operator pose read without ground cue")
 check(c.thread_support302().is_equal_approx(c.operator301.transform * (Vector3.UP * .08)), "line endpoint follows the posed paper anchor")
 await shot301("brace")
 w.ground_cues306 = true
 c.render301()
 check(c.cue301.visible, "ground cue remains available for comparison")
 w.ground_cues306 = false
 c.enter301("attack")
 clean303()
 w.reset_impact248()
 w.hero.parried = false
 w.hero.parry_t = .2
 w._teleport15(c.attack_at301())
 var hp: float = w.player_hp
 c.contact303(c.attack_at301())
 check(c.state301 == "stunned" and w.player_hp == hp and w.parry_threat306 == 0., "real heavy parry blocks damage and clears per-hit context")
 check(is_equal_approx(w.stop_duration, .15) and w.punch >= 1.35 and w.impact_clock.events.any(func(e): return e.group == "heavy306" and e.scale == .25), "heavy parry schedules stronger stop, zoom and slow motion")
 w.restart301()
 check(Engine.time_scale == 1. and w.impact_clock.events.is_empty(), "restarting clears heavy feedback")
