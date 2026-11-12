extends SceneTree
class Harness316:
 extends "res://scripts/world/woodland_world314.gd"
 func export_stats226() -> Error:
  return OK
var failures := 0
func _initialize() -> void:
 call_deferred("run")
func check(ok: bool, message: String) -> void:
 print(("PASS " if ok else "FAIL ") + message)
 if not ok: failures += 1
func shot(tag: String) -> void:
 for i in 4: await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/castle-candidates/316-" + tag + ".png")
func run() -> void:
 var w = Harness316.new()
 root.add_child(w)
 current_scene = w
 var deadline := Time.get_ticks_msec() + 180000
 while not is_instance_valid(w.theatre314) and Time.get_ticks_msec() < deadline:
  await process_frame
 if not is_instance_valid(w.theatre314):
  check(false,"world ready")
  quit(1)
  return
 var stage = w.theatre314
 w.set_physics_process(false)
 w.set_process(false)
 stage.set_process(false)
 w.hero.set_physics_process(false)
 stage.playing = false
 stage.finished = true
 stage.sample(7.65)
 w.waiting_intro314 = false
 stage.clear_demo314()
 check(stage.frames316.size() == 16,"all 16 atlas cells ready")
 var pixel: float = .9 * stage.actor_height313() / 288.
 for i in 16:
  stage.pose316(i)
  check(is_equal_approx(stage.visual.pixel_size,pixel) and stage.visual.texture == stage.frames316[i] and stage.visual.material_override.albedo_texture == stage.frames316[i].atlas,"fixed scale and atlas material pose %d" % i)
 for t in [.1, .7, 2.5, 4.1, 4.6, 5., 5.3]:
  stage.sample(t)
  check(stage.visual.material_override.albedo_texture == stage.ACTIONS316,"intro uses new group at %.1f" % t)
 stage.sample(7.65)
 stage.reaction313(5)
 stage.reaction313(4)
 var released_hand: Vector3 = stage.girl.transform * Vector3(0., (297. - 172.) * pixel, .29)
 stage.sample_entry313(stage.RELEASE313)
 check(stage.packet313.position.distance_to(released_hand) < .001,"paper packet starts at new raised-paper hand")
 check(stage.reaction_index314 == 5 and stage.frame316 == 9,"angry reaction takes priority over happy")
 await shot("balcony-angry")
 stage.reaction_left313 = 0.
 stage.cue_card314("dinosaur")
 for t in [.15,.2,.2,.25,.3]:
  stage._process(t)
  check(stage.visual.material_override.albedo_texture == stage.ACTIONS316 and is_equal_approx(stage.visual.pixel_size,pixel),"later summons keep same group and scale")
 stage.begin_collapse314()
 for t in [.4,1.1,2.4,4.6]:
  stage.collapse314(t)
  var expected_frame: int = {0.4: 12, 1.1: 13, 2.4: 14, 4.6: 11}[t]
  check(stage.frame316 == expected_frame,"rescue/cry pose %.1f" % t)
  if t == 1.1: await shot("rescue")
 stage.girl.position = stage.to_local(w.hero.global_position) + Vector3(1.25,0.,0.)
 stage.girl.rotation = Vector3.ZERO
 stage.defeat_pose314(1)
 await shot("same-row-cry")
 stage.pixel_pose315()
 await shot("same-row-idle")
 stage.use_pixel315 = false
 stage.director_pose313(5)
 check(stage.visual.texture == stage.director_frames313[5],"F11 old group retained")
 stage.use_pixel315 = true
 stage.reset_battle314()
 stage.start()
 check(stage.visual.material_override.albedo_texture == stage.ACTIONS316 and stage.girl.rotation.x == 0.,"restart retains new upright actor")
 print("RESULT316 failures=%d" % failures)
 quit(1 if failures else 0)
