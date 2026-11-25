extends "res://scripts/world/room_world370.gd"
var leaving371:=false
var diagnostics371: Array=[]
var diagnostic_time371:=0.
var peak371:=0.
func room_script355() -> Script:return preload("res://scripts/room/room_shell371.gd")
func _ready() -> void:
 Engine.max_fps=60
 await super._ready()
 DisplayServer.window_set_title("小白鹅 · 371 · 室内性能与出门加载")
 help367=help367.replace("370 · 盖被遮挡与室内补光","371 · 遮挡按需更新 / 出门加载")
 refresh367()
func leave371() -> void:
 if leaving371:return
 leaving371=true
 if sleeping362:set_sleep362(0)
 get_tree().call_deferred("change_scene_to_file","res://scenes/world/yard_loading371.tscn")
func interact355() -> void:
 if not sleeping362:
  var near: Dictionary=choose355()
  if not near.is_empty() and near.id=="exit":leave371();return
 super.interact355()
func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F3:
  leave371();get_viewport().set_input_as_handled();return
 if leaving371:return
 super._input(event)

func _process(delta: float) -> void:
 super._process(delta)
 diagnostic_time371+=delta;peak371=maxf(peak371,delta*1000.)
 if diagnostic_time371>=10.:
  diagnostics371.append({"time_ms":Time.get_ticks_msec(),"fps":Engine.get_frames_per_second(),"peak_frame_ms":peak371,"video_MB":Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)/1048576.,"static_MB":Performance.get_monitor(Performance.MEMORY_STATIC)/1048576.,"sleep":sleeping362,"mask_updates":room.mask_updates371})
  if diagnostics371.size()>60:diagnostics371.pop_front()
  var out:=FileAccess.open("res://docs/room371-runtime.json",FileAccess.WRITE)
  if out:out.store_string(JSON.stringify(diagnostics371,"\t"));out.close()
  diagnostic_time371=0.;peak371=0.
