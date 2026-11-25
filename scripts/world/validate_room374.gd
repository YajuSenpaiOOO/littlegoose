extends SceneTree
var failures: Array[String]=[]
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func capture(tag: String) -> void:
 for i in 5:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/room374-"+tag+".png")
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var w=preload("res://scripts/world/room_world374.gd").new();root.add_child(w);current_scene=w
 while not is_instance_valid(w.companion373) or not w.companion373.ready373:await physics_frame
 var c=w.companion373
 check(c.atlas373.size()==4,"four independently authored direction strips load")
 check(w.human_visual372.rotation.is_zero_approx(),"upright actor retained")
 w.set_pair372(true);c.hold373();await capture("pair-idle")
 var fixed: Vector3=c.global_position
 for i in 90:await physics_frame
 check(c.global_position.distance_to(fixed)<.01,"hold stands still without foot jitter")
 w.set_pair372(false);w.hero.set_physics_process(false);w.hero.set_process(false)
 var results: Array=[]
 for target in [Vector3(-3.,.05,2.),Vector3(-1.7,.05,-2.6),Vector3(2.7,.05,-2.8),Vector3(3.,.05,1.8),Vector3(-3.8,.05,.4)]:
  w.hero.global_position=target;w.hero.reset_physics_interpolation();c.resume373()
  var start: Vector3=c.global_position
  for i in 600:
   await physics_frame
   if i==40:await capture("walking-"+str(results.size()+1))
   if c.global_position.distance_to(target)<1.1:break
  var distance: float=c.global_position.distance_to(target);results.append({"target":target,"distance":distance})
  check(distance<1.2,"follow reaches hero around room furniture "+str(target))
  check(c.global_position.distance_to(start)>.3,"companion actually walks rather than teleporting")
  await capture("follow-"+str(results.size()))
 check(c.seen_frames373.size()>=8,"movement visits multiple direction and step frames")
 check(absf(w.human_visual372.offset.y-(w.human_visual372.texture.get_height()*.5))<w.human_visual372.texture.get_height(),"sprite anchor remains finite")
 var rest: Vector3=c.global_position
 for i in 90:await physics_frame
 check(c.global_position.distance_to(rest)<.03,"arrived follower stays settled")
 c.stage373(Vector3(0.,.05,0.))
 for i in 600:
  await physics_frame
  if c.arrived373:break
 check(c.arrived373 and c.mode373=="hold","scripted stand position hands control to hold")
 w.set_night355(true);await capture("night");w.set_night355(false)
 for key in ["down","up","left","right"]:
  c.direction373=key;c.hold373();await capture("direction-"+key)
 w.set_sleep362(1);c.resume373();var sleep_at: Vector3=c.global_position
 for i in 60:await physics_frame
 check(c.global_position.distance_to(sleep_at)<.03,"sleeping hero pauses companion follow")
 w.set_sleep362(0)
 var bed: Dictionary=w.room.item356("bed")
 w.hero.global_position=Vector3(bed.approach.x,.05,bed.approach.y);c.global_position=w.hero.global_position+Vector3(.6,0.,0.);c.hold373()
 w.interact355();check(w.sleeping362,"nearby companion does not steal bed E interaction")
 w.interact355();check(not w.sleeping362,"E wakes the sleeping hero with companion nearby")
 w.hero.set_physics_process(true);w.hero.set_process(true);w.reset355()
 check(c.mode373=="follow" and w.hero.visible,"reset restores follow and walking hero")
 var out:=FileAccess.open("res://docs/room374-validation.json",FileAccess.WRITE);out.store_string(JSON.stringify({"failures":failures,"routes":results,"seen_frames":c.seen_frames373.keys()},"\t"));out.close()
 print("ROOM374_DONE ",failures);quit(0 if failures.is_empty() else 1)
