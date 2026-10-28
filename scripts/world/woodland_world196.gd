extends "res://scripts/world/woodland_world195.gd"
var upright196 := false
var angle_cards196: Array[Dictionary]=[]
func _init() -> void:
 super._init();memory_save116="user://forest196_preview.cfg"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 196 · 竖直摆件对照 / 近景提前清场")
func _whole_fade_script67() -> Script: return preload("res://scripts/art/whole_tree_fade196.gd")
func _ready() -> void:
 await super._ready()
 for prop in forest188.props181:
  if prop.texture==preload("res://assets/forest188/post_top_nightlight_pixel.png"):
   angle_cards196.append({"node":prop,"billboard":prop.billboard,"rotation":prop.rotation})
 # Only complete station cards, never the split house/tree ground joins.
 var stations := find_children("*","Node3D",true,false)
 for node in stations:
  if node.get_script()!=null and "station_kit" in node.get_script().resource_path and node.get("visuals81")!=null:
   for visual in node.visuals81:
    angle_cards196.append({"node":visual,"billboard":visual.billboard,"rotation":visual.rotation})
 set_upright196(true)
 for layer in get_children():
  if layer is CanvasLayer:
   for child in layer.get_children():
    if child is Label and child.text.begins_with("195 "):
     child.text=child.text.replace("195 稳定前景 / 提前林荫退让","196 路灯/站台[竖直] · F2切换\n近相机树冠提前清场")
func set_upright196(on: bool) -> void:
 upright196=on
 for record in angle_cards196:
  record.node.billboard=BaseMaterial3D.BILLBOARD_DISABLED if on else record.billboard
  record.node.rotation=Vector3(0,record.rotation.y,record.rotation.z) if on else record.rotation
 for layer in get_children():
  if layer is CanvasLayer:
   for child in layer.get_children():
    if child is Label and child.text.begins_with("196 "):
     child.text=child.text.replace("[竖直]","[原朝向]") if not on else child.text.replace("[原朝向]","[竖直]")
func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F2:
  set_upright196(not upright196);get_viewport().set_input_as_handled();return
 super._input(event)
