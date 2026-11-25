extends SceneTree
var failures: Array[String]=[]
func check(ok: bool, label: String) -> void:
 if not ok:failures.append(label)
func shot(tag: String) -> Image:
 for i in 6:await process_frame
 await RenderingServer.frame_post_draw
 var im:=root.get_texture().get_image();im.save_png("res://docs/room382-"+tag+".png");return im
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var w=preload("res://scripts/world/room_world382.gd").new();root.add_child(w);current_scene=w
 while not is_instance_valid(w.hair382):await process_frame
 w.playing379=false
 var pixel_report: Array=[]
 for d in [0,1,2,3]:
  w.set_direction381(d)
  for i in 4:
   w.show_frame379(i)
   if d==0 or d==2:check(w.wing379.position.z<w.body379.position.z,"outer arm precedes root")
   if d==1:check(w.hair382.visible and w.hair382.position.z>w.wing379.position.z and w.wing379.position.z>w.body379.position.z,"hair > wing > back")
   var fixed: Image=await shot(str(d)+"-"+str(i))
   if d==0 or d==2:
    w.wing379.visible=false;w.far381.visible=false
    var ref: Image=await shot(str(d)+"-"+str(i)+"-arm-reference")
    w.fixed382=false;w.set_direction381(d);w.show_frame379(i);w.wing379.visible=true
    var old: Image=await shot(str(d)+"-"+str(i)+"-old")
    w.fixed382=true;w.set_direction381(d);w.show_frame379(i)
    var src: Image=w.body379.texture.atlas.get_image()
    var samples:=0;var blocked:=0;var old_blocked:=0
    for sy in range(580,680,4):
     for sx in range(260 if d==0 else 140,380 if d==0 else 250,4):
      var c: Color=src.get_pixel(sx+(512 if d==2 else 0),sy)
      if c.a<.9 or c.r<.7 or c.g<.6 or c.b<.5:continue
      var pos: Vector3=w.body379.to_global(Vector3((sx-256)*w.body379.pixel_size,(930-sy)*w.body379.pixel_size,0))
      var screen: Vector2=w.camera.unproject_position(pos)*Vector2(ref.get_size())/w.get_viewport().get_visible_rect().size
      var point:=Vector2i(screen)
      var rc: Color=ref.get_pixelv(point);var fc: Color=fixed.get_pixelv(point);var oc: Color=old.get_pixelv(point)
      samples+=1
      if absf(rc.r-fc.r)>.025:blocked+=1
      if absf(rc.r-oc.r)>.025:old_blocked+=1
    pixel_report.append({"direction":d,"frame":i,"samples":samples,"fixed_occluded":blocked,"old_occluded":old_blocked})
    check(samples>10 and blocked==0,"GPU outer sleeve/arm visible "+str(d)+"/"+str(i))
  w.fixed382=false;w.set_direction381(d);await shot(str(d)+"-old");w.fixed382=true
 w.set_direction381(1);w.set_night355(true);await shot("back-night");w.set_night355(false)
 w.set_pair372(false);await shot("room")
 w.set_direction381(0);w.playing379=true
 for i in 45:
  await create_timer(.02).timeout
  check(w.wing379.position.z<w.body379.position.z,"animated arm order")
 var f:=FileAccess.open("res://docs/room382-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"failures":failures,"arm_pixels":pixel_report},"\t"));f.close()
 print("ROOM382_DONE ",failures);quit(0 if failures.is_empty() else 1)
