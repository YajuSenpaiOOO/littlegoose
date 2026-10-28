extends "res://scripts/world/woodland_world191.gd"
func _init() -> void:
 super._init();memory_save116="user://forest192_preview.cfg"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 192 · 原身形 / 材质受光 / 琥珀暖灯")
func _hero_script() -> Script: return preload("res://scripts/combat/hero192.gd")
func _forest_mood_script188() -> Script: return preload("res://scripts/art/forest_mood192.gd")
func _lighting_script191() -> Script: return preload("res://scripts/art/forest_lighting192.gd")
func _ready() -> void:
 await super._ready()
 for layer in get_children():
  if layer is CanvasLayer:
   for child in layer.get_children():
    if child is Label and child.text.begins_with("191 "):
     child.text="192 原身形 / 材质受光 / 琥珀暖灯\nF8 样板 / F6 入口 / F7 小屋 / F3 小院\nF11 小径 / F10 调色 / F12 新灯光对照"
