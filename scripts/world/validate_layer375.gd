extends SceneTree
var failures: Array[String]=[]
var results: Array=[]
func _initialize() -> void:call_deferred("run")
func snap() -> Image:
 for i in 6:await process_frame
 await RenderingServer.frame_post_draw
 return root.get_texture().get_image()
func diff(a: Color,b: Color) -> float:return absf(a.r-b.r)+absf(a.g-b.g)+absf(a.b-b.b)
func run() -> void:
 var w=preload("res://scripts/world/room_world375.gd").new();root.add_child(w);current_scene=w
 while not is_instance_valid(w.companion373) or not w.companion373.ready373:await physics_frame
 w.companion373.hold373();w.set_sleep362(1)
 var source:=Image.load_from_file("res://assets/room369/sleep_full_pixel.png")
 for mode in ["detail","fixed","follow","wide","pillow-stress"]:
  w.set_follow363(false);w.set_detail364(mode in ["detail","pillow-stress"])
  if mode=="pillow-stress":w.room.pillow364.position.y+=.20
  if mode=="follow":
   w.set_follow363(true)
   for i in 100:await physics_frame
  if mode=="wide":root.size=Vector2i(1600,900)
  w.follow363=false
  var objects: Array=[]
  for parent in [w.room.pillow364,w.room.right_pillow368]:
   for node in parent.get_children():
    if node is MeshInstance3D and node.visible:objects.append(node)
  var scale: Vector2
  var losses: Array=[]
  var counts: Array=[]
  for enabled in [false,true]:
   w.room.layer375=enabled
   for node in objects:node.hide()
   var reference: Image=await snap()
   w.room.sleep_root369.hide();var background: Image=await snap();w.room.sleep_root369.show()
   for node in objects:node.show()
   var actual: Image=await snap()
   scale=Vector2(actual.get_size())/w.camera.get_viewport().get_visible_rect().size
   var lo:=Vector2.INF;var hi:=-Vector2.INF
   for uv in [Vector2(0.,0.),Vector2(1.,0.),Vector2(0.,.55),Vector2(1.,.55)]:
    var point: Vector2=w.camera.unproject_position(w.room.craft364.to_global(w.room.SLEEP369.point369(uv)))*scale
    lo=lo.min(point);hi=hi.max(point)
   var count:=0;var lost:=0
   for y in range(maxi(0,int(lo.y)-3),mini(actual.get_height(),int(hi.y)+4)):
    for x in range(maxi(0,int(lo.x)-3),mini(actual.get_width(),int(hi.x)+4)):
     if diff(reference.get_pixel(x,y),background.get_pixel(x,y))<.25:continue
     count+=1
     if diff(reference.get_pixel(x,y),actual.get_pixel(x,y))>.12:lost+=1
   losses.append(lost);counts.append(count)
   if enabled:actual.save_png("res://docs/room375-layer-"+mode+".png")
  var row={"view":mode,"old_actor_pixels":counts[0],"new_actor_pixels":counts[1],"old_pillow_occluded":losses[0],"new_pillow_occluded":losses[1],"pillow_depth":w.room.pillow_depth375,"actor_depth_limit":w.room.proxy_depth375};results.append(row);print("LAYER375 ",row)
  if w.room.proxy_depth375>=w.room.pillow_depth375 or counts[1]<100 or losses[1]>2:failures.append(mode)
 w.room.pillow364.position.y-=.20
 w.room.show_duvet366=false;w.room.update_covers366();w.set_detail364(true);var revealed: Image=await snap();revealed.save_png("res://docs/room375-uncovered.png")
 if w.room.pose_material369.get_shader_parameter("cover_mask"):failures.append("Q")
 var out:=FileAccess.open("res://docs/room375-layer-validation.json",FileAccess.WRITE);out.store_string(JSON.stringify({"failures":failures,"views":results},"\t"));out.close()
 print("LAYER375_DONE ",failures);quit(0 if failures.is_empty() else 1)
