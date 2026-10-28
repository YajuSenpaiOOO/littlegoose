extends "res://scripts/world/woodland_world196.gd"
func _init() -> void:
 super._init();memory_save116="user://forest198_preview.cfg"
func _hero_script() -> Script: return preload("res://scripts/combat/hero192.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 198 · 恢复竖直主角 / 关系修整基线")
func _ready() -> void:
 await super._ready()
 set_upright196(false)
 for layer in get_children():
  if layer is CanvasLayer:
   for child in layer.get_children():
    if child is Label and child.text.begins_with("196 "):
     child.text="198 竖直主角 / 材质受光 · 关系修整基线\nF6入口 / F7小屋 / F8样板 / F9吊床\nF3小院 / F11小径 / F10调色 / F12灯光"
func _input(event: InputEvent) -> void:
 # Retire display-angle experiments from the working baseline.
 if event is InputEventKey and event.pressed and event.physical_keycode in [KEY_F1,KEY_F2]:
  get_viewport().set_input_as_handled();return
 super._input(event)
