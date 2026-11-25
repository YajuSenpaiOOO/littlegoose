extends "res://scripts/world/room_world355.gd"
func room_script355() -> Script:return preload("res://scripts/room/room_shell356.gd")
func home_goose355() -> bool:return false
func _ready() -> void:
 await super._ready()
 DisplayServer.window_set_title("小白鹅 · 356 · 家具角度对照")
 for node in title_panel.find_children("*","Label",true,false):node.text=node.text.replace("355 · 暖木小屋","356 · 家具角度对照")+"\nF5 画稿 / 体积对照"
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F5:
  room.set_art356(not room.art356);get_viewport().set_input_as_handled();return
 super._input(event)
