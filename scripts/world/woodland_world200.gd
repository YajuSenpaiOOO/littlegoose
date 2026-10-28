extends "res://scripts/world/woodland_world199.gd"
func _init() -> void:
 super._init();memory_save116="user://forest200_preview.cfg"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 200 · 整树避让 / 遮挡判定修正")
func _whole_fade_script67() -> Script: return preload("res://scripts/art/whole_tree_fade200.gd")
func _relations_script199() -> Script: return preload("res://scripts/art/prop_relations200.gd")
func _ready() -> void:
 await super._ready()
 for layer in get_children():
  if layer is CanvasLayer:
   for child in layer.get_children():
    if child is Label and child.text.begins_with("199 "):
     child.text=child.text.replace("199 整件遮挡 / 同步树影 / 小径视线","200 整树避让 / 遮挡判定修正")
