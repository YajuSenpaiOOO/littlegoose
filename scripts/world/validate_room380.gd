extends SceneTree
var errors: Array[String]=[]
func check(ok: bool, label: String) -> void:
 if not ok:errors.append(label)
func shot(tag: String) -> Image:
 for i in 6:await process_frame
 await RenderingServer.frame_post_draw
 var im:=root.get_texture().get_image();im.save_png("res://docs/room380-"+tag+".png");return im
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var w=preload("res://scripts/world/room_world380.gd").new();root.add_child(w);current_scene=w
 while not is_instance_valid(w.shadow380):await process_frame
 var wing_local: Vector3=w.wing379.position
 var lo:=INF;var hi:=-INF
 for i in 140:
  await create_timer(.016).timeout
  lo=minf(lo,w.rig379.position.y);hi=maxf(hi,w.rig379.position.y)
  check(w.wing379.position==wing_local,"back attachment moved")
  check(w.rig379.scale.x>.98 and w.rig379.scale.y<1.02,"motion scale exceeded")
 check(hi-lo>.04 and hi-lo<.13,"hover amplitude")
 w.playing379=false;var frozen: Transform3D=w.rig379.transform
 await create_timer(.1).timeout;check(w.rig379.transform.is_equal_approx(frozen),"pause froze all motion")
 w.ink380.set_shader_parameter("body_weight",0.);w.ink380.set_shader_parameter("wing_weight",0.);var base: Image=await shot("no-shadow")
 w.ink380.set_shader_parameter("body_weight",1.);var body: Image=await shot("body-shadow")
 w.ink380.set_shader_parameter("body_weight",0.);w.ink380.set_shader_parameter("wing_weight",1.);var wing: Image=await shot("wing-shadow")
 w.ink380.set_shader_parameter("body_weight",1.);var both: Image=await shot("union-shadow")
 var overlap:=0;var darkened:=0
 # Restrict the test to this flight actor's ground area; the standing reference
 # continues breathing and can otherwise change pixels between captures.
 var foot: Vector2=w.camera.unproject_position(w.flight_root377.global_position)
 for y in range(int(foot.y),base.get_height(),2):
  for x in range(maxi(0,int(foot.x)-100),base.get_width(),2):
   var c: Color=base.get_pixel(x,y);var b: Color=body.get_pixel(x,y);var g: Color=wing.get_pixel(x,y);var u: Color=both.get_pixel(x,y)
   if c.r-b.r>.025 and c.r-g.r>.025:
    overlap+=1
    if minf(b.r,g.r)-u.r>.012:darkened+=1
 check(overlap>5,"GPU overlap pixels sampled")
 check(darkened==0,"GPU union overlap does not darken twice")
 w.set_night355(true);await shot("night");w.set_night355(false)
 w.motion380=false;w.playing379=true
 await create_timer(.4).timeout
 check(w.rig379.scale.is_equal_approx(Vector3.ONE) and is_zero_approx(w.rig379.rotation.z),"motion toggle restores neutral")
 w.reference379=true;w.pose379();w.update_shadow380();check(not w.shadow380.visible,"reference hides union shadow")
 var f:=FileAccess.open("res://docs/room380-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"errors":errors,"hover_range":[lo,hi],"overlap_samples":overlap,"double_darkened":darkened},"\t"));f.close()
 print("ROOM380_DONE ",errors);quit(0 if errors.is_empty() else 1)
