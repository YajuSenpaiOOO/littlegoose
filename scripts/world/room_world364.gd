extends "res://scripts/world/room_world363.gd"
var detail364:=false
func room_script355() -> Script:return preload("res://scripts/room/room_shell364.gd")
func _ready() -> void:
 await super._ready()
 DisplayServer.window_set_title("小白鹅 · 364 · 手绘3D局部样件")
 for node in title_panel.find_children("*","Label",true,false):node.text="364 · 手绘3D床头＋左枕样件\n其余床架/床垫是素色承托，非整床成品\nF11 新3D样件 / 2D画稿 · C 近看/全屋\nF9 专用绘制/素色 · F12 固定/跟随\nE 切2D床躺卧试演 · F10 睡位被子预览\nF2 昼夜 · F4 占地 · F5 占位\nF6 衣柜 · F7 归位 · F3 小院"
 follow_label363.position.y=240.
func set_sleep362(mode: int) -> void:
 super.set_sleep362(mode)
 if mode>0:room.set_craft364(false)
func set_detail364(value: bool) -> void:
 detail364=value;set_follow363(false)
 if value:
  var center: Vector3=room.item356("bed").root.global_position+Vector3(0.,1.20,-.55)
  camera.global_position=center+camera.global_basis.z*6.2
 else:camera.global_position=camera_home363
 camera.reset_physics_interpolation()
func _process(delta: float) -> void:
 super._process(delta)
 if camera_ready363 and detail364:follow_label363.text="近看：同25°/42FOV · C回全屋 · F11切对照"
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo:
  match event.physical_keycode:
   KEY_C:set_detail364(not detail364);get_viewport().set_input_as_handled();return
   KEY_F9:room.set_paint364(not room.painted364);get_viewport().set_input_as_handled();return
   KEY_F12:
    if detail364:set_detail364(false)
   KEY_F7:
    if detail364:set_detail364(false)
 super._input(event)
