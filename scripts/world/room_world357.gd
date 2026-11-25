extends "res://scripts/world/room_world356.gd"
func room_script355() -> Script:return preload("res://scripts/room/room_shell357.gd")
func _ready() -> void:
 await super._ready()
 DisplayServer.window_set_title("小白鹅 · 357 · 立体手绘衣柜")
 for node in title_panel.find_children("*","Label",true,false):node.text=node.text.replace("356 · 家具角度对照","357 · 立体手绘衣柜")+"\nF6 立体衣柜 / 原画稿"
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F6:
  room.toggle357();get_viewport().set_input_as_handled();return
 super._input(event)
