extends "res://scripts/world/woodland_world196.gd"
func _init() -> void:
 super._init();memory_save116="user://forest197_preview.cfg"
func _hero_script() -> Script: return preload("res://scripts/combat/hero197.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 197 · 主角相机平面对照 / 原图身形")
func set_upright196(on: bool) -> void:
 super.set_upright196(on)
 for layer in get_children():
  if layer is CanvasLayer:
   for child in layer.get_children():
    if child is Label and child.text.begins_with("197 "):
     child.text=child.text.replace("路灯/站台[原朝向]","路灯/站台[竖直]") if on else child.text.replace("路灯/站台[竖直]","路灯/站台[原朝向]")
func _ready() -> void:
 await super._ready()
 # Return props from the 196 upright experiment to their authored display.
 set_upright196(false)
 for layer in get_children():
  if layer is CanvasLayer:
   for child in layer.get_children():
    if child is Label and child.text.begins_with("196 "):
     child.text="197 主角[朝向相机] · F1切回192身形\nF2 路灯/站台[原朝向] · F6入口 / F7小屋\nF8样板 / F9吊床 / F3小院 / F11小径\nF10调色 / F12灯光"
func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F1:
  hero.set_camera_facing197(not hero.camera_facing197)
  for layer in get_children():
   if layer is CanvasLayer:
    for child in layer.get_children():
     if child is Label and child.text.begins_with("197 "):
      child.text=child.text.replace("主角[朝向相机]","主角[192竖直]") if not hero.camera_facing197 else child.text.replace("主角[192竖直]","主角[朝向相机]")
  get_viewport().set_input_as_handled();return
 super._input(event)
