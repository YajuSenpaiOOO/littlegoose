extends SceneTree
class Trial:
 extends "res://scripts/world/woodland_world335.gd"
 var cursor335:=Vector2.INF
 func acquire_structure335(cursor: Vector2) -> Dictionary:
  return super.acquire_structure335(cursor335 if cursor335.is_finite() else cursor)
 func export_stats226() -> Error: return OK
var failures:=0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func capture(w: Node, tag: String) -> void:
 var selected: Dictionary=w.structure335.duplicate()
 w._process(.016)
 w.structure335=selected
 w.structure_ui335.queue_redraw()
 for i in 4: await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/castle-candidates/335-"+tag+".png")
func run() -> void:
 var w=Trial.new()
 root.add_child(w)
 current_scene=w
 var limit:=Time.get_ticks_msec()+180000
 while not is_instance_valid(w.structure_ui335) and Time.get_ticks_msec()<limit: await process_frame
 if not is_instance_valid(w.structure_ui335):
  quit(1)
  return
 w.trial_ui114.set_process(false)
 w.set_physics_process(false)
 w.hero.set_physics_process(false)
 var stage=w.theatre314
 stage.set_process(false)
 stage.cancel()
 stage.sample(4.06)
 stage.finished=true
 w.boss_step314(.01)
 w.set_process(false)
 await physics_frame
 await process_frame
 await physics_frame
 w.normal_form335=3
 w.scatter327(0)
 check(w.paper_queue334.size()==21 and stage.gap335.visible,"21 spokes plus visible safe gap")
 var dirs: Array=w.paper_queue334.map(func(s): return s.aim)
 w.tick_paper_queue334(.49)
 check(w.cannon_shots326.is_empty(),"gap prewarning before emission")
 w.tick_paper_queue334(.02)
 check(w.cannon_shots326.size()==21,"ring emitted together after warning")
 var first: Vector2=dirs[0]
 var last: Vector2=dirs.back()
 check(absf(first.angle_to(last))>1.,"angular opening wider than regular spoke spacing")
 await capture(w,"ring")
 w.normal_form335=7
 w.scatter327(0)
 check(Vector2(w.paper_queue334[0].aim).distance_to(first)>.2,"next ring rotates opening")
 w.interrupt327(0)
 check(w.paper_queue334.is_empty() and not stage.gap335.visible,"disable cancels queued ring and cue")
 # Real camera rays and the real screen bracket.
 for i in 2:
  var area: Area3D=stage.cannon_areas326[i]
  var shape: CollisionShape3D=area.get_child(0)
  var cursor: Vector2=w.camera.unproject_position(shape.global_position)
  w.cursor335=cursor
  var found: Dictionary=w.acquire_structure335(cursor)
  check(not found.is_empty() and found.collider==area,"native cannon ray selects gun %d"%i)
  w.structure335=found
  w.structure_ui335.queue_redraw()
  await capture(w,"gun-%d"%i)
  check(w.structure_ui335.drawn335.size.x>10.,"native cannon bracket draws %d"%i)
  w.hurt_cannon326(i,16.)
  check(w.acquire_structure335(cursor).is_empty(),"disabled cannon no longer acquired %d"%i)
  w.structure335=found
  w.structure_ui335.queue_redraw()
  await process_frame
  check(w.structure_ui335.drawn335.size==Vector2.ZERO,"stale gun bracket clears immediately %d"%i)
 var acquired:=false
 for shape in stage.castle_target327.get_children():
  var cursor: Vector2=w.camera.unproject_position(shape.global_position)
  w.cursor335=cursor
  var found: Dictionary=w.acquire_structure335(cursor)
  if not found.is_empty() and found.collider==stage.castle_target327:
   acquired=true
   w.structure335=found
   w.structure_ui335.queue_redraw()
   await capture(w,"castle")
   check(w.structure_ui335.drawn335.size.x>10.,"castle bracket draws wall bay")
   break
 check(acquired,"castle real geometry acquired")
 w.finish251(true)
 check(w.structure335.is_empty() and not stage.gap335.visible,"victory clears structure targeting and ring cue")
 w.restart301()
 check(w.ring_turn335==0 and w.normal_form335==0 and w.fastener_hp321==144.,"restart resets ring cycle and durability")
 print("RESULT failures=",failures)
 quit(failures)
