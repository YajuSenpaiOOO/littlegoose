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
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://docs/home406-"+tag+".png")
func run() -> void:
 var w=load("res://scenes/world/world406.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready406:await process_frame
 var map_id: int=w.map406.get_instance_id();var room_id: int=w.room406.get_instance_id()
 check(w.map406.mode405==1,"outside retains original small cottage")
 for i in 30:await process_frame
 await capture("outside")
 var furniture: Array=[]
 for row in w.room406.room.footprints:furniture.append([row.root,row.root.transform])
 for i in 3:
  var key:=InputEventKey.new();key.pressed=true;key.physical_keycode=KEY_F3;w._input(key);await settle(w)
  check(w.indoors406 and w.room406.hero.controls_enabled,"F3 fade enters original-size room")
  check(w.map406.process_mode==Node.PROCESS_MODE_DISABLED,"outside simulation pauses indoors")
  if i==0:await capture("inside")
  w.room406.leave371();await settle(w)
  check(not w.indoors406 and w.map406.hero.controls_enabled,"room exit fades back into retained map")
  if i==0:await capture("return")
  check(w.map406.get_instance_id()==map_id and w.room406.get_instance_id()==room_id,"both scenes retained across crossings")
 var intact:=true
 for row in furniture:intact=intact and row[0].transform==row[1]
 check(intact,"indoor furniture never scaled or rearranged")
 print("HOME406_DONE ",failures)
 if failures.is_empty() and "--play-after" in OS.get_cmdline_user_args():return
 quit(0 if failures.is_empty() else 1)
