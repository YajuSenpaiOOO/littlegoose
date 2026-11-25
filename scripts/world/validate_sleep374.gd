extends SceneTree
var failures: Array[String]=[]
var results: Array=[]
func _initialize() -> void:call_deferred("run")
func snap() -> Image:
 for i in 6:await process_frame
 await RenderingServer.frame_post_draw
 return root.get_texture().get_image()
func delta(a: Color,b: Color) -> float:return absf(a.r-b.r)+absf(a.g-b.g)+absf(a.b-b.b)
func run() -> void:
 var w=preload("res://scripts/world/room_world374.gd").new();root.add_child(w);current_scene=w
 while not is_instance_valid(w.companion373) or not w.companion373.ready373:await physics_frame
 w.companion373.hold373();w.set_sleep362(1)
 var source:=Image.load_from_file("res://assets/room369/sleep_full_pixel.png")
 var old_total:=0
 for scenario in ["fixed","detail","follow","wide"]:
  w.set_follow363(false);w.set_detail364(scenario=="detail")
  if scenario=="follow":
   w.set_follow363(true)
   for i in 100:await physics_frame
  if scenario=="wide":root.size=Vector2i(1600,900)
  # Freeze the camera once positioned so comparison isolates actor visibility.
  w.follow363=false
  w.room.pose_material369.set_shader_parameter("head_only",false)
  var old: Image=await snap()
  w.room.pose_material369.set_shader_parameter("head_only",true)
  var fixed: Image=await snap();fixed.save_png("res://docs/room374-sleep-"+scenario+".png")
  w.room.sleep_root369.hide();var background: Image=await snap();w.room.sleep_root369.show()
  var count:=0;var old_leaks:=0;var new_leaks:=0
  var scale: Vector2=Vector2(fixed.get_size())/w.camera.get_viewport().get_visible_rect().size
  for y in range(730,1250,18):
   for x in range(100,1110,18):
    if source.get_pixel(x,y).a<.9:continue
    var uv:=Vector2(float(x)/source.get_width(),float(y)/source.get_height())
    var at: Vector3=w.room.craft364.to_global(w.room.SLEEP369.point369(uv))
    var point: Vector2=w.camera.unproject_position(at)*scale
    var px:=int(round(point.x));var py:=int(round(point.y))
    if px<0 or py<0 or px>=fixed.get_width() or py>=fixed.get_height():continue
    count+=1
    if delta(old.get_pixel(px,py),background.get_pixel(px,py))>.13:old_leaks+=1
    if delta(fixed.get_pixel(px,py),background.get_pixel(px,py))>.13:new_leaks+=1
  old_total+=old_leaks
  var row={"scenario":scenario,"lower_actor_samples":count,"old_leaks":old_leaks,"fixed_leaks":new_leaks};results.append(row);print("SLEEP374 ",row)
  if count<100 or new_leaks>0:failures.append(scenario)
 w.room.show_duvet366=false;w.room.update_covers366();await snap()
 if w.room.pose_material369.get_shader_parameter("cover_mask"):failures.append("Q did not restore full pose")
 print("SLEEP374_OLD_REPRO_SAMPLES ",old_total)
 var out:=FileAccess.open("res://docs/room374-sleep-validation.json",FileAccess.WRITE);out.store_string(JSON.stringify({"failures":failures,"samples":results,"old_reproduced":old_total>0},"\t"));out.close()
 print("SLEEP374_DONE ",failures);quit(0 if failures.is_empty() else 1)
