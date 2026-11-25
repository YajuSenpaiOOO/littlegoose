extends SceneTree
var failures: Array[String]=[]
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func _initialize() -> void:call_deferred("run")
func settle(w: Node) -> void:
 while w.busy406:await process_frame
 for i in 55:await process_frame
func capture(tag: String) -> void:
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://docs/home409-"+tag+".png")
func run() -> void:
 var w=load("res://scenes/world/world409.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready406:await process_frame
 var map_id: int=w.map406.get_instance_id();var room_id: int=w.room406.get_instance_id()
 check(w.map406.mode405==2,"outside uses smaller 3D cottage")
 check(w.map406.model405.scale.is_equal_approx(Vector3.ONE*.68),"3D exterior uses 68 percent uniform scale")
 for i in 30:await process_frame
 await capture("outside")
 var furniture: Array=[]
 for row in w.room406.room.footprints:furniture.append([row.root,row.root.transform])
 for i in 3:
  var key:=InputEventKey.new();key.pressed=true;key.physical_keycode=KEY_F3;w._input(key);await settle(w)
  check(w.indoors406 and w.room406.hero.controls_enabled,"F3 enters compact room")
  check(w.map406.process_mode==Node.PROCESS_MODE_DISABLED,"outside simulation pauses indoors")
  if i==0:
   var r=w.room406.room
   check(is_equal_approx(r.floor391.mesh.size.x*r.floor391.scale.x,11.34),"interior architectural width reduced by ten percent")
   check(r.item356("bed").root.scale==Vector3.ONE and w.room406.hero.scale==Vector3.ONE,"bed and actor keep original dimensions")
   w.room406.hero.set_physics_process(false);w.room406.hero.global_position=Vector3(0,.05,.8);w.room406.hero.reset_physics_interpolation()
   for tick in 35:w.room406.hero.velocity=Vector3(0,0,-2.5);w.room406.hero.move_and_slide();await physics_frame
   check(w.room406.hero.position.z<-.4,"compressed central aisle remains physically passable")
   var bed: Dictionary=r.item356("bed");w.room406.hero.global_position=Vector3(bed.approach.x,.05,bed.approach.y);w.room406.interact355()
   check(w.room406.sleeping362,"relocated bed can be used")
   w.room406.interact355();check(not w.room406.sleeping362,"relocated bed wakes correctly")
   w.room406.reset355();w.room406.hero.set_physics_process(true)
  if i==0:await capture("inside")
  w.room406.leave371();await settle(w)
  check(not w.indoors406 and w.map406.hero.controls_enabled,"room exit fades back into retained map")
  if i==0:await capture("return")
  check(w.map406.get_instance_id()==map_id and w.room406.get_instance_id()==room_id,"both scenes retained across crossings")
 var intact:=true
 for row in furniture:intact=intact and row[0].transform==row[1]
 check(intact,"compact layout stays stable across crossings")
 print("HOME409_DONE ",failures)
 if failures.is_empty() and "--play-after" in OS.get_cmdline_user_args():return
 quit(0 if failures.is_empty() else 1)
