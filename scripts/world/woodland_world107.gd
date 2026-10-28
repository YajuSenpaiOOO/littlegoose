extends "res://scripts/world/woodland_world106.gd"
var woodland_ready107 := false
var layers107: Node3D
func _build_lab_floor() -> void:
 super._build_lab_floor();meadow=preload("res://scripts/world/world_surface107.gd").new()
func _lamps_script106() -> Script: return preload("res://scripts/art/woodland_lamps107.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time107.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 107 · 木枝挂灯 / 林下草带")
func _grass_growth92(at: Vector2) -> float:
 var grow := super._grass_growth92(at)
 var p: Vector2=at-Vector2(meadow.landmarks.grove)
 if p.length()>21. or PARK99.on_stairs99(p) or p.distance_to(PARK99.DECK)<2.9: return grow
 var path := PARK99.path_distance99(p)
 # Restore upright tufts away from the actual worn tread. Preserve the paths.
 var edge := smoothstep(.95,1.9,path)
 return maxf(grow,lerpf(.25,.85,edge))
func _ready() -> void:
 super._ready()
 while not woodland_ready106: await get_tree().physics_frame
 layers107=preload("res://scripts/art/woodland_layers107.gd").new();layers107.world=self;add_child(layers107)
 woodland_ready107=true;_title35();time55.update_guide()
 print("WOODLAND107_READY grass=",layers107.grass_count107," ferns=",layers107.fern_count107," batches=",layers107.batches107.size())
func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed and event.physical_keycode==KEY_F8:
  if is_instance_valid(layers107): layers107.visible=not layers107.visible
  return
 super._unhandled_input(event)
