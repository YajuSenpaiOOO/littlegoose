extends "res://scripts/world/room_world366.gd"
var help367:=""
var label367: Label
func room_script355() -> Script:return preload("res://scripts/room/room_shell367.gd")
func _ready() -> void:
 await super._ready()
 DisplayServer.window_set_title("小白鹅 · 367 · 像素床与手绘床对照")
 for node in title_panel.find_children("*","Label",true,false):
  label367=node;help367=node.text.replace("366 · 奶油厚被与绿色搭毯","367 · 像素床 / 手绘床对照")
 follow_label363.position.y=270.
 refresh367()
func refresh367() -> void:
 if is_instance_valid(label367):label367.text=help367+"\nP 切换画风 · 当前："+("像素色块" if room.pixel367 else "原手绘")
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_P:
  room.set_pixel367(not room.pixel367);refresh367();get_viewport().set_input_as_handled();return
 super._input(event)
