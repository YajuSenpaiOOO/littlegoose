extends "res://scripts/world/room_world357.gd"
func room_script355() -> Script:return preload("res://scripts/room/room_shell358.gd")
func _ready() -> void:
 await super._ready()
 DisplayServer.window_set_title("小白鹅 · 358 · 分层双人床")
 for node in title_panel.find_children("*","Label",true,false):node.text=node.text.replace("357 · 立体手绘衣柜","358 · 分层双人床")+"\nF8 睡位标记 · F9 被子 · F10 新床/旧图"
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo:
  match event.physical_keycode:
   KEY_F8:room.slots358.visible=not room.slots358.visible;get_viewport().set_input_as_handled();return
   KEY_F9:room.blanket358.visible=not room.blanket358.visible;get_viewport().set_input_as_handled();return
   KEY_F10:room.toggle_bed358();get_viewport().set_input_as_handled();return
 super._input(event)
