extends "res://scripts/world/woodland_world190.gd"
var lighting191: Node
func _init() -> void:
 super._init();memory_save116="user://forest191_preview.cfg"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 191 · 窗前暖光 / 林间小舞台")
func _forest_mood_script188() -> Script: return preload("res://scripts/art/forest_mood191.gd")
func _lighting_script191() -> Script: return preload("res://scripts/art/forest_lighting191.gd")
func _ready() -> void:
 await super._ready()
 lighting191=_lighting_script191().new();lighting191.world=self;add_child(lighting191)
 for layer in get_children():
  if layer is CanvasLayer:
   for child in layer.get_children():
    if child is Label and child.text.begins_with("190 "):
     child.text="191 窗前暖光 / 林间小舞台\nF8 样板 / F6 入口 / F7 小屋 / F3 小院\nF11 小径 / F10 调色 / F12 新灯光对照"
func _input(event: InputEvent) -> void:
 if is_instance_valid(lighting191) and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F12:
  lighting191.enabled=not lighting191.enabled;get_viewport().set_input_as_handled();return
 super._input(event)
