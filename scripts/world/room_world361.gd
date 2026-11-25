extends "res://scripts/world/room_world360.gd"
func room_script355() -> Script:return preload("res://scripts/room/room_shell361.gd")
func _ready() -> void:
 await super._ready()
 DisplayServer.window_set_title("小白鹅 · 361 · 床的手绘渲染对照")
 for node in title_panel.find_children("*","Label",true,false):node.text=node.text.replace("360 · 羽毛双人床","361 · 手绘渲染对照")+"\nF12 手绘/实时受光"
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_F12:
   room.set_painted361(not room.painted361);get_viewport().set_input_as_handled();return
 super._input(event)
