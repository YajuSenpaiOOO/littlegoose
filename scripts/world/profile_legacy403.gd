extends SceneTree
var begin403:=0
func _initialize() -> void:call_deferred("run")
func run() -> void:
 Engine.max_fps=60;begin403=Time.get_ticks_msec()
 var path:="res://scenes/world/world169.tscn"
 ResourceLoader.load_threaded_request(path)
 while ResourceLoader.load_threaded_get_status(path)==ResourceLoader.THREAD_LOAD_IN_PROGRESS:await process_frame
 if ResourceLoader.load_threaded_get_status(path)!=ResourceLoader.THREAD_LOAD_LOADED:quit(2);return
 var read_ms:=Time.get_ticks_msec()-begin403
 print("LEGACY403_RESOURCE_MS ",read_ms)
 var packed: PackedScene=ResourceLoader.load_threaded_get(path)
 var at:=Time.get_ticks_msec();var w=packed.instantiate();var inst_ms:=Time.get_ticks_msec()-at
 at=Time.get_ticks_msec();root.add_child(w);current_scene=w
 print("LEGACY403_ADD_CHILD_MS ",Time.get_ticks_msec()-at)
 while not is_instance_valid(w.arc_shadows167) and Time.get_ticks_msec()-begin403<120000:await process_frame
 var report:={"resource_ms":read_ms,"instantiate_ms":inst_ms,"total_ready_ms":Time.get_ticks_msec()-begin403,"ready":is_instance_valid(w.arc_shadows167),"static_MB":Performance.get_monitor(Performance.MEMORY_STATIC)/1048576.,"video_MB":Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)/1048576.}
 print("LEGACY403_DONE ",JSON.stringify(report))
 FileAccess.open("res://docs/home403-legacy.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 quit()
