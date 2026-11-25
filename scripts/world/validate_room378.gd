extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var w=preload("res://scripts/world/room_world378.gd").new();root.add_child(w);current_scene=w
 while not is_instance_valid(w.body378):await process_frame
 w.flap378=false
 for i in 30:await process_frame
 var body_pose: Transform3D=w.body378.transform
 var errors: Array[String]=[]
 for phase in [0.,PI*.5,PI*1.5]:
  w.phase378=phase;w.pose378()
  for i in 8:await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://docs/room378-phase-"+str(snappedf(phase,.1))+".png")
  if w.body378.transform!=body_pose:errors.append("body moved")
 w.set_night355(true)
 for i in 10:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/room378-night.png")
 w.reference378=true;w.pose378()
 if w.rig378.visible or not w.flight377.visible:errors.append("reference toggle")
 var f:=FileAccess.open("res://docs/room378-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"errors":errors,"body_static":w.body378.transform==body_pose,"wing_count":w.wings378.size()},"\t"));f.close()
 print("ROOM378_DONE ",errors);quit(0 if errors.is_empty() else 1)
