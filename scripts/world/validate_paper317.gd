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
 root.get_texture().get_image().save_png("res://docs/castle-candidates/318-" + tag + ".png")
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
 for kind in ["knight", "monster", "dinosaur"]:
  w.spawned301 = 1 if kind == "knight" else (2 if kind == "monster" else 4)
  w.spawn314()
  var pending = stage.summon_card317
  check(pending.kind301 == kind and not pending.visible and pending.hit_area.collision_layer == 0 and not w.enemies.has(pending),"pending summon isolated " + kind)
  stage.sample_summon317(1.3)
  check(stage.packet313.visible and stage.handler313.visible and not stage.summon_preview317.visible,"throw and descending catcher " + kind)
  stage.sample_summon317(2.4)
  check(stage.summon_preview317.visible and stage.line313.visible and not stage.packet313.visible,"unfold correct actor " + kind)
  if kind == "knight": await shot("knight-catch317")
  stage.sample_summon317(stage.SUMMON_END317)
  var endpoint: Vector3 = stage.summon_preview317.global_position
  check(endpoint.distance_to(pending.visual.global_position) < .001,"seamless actor endpoint " + kind)
  stage.finish_summon317()
  check(pending.visible and pending.hit_area.collision_layer == 8 and w.enemies.has(pending),"combat enabled after unfold " + kind)
  pending.set_physics_process(false)
  pending.hide()
 w.entry_clock314 = -1.
 stage.begin_collapse314()
 for t in [.4,1.1,2.4,4.6]:
  stage.collapse314(t)
  var expected_frame: int = {0.4: 12, 1.1: 13, 2.4: 14, 4.6: 11}[t]
  check(stage.frame316 == expected_frame,"rescue/cry pose %.1f" % t)
  if expected_frame in [13, 14]:
   var local_hook := Vector3(41. if expected_frame == 13 else 42., 272., 0.) * pixel
   var rope: PackedVector3Array = stage.line_mesh313.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
   check(rope[0].is_equal_approx(stage.girl.transform * local_hook), "rope meets the visible strap at %.1f" % t)
  if expected_frame != 11: await shot("rescue-%d" % expected_frame)
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
