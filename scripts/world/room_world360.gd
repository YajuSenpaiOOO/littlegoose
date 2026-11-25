extends "res://scripts/world/room_world359.gd"
func room_script355() -> Script:return preload("res://scripts/room/room_shell360.gd")
func _ready() -> void:
 await super._ready()
 DisplayServer.window_set_title("小白鹅 · 360 · 羽毛双人床")
 for node in title_panel.find_children("*","Label",true,false):node.text=node.text.replace("359 · 软寝具试版","360 · 羽毛双人床").replace("F11 软寝具 / 方盒对照","F11 新床 / 359对照")
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_F9 and room.use360:
   room.cover360.visible=not room.cover360.visible;get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_F8 and room.use360:
   room.slots358.reparent(room.bed360,false);room.slots358.visible=not room.slots358.visible;get_viewport().set_input_as_handled();return
 super._input(event)
