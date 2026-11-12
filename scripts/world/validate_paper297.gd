extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world297.gd"
 func export_stats226() -> Error:return OK
func shot297(tag: String) -> void:
 for i in 4:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/paper297-"+tag+".png")
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.available297:await process_frame
 var s=w.stage297;s.set_process(false);w.hero.set_physics_process(false)
 check(w.enemies.is_empty() and not w.active114,"opening preview has no live Tuantuan battle")
 check(not w.hero.controls_enabled and w.combat_paused,"opening locks input before toss")
 check(is_equal_approx(s.visual.pixel_size*1268.,1.6),"paper girl visible height matches native hero1.6")
 for state in [[0.,"idle"],[1.35,"toss"],[2.8,"fold"],[4.9,"castle"]]:
  s.sample(state[0]);await shot297(state[1])
  check(s.girl.position.is_finite() and s.book.position.is_finite(),"finite staging at "+state[1])
  check(s.visual.texture==(s.THROW if state[0]>=.72 and state[0]<4.65 else s.IDLE),"single held/separate book switch at "+state[1])
 check(not s.book.visible and s.castle.visible and s.bodies.all(func(b):return not b.disabled),"completed castle solid wings, no duplicate floating book")
 check(s.visual.material_override.albedo_texture==s.IDLE,"native receiver follows current actor texture")
 s.sample(5.1);s._process(.01)
 check(s.finished and not s.playing and w.hero.controls_enabled and not w.combat_paused,"opening returns control")
 s.start();check(s.playing and s.age==0. and s.bodies.all(func(b):return b.disabled),"replay resets stage and collision")
 s.cancel();check(not s.playing and w.hero.controls_enabled and not w.combat_paused,"cancel restores input/pause")
 FileAccess.open("res://docs/paper297-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"scope":"opening prototype, no boss AI or damage"},"  "))
 quit(0 if checks.all(func(c):return c.pass) else 1)
