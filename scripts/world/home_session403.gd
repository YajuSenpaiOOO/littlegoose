extends Node3D
var host403: Node3D
var ready403:=false
var report403: Dictionary={}
var previous_cache403:=false
func host_path403() -> String:return "res://scripts/world/room_world403.gd"
func version403() -> String:return "403"
func _ready() -> void:
 Engine.max_fps=60
 previous_cache403=preload("res://scripts/room/mesh_cache403.gd").enabled403
 preload("res://scripts/room/mesh_cache403.gd").enabled403=true
 var start:=Time.get_ticks_msec()
 var canvas:=CanvasLayer.new();add_child(canvas)
 var bg:=ColorRect.new();bg.color=Color("292522");bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);canvas.add_child(bg)
 var label:=Label.new();label.text="正在准备家园…";label.position=Vector2(80,100);label.add_theme_font_size_override("font_size",24);canvas.add_child(label)
 await get_tree().process_frame;await get_tree().process_frame
 var first_frame:=Time.get_ticks_msec()-start
 var path:=host_path403()
 var error:=ResourceLoader.load_threaded_request(path,"Script")
 if error!=OK:label.text="家园读取失败："+str(error);return
 while ResourceLoader.load_threaded_get_status(path)==ResourceLoader.THREAD_LOAD_IN_PROGRESS:
  label.text="正在读取家园资源… %.1f秒"%((Time.get_ticks_msec()-start)/1000.)
  await get_tree().process_frame
 if ResourceLoader.load_threaded_get_status(path)!=ResourceLoader.THREAD_LOAD_LOADED:label.text="家园资源读取失败";return
 var resource_ms:=Time.get_ticks_msec()-start
 var script: Script=ResourceLoader.load_threaded_get(path)
 var at:=Time.get_ticks_msec();host403=script.new();var inst_ms:=Time.get_ticks_msec()-at
 at=Time.get_ticks_msec();add_child(host403);var add_ms:=Time.get_ticks_msec()-at
 while not host403.home_ready403:await get_tree().process_frame
 for i in 3:await get_tree().process_frame
 report403={"first_overlay_ms":first_frame,"resource_ready_ms":resource_ms,"instantiate_ms":inst_ms,"initial_add_child_ms":add_ms,"room_ms":host403.room_build_ms403,"yard_ms":host403.yard_build_ms403,"total_ready_ms":Time.get_ticks_msec()-start,"static_MB":Performance.get_monitor(Performance.MEMORY_STATIC)/1048576.,"video_MB":Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)/1048576.}
 print("HOME"+version403()+"_READY ",JSON.stringify(report403))
 FileAccess.open("res://docs/home"+version403()+"-startup.json",FileAccess.WRITE).store_string(JSON.stringify(report403,"\t"))
 ready403=true;canvas.queue_free()
 if ("--home"+version403()+"-profile") in OS.get_cmdline_user_args():get_tree().quit()
func _exit_tree() -> void:
 var cache=preload("res://scripts/room/mesh_cache403.gd")
 cache.enabled403=previous_cache403
 if not previous_cache403:cache.held403.clear();cache.checked403=false;cache.valid403=false
