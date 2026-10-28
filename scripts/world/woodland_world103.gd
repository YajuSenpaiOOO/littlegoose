extends "res://scripts/world/woodland_world102.gd"
const ENTRY103=preload("res://scripts/world/park_layout103.gd")
var woodland_ready103 := false
var entrance_trees103 := 0
func _forest_script87() -> Script: return preload("res://scripts/art/forest_props103.gd")
func _rock_surfaces_script91() -> Script: return preload("res://scripts/art/rock_surfaces103.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time103.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 103 · 林缘入口 / 踩草过渡 / 手绘细土径")
func _build_lab_floor() -> void:
 super._build_lab_floor();meadow=preload("res://scripts/world/world_surface103.gd").new()
func _build_woodland() -> void:
 super._build_woodland()
 var g: Vector2=meadow.landmarks.grove
 for offset in [Vector2(13.8,17.1),Vector2(23.4,5.5),Vector2(26.,17.0)]:
  var at: Vector2=g+offset;var nearby := false
  for tree in trees:
   if Vector2(tree.root.position.x,tree.root.position.z).distance_to(at)<2.3: nearby=true;break
  if not nearby:
   _add_route_tree(at,6.7);trees[-1].root.set_meta("entrance103",true);entrance_trees103+=1
func _grass_growth92(at: Vector2) -> float:
 var grow := super._grass_growth92(at)
 if meadow==null or meadow.landmarks.is_empty(): return grow
 var p: Vector2=at-Vector2(meadow.landmarks.grove)
 var entry := ENTRY103.corridor103(p)
 var worn := (1.-smoothstep(.9,2.2,entry.x))*smoothstep(.0,.12,entry.y)*(1.-smoothstep(.85,1.,entry.y))
 grow=lerpf(grow,.25,worn*.82)
 if ENTRY103.lift103(p)>.035: grow=maxf(grow,1.15)
 return grow
func _ready() -> void:
 super._ready()
 while not woodland_ready102: await get_tree().physics_frame
 woodland_ready103=true;_title35();time55.update_guide();print("WOODLAND103_READY entrance_trees=",entrance_trees103)
func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed and event.physical_keycode==KEY_F6:
  set_review72(false);_teleport15(meadow.landmarks.grove+Vector2(17.,10.5));return
 super._unhandled_input(event)
