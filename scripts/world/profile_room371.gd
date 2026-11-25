extends SceneTree
var results: Array=[]
func _initialize() -> void:call_deferred("run")
func sample371(w: Node,tag: String) -> void:
 var frames: Array[float]=[]
 var last:=Time.get_ticks_usec()
 for i in 180:
  await process_frame
  var now:=Time.get_ticks_usec();frames.append(float(now-last)/1000.);last=now
 frames.sort()
 var row={"tag":tag,"median_ms":frames[90],"p95_ms":frames[171],"max_ms":frames[-1],"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"video_MB":Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)/1048576.,"static_MB":Performance.get_monitor(Performance.MEMORY_STATIC)/1048576.}
 results.append(row);print("ROOM371_PROFILE ",row)
func run() -> void:
 Engine.max_fps=60
 var baseline: bool="--baseline" in OS.get_cmdline_user_args()
 var path: String="res://scripts/world/room_world370.gd" if baseline else "res://scripts/world/room_world371.gd"
 var w=load(path).new();root.add_child(w);current_scene=w
 while not w.ready355:await process_frame
 for i in 20:await process_frame
 await sample371(w,"370-idle" if baseline else "371-idle")
 w.set_sleep362(1)
 await sample371(w,"370-sleep" if baseline else "371-sleep")
 if not baseline:
  var weak: WeakRef=weakref(w);w.leave371();w=null
  var start:=Time.get_ticks_msec();var completed:=false
  while Time.get_ticks_msec()-start<120000:
   await process_frame
   var scene=current_scene
   if scene!=null and "arc_shadows167" in scene and is_instance_valid(scene.arc_shadows167):completed=true;break
  print("YARD371_TEST ready=",completed," elapsed_ms=",Time.get_ticks_msec()-start," old_room_freed=",weak.get_ref()==null)
  if not completed:quit(2);return
  await sample371(current_scene,"169-after-exit")
 var file:=FileAccess.open("res://docs/room371-profile-"+("baseline" if baseline else "fixed")+".json",FileAccess.WRITE);file.store_string(JSON.stringify(results,"\t"));file.close()
 quit()

