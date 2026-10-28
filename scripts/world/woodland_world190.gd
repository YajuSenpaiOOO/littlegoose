extends "res://scripts/world/woodland_world189.gd"
func _init() -> void:
 super._init();memory_save116="user://forest190_preview.cfg"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 190 · 统一受光 / 无光照断线")
func _porch_script() -> Script: return preload("res://scripts/art/woodland_palette190.gd")
func _hero_script() -> Script: return preload("res://scripts/combat/hero190.gd")
func _forest_mood_script188() -> Script: return preload("res://scripts/art/forest_mood190.gd")
func _ready() -> void:
 await super._ready()
 for layer in get_children():
  if not layer is CanvasLayer: continue
  for child in layer.get_children():
   if child is Label and child.text.begins_with("189 "):
    child.text="190 统一受光 / 无光照断线\nF8 样板 / F6 入口 / F7 小屋 / F3 小院\nF11 小径中段 / F10 光色对照"
