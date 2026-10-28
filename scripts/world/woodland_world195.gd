extends "res://scripts/world/woodland_world194.gd"
func _init() -> void:
 super._init();memory_save116="user://forest195_preview.cfg"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 195 · 稳定前景 / 提前林荫退让")
func _whole_fade_script67() -> Script: return preload("res://scripts/art/whole_tree_fade195.gd")
func _ready() -> void:
 await super._ready()
 for layer in get_children():
  if layer is CanvasLayer:
   for child in layer.get_children():
    if child is Label and child.text.begins_with("194 "): child.text=child.text.replace("194 双生树吊床 / 林边层次 / 慢半拍呜喵","195 稳定前景 / 提前林荫退让")
