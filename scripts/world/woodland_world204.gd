extends "res://scripts/world/woodland_world203.gd"
func _init() -> void:
 super._init();memory_save116="user://forest204_preview.cfg"
func _paper_manager_script146() -> Script: return preload("res://scripts/combat/paper_ground204.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 204 · 纸飞机贴地辅助圈")
func _ready() -> void:
 await super._ready()
 for layer in get_children():
  if layer is CanvasLayer:
   for child in layer.get_children():
    if child is Label and child.text.begins_with("203 "): child.text=child.text.replace("203 毛絮受击 / 软软幽灵猫","204 纸飞机贴地辅助圈")
