extends "res://scripts/world/woodland_world188.gd"
func _init() -> void:
 super._init();memory_save116="user://forest189_preview.cfg"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 189 · 紫色林荫 / 拨花 / 吊床猫猫")
func _forest_art_script188() -> Script: return preload("res://scripts/art/forest_art189.gd")
func _forest_mood_script188() -> Script: return preload("res://scripts/art/forest_mood189.gd")
func _ready() -> void:
 await super._ready()
 for layer in get_children():
  if not layer is CanvasLayer: continue
  for child in layer.get_children():
   if child is Label and child.text.begins_with("188 "):
    child.text="189 紫色林荫 / 拨花 / 吊床猫猫\nF8 样板 / F6 入口 / F7 小屋 / F3 小院\nF11 小径中段 / F10 光色对照"
func _input(event: InputEvent) -> void:
 if forest_ready188 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F11:
  if connection188.size()>0: _teleport15(connection188[connection188.size()/2])
  get_viewport().set_input_as_handled();return
 super._input(event)
