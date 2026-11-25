extends SceneTree
var failures: Array[String]=[]
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var w=preload("res://scripts/world/room_world376.gd").new();root.add_child(w);current_scene=w
 while not is_instance_valid(w.companion373) or not w.companion373.ready373:await physics_frame
 var c=w.companion373;c.hold373();w.set_pair372(true)
 w.hero.set_physics_process(false);w.hero.set_process(false)
 for i in 30:await physics_frame
 var at: Vector3=c.global_position;var phase: float=c.gait375
 var low:=10.0;var high:=-10.0
 for i in 180:
  await physics_frame
  low=minf(low,c.visual.scale.y);high=maxf(high,c.visual.scale.y)
 check(high-low>.010 and high-low<.014,"idle breathing gentle scale range")
 check(c.global_position.distance_to(at)<.01 and c.visual.position.is_zero_approx(),"idle foot and physics stay grounded")
 check(is_equal_approx(phase,c.gait375),"breathing does not advance gait")
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/room376-idle.png")
 w.hero.global_position=Vector3(-3.0,.05,2.8);c.resume373()
 var roll:=0.0;var lift:=0.0;var stretch:=0.0;var distance: float=c.walked375
 for i in 500:
  await physics_frame
  roll=maxf(roll,absf(c.visual.rotation.z));lift=maxf(lift,c.visual.position.y);stretch=maxf(stretch,c.visual.scale.y-1.0)
  if i==32:
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png("res://docs/room376-walking.png")
  if c.global_position.distance_to(w.hero.global_position)<1.0:break
 check(roll>.008 and roll<=.0131 and lift>.01 and lift<=.0181 and stretch>.02 and stretch<=.0281,"distance-driven roll lift and squash bounded")
 check(absf(fposmod(phase+(c.walked375-distance)/c.CYCLE_DISTANCE375,1.0)-c.gait375)<.0001,"motion preserves distance-driven cadence")
 c.hold373()
 for i in 30:await physics_frame
 check(c.visual.position.length()<.0001 and absf(c.visual.rotation.z)<.0001,"stop settles lift and roll")
 c.motion376=false;await physics_frame;await physics_frame
 check(c.visual.scale.is_equal_approx(Vector3.ONE) and c.visual.rotation.is_zero_approx() and c.visual.position.is_zero_approx(),"toggle restores original pose")
 var report={"failures":failures,"idle_y_scale_range":[low,high],"walk_max_roll_rad":roll,"walk_max_lift":lift,"walk_max_stretch":stretch}
 var f:=FileAccess.open("res://docs/room376-motion-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
 print("MOTION376_DONE ",failures);quit(0 if failures.is_empty() else 1)
