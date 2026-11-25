extends SceneTree
var errors: Array[String]=[]
func check(ok: bool, label: String) -> void:
 if not ok:errors.append(label)
func shot(tag: String) -> Image:
 for i in 6:await process_frame
 await RenderingServer.frame_post_draw
 var image:=root.get_texture().get_image();image.save_png("res://docs/room381-"+tag+".png");return image
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var w=preload("res://scripts/world/room_world381.gd").new();root.add_child(w);current_scene=w
 while not w.initialized381:await process_frame
 w.playing379=false
 for d in 4:
  w.set_direction381(d)
  var near_root: Vector3=w.wing379.position;var far_root: Vector3=w.far381.position
  var body: Transform3D=w.body379.transform
  for i in 4:
   w.show_frame379(i)
   check(w.wing379.position==near_root and w.far381.position==far_root,"stable roots "+str(d)+"/"+str(i))
   check(w.body379.transform==body,"static body "+str(d)+"/"+str(i))
   check(w.far381.visible==(d==0 or d==2),"side far wing visibility")
   if d==0 or d==2:
    check(w.far381.position.z<w.body379.position.z and w.wing379.position.z>w.body379.position.z,"near/body/far depth")
   var full: Image=await shot(str(d)+"-"+str(i))
   if (d==0 or d==2) and i==1:
    w.far381.visible=false
    var hidden: Image=await shot(str(d)+"-far-hidden")
    var foot: Vector2=w.camera.unproject_position(w.flight_root377.global_position)
    var changed:=0
    for y in range(maxi(0,int(foot.y)-300),mini(full.get_height(),int(foot.y)),2):
     for x in range(maxi(0,int(foot.x)-200),mini(full.get_width(),int(foot.x)+200),2):
      if absf(full.get_pixel(x,y).r-hidden.get_pixel(x,y).r)>.02:changed+=1
    print("FAR_VISIBLE ",d," ",changed);check(changed>5,"far wing visible beyond near/body "+str(d))
    w.far381.visible=true
  w.set_night355(true);await shot(str(d)+"-night");w.set_night355(false)
 w.set_direction381(0);w.playing379=true
 var relative: Vector3=w.body379.to_local(w.wing379.global_position)
 for i in 60:
  await create_timer(.02).timeout
  check(w.body379.to_local(w.wing379.global_position).is_equal_approx(relative),"hover attachment remains")
 w.soft370=false;await shot("fill-off");w.soft370=true
 w.reference379=true;w.pose379();w.update_shadow380();check(not w.shadow380.visible,"reference hides composite shadow")
 var f:=FileAccess.open("res://docs/room381-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"errors":errors,"direction_count":4,"frame_count":16,"side_layers":"near > body > far"},"\t"));f.close()
 print("ROOM381_DONE ",errors);quit(0 if errors.is_empty() else 1)
