extends "res://scripts/world/room_world358.gd"
func room_script355() -> Script:return preload("res://scripts/room/room_shell359.gd")
func _ready() -> void:
 await super._ready()
 DisplayServer.window_set_title("小白鹅 · 359 · 软寝具试版")
 for node in title_panel.find_children("*","Label",true,false):node.text=node.text.replace("358 · 分层双人床","359 · 软寝具试版")+"\nF11 软寝具 / 方盒对照"
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F11:
  room.toggle_soft359();get_viewport().set_input_as_handled();return
 super._input(event)
