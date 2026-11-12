extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world300.gd"
 func export_stats226() -> Error:return OK
func shot300(tag: String) -> void:
 for i in 4:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/paper300-"+tag+".png")
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.available297:await process_frame
 var s=w.stage297;s.set_process(false)
 check(s.lanes.is_empty() and s.book==null and s.plinth==null,"old book, floor and moving plinth remain absent")
 check(is_equal_approx(s.castle.pixel_size*float(s.layout300.castle.span[0]),12.),"castle has enlarged real entry artwork")
 for state in [[1.9,"lean"],[2.7,"fold"],[3.7,"command"],[4.7,"entry"],[6.7,"outside"],[8.4,"settled"]]:
  s.sample(state[0]);await shot300(state[1])
  check(s.girl.position.is_equal_approx(s.HOME300),"fixed balcony position: "+state[1])
  check(s.girl.visible and s.balcony300.visible,"actor supported and visible: "+state[1])
  if state[1] in ["lean","fold","command"]:
   check(s.pose300==state[1] and s.visual.texture==s.POSES300[state[1]],"authored frame selected: "+state[1])
   check(is_equal_approx(s.visual.pixel_size*float(s.layout300[state[1]].span[1]),1.6),"constant actor height: "+state[1])
  if state[1]=="entry":
   check(s.gate_open298>.9 and s.door_shape298.disabled,"gate opens before entry")
   check(s.puppet298.visible and s.puppet298.position.x>.5 and s.puppet298.position.x<1.2 and s.puppet298.position.z<.5,"puppet starts behind centre gate, not on flank")
  if state[1]=="outside":
   check(s.puppet298.position.z>2. and absf(s.puppet298.position.x)<1.3,"puppet travels into front through centre")
 check(not s.door_shape298.disabled,"gate closes after operator clears entry")
 for i in 3:await physics_frame
 var space=w.get_world_3d().direct_space_state
 var start=s.global_position+Vector3(0,.7,2.);var end=s.global_position+Vector3(0,.7,-.7)
 check(not space.intersect_ray(PhysicsRayQueryParameters3D.create(start,end,2)).is_empty(),"closed gate has real blocker")
 s.sample(5.);for i in 3:await physics_frame
 check(space.intersect_ray(PhysicsRayQueryParameters3D.create(start,end,2)).is_empty(),"open gate clears real blocker")
 s.sample(8.6);s._process(.01);check(s.finished and w.hero.controls_enabled and not w.combat_paused,"entry completes and restores control")
 s.actor_clock300=1.8;s._process(.01);check(s.pose300=="fold","post-intro idle loop keeps folding")
 s.actor_clock300=4.;s._process(.01);check(s.pose300=="command","post-intro idle loop signals troops")
 s.start();check(not s.castle.visible and not s.puppet298.visible and s.pose300=="idle","replay resets actor/stage")
 s.cancel();check(w.hero.controls_enabled and not w.combat_paused,"cancel restores controls")
 FileAccess.open("res://docs/paper300-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"scope":"balcony keyframes and synchronized gate entry; not full boss AI"},"  "))
 quit(0 if checks.all(func(c):return c.pass) else 1)
