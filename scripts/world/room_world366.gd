extends "res://scripts/world/room_world365.gd"
func room_script355() -> Script:return preload("res://scripts/room/room_shell366.gd")
func _ready() -> void:
 await super._ready()
 DisplayServer.window_set_title("小白鹅 · 366 · 奶油厚被与绿色搭毯")
 for node in title_panel.find_children("*","Label",true,false):node.text=node.text.replace("365 · 床单与褶边床裙","366 · 奶油厚被与绿色搭毯").replace("V 床单床裙/旧承托 · 厚被子尚未制作","Q 被子/床单 · G 搭毯 · V 床单床裙")
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_Q:
   room.show_duvet366=not room.show_duvet366;room.update_covers366();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_G:
   room.show_throw366=not room.show_throw366;room.update_covers366();get_viewport().set_input_as_handled();return
 super._input(event)
