extends Node3D
var host405: Node3D
var ready405:=false
func _ready() -> void:
 Engine.max_fps=60
 var start:=Time.get_ticks_msec()
 var layer:=CanvasLayer.new();layer.layer=120;add_child(layer)
 var bg:=ColorRect.new();bg.color=Color("292e29");bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);layer.add_child(bg)
 var label:=Label.new();label.position=Vector2(75,95);label.add_theme_font_size_override("font_size",23);layer.add_child(label)
 label.text="正在准备大地图落位对照…\n本轮加载完整旧地图，进入后切换房屋不重载。"
 await get_tree().process_frame;await get_tree().process_frame
 var path:="res://scripts/world/woodland_world405.gd"
 var error:=ResourceLoader.load_threaded_request(path,"Script")
 if error!=OK:label.text="读取失败："+str(error);return
 while ResourceLoader.load_threaded_get_status(path)==ResourceLoader.THREAD_LOAD_IN_PROGRESS:
  label.text="正在读取完整大地图… %.1f秒"%((Time.get_ticks_msec()-start)/1000.)
  await get_tree().process_frame
 if ResourceLoader.load_threaded_get_status(path)!=ResourceLoader.THREAD_LOAD_LOADED:label.text="大地图资源读取失败";return
 var resource_ms:=Time.get_ticks_msec()-start
 var script: Script=ResourceLoader.load_threaded_get(path);host405=script.new();add_child(host405)
 while not host405.ready405:
  label.text="正在构建旧大地图与小屋… %.1f秒"%((Time.get_ticks_msec()-start)/1000.)
  await get_tree().process_frame
 var row:={"resource_ms":resource_ms,"total_ms":Time.get_ticks_msec()-start,"static_MB":Performance.get_monitor(Performance.MEMORY_STATIC)/1048576.,"video_MB":Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)/1048576.}
 print("FIT405_STARTUP ",JSON.stringify(row));FileAccess.open("res://docs/home405-startup.json",FileAccess.WRITE).store_string(JSON.stringify(row,"\t"))
 ready405=true;layer.queue_free()
