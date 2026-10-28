extends "res://scripts/world/woodland_world192.gd"
var enemy_grade193: Node
func _init() -> void:
 super._init();memory_save116="user://forest193_preview.cfg"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 193 · 昼夜演员 / 系绳吊床 / 林间暖光")
func _forest_art_script188() -> Script: return preload("res://scripts/art/forest_art193.gd")
func _forest_mood_script188() -> Script: return preload("res://scripts/art/forest_mood193.gd")
func _lighting_script191() -> Script: return preload("res://scripts/art/forest_lighting193.gd")
func _ready() -> void:
 await super._ready()
 enemy_grade193=preload("res://scripts/combat/enemy_grade193.gd").new();enemy_grade193.world=self;add_child(enemy_grade193)
 for layer in get_children():
  if layer is CanvasLayer:
   for child in layer.get_children():
    if child is Label and child.text.begins_with("192 "):
     child.text="193 昼夜演员 / 系绳吊床 / 林间暖光\nF8 样板 / F6 入口 / F7 小屋 / F3 小院\nF11 小径 / F10 调色 / F12 新灯光对照"
