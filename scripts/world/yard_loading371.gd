extends Control
const TARGET="res://scenes/world/world169.tscn"
var started371:=0
var phase371:=0
var status371: Label
func _ready() -> void:
 started371=Time.get_ticks_msec()
 var backdrop:=ColorRect.new();backdrop.color=Color("292522");backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(backdrop)
 status371=Label.new();status371.position=Vector2(100,150);status371.add_theme_font_size_override("font_size",24);add_child(status371)
 status371.text="正在离开小屋，释放室内资源…"
 await get_tree().process_frame
 await get_tree().process_frame
 var error:=ResourceLoader.load_threaded_request(TARGET)
 if error!=OK:status371.text="小院加载失败："+str(error);phase371=-1;return
 phase371=1
 print("YARD371_REQUEST after_room_release_ms=",Time.get_ticks_msec()-started371)
func _process(_delta: float) -> void:
 if phase371!=1:return
 var progress: Array=[]
 var state:=ResourceLoader.load_threaded_get_status(TARGET,progress)
 status371.text="正在读取小院资源… "+str(int(float(progress[0])*100.))+"%" if not progress.is_empty() else "正在读取小院资源…"
 if state==ResourceLoader.THREAD_LOAD_FAILED or state==ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
  status371.text="小院资源读取失败，请重新启动。";phase371=-1;return
 if state==ResourceLoader.THREAD_LOAD_LOADED:
  phase371=2;status371.text="资源已读取，正在构建小院…"
  call_deferred("enter371")
func enter371() -> void:
 await get_tree().process_frame
 var packed: PackedScene=ResourceLoader.load_threaded_get(TARGET)
 print("YARD371_RESOURCE_READY ms=",Time.get_ticks_msec()-started371)
 var overlay=load("res://scripts/world/yard_progress371.gd").new();overlay.layer=128;overlay.started371=started371
 get_tree().root.add_child(overlay)
 for child in get_children():child.reparent(overlay)
 overlay.status371=status371
 var error:=get_tree().change_scene_to_packed(packed)
 print("YARD371_CHANGE ms=",Time.get_ticks_msec()-started371," result=",error)
