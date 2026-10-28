extends "res://scripts/world/terrace_world90.gd"
var rocks91: Node3D
var stone_ready91 := false
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 91 · 净草地 / 独立石质断面 · Ctrl+Alt+K对照")
func _time_script() -> Script: return preload("res://scripts/world/stone_time91.gd")
func _rock_surfaces_script91() -> Script: return preload("res://scripts/art/rock_surfaces91.gd")

func _assign_ground_materials() -> void:
	# Material / terrain debug switches must not lose the separated side faces.
	var installed := is_instance_valid(rocks91)
	var enabled: bool=rocks91.active91 if installed else true
	if installed and ground.mesh==rocks91.clean91: ground.mesh=rocks91.original91
	super._assign_ground_materials()
	if installed:
		rocks91.free()
		rocks91=_rock_surfaces_script91().new();rocks91.world=self;add_child(rocks91)
		rocks91.set_enabled91(enabled)

func _ready() -> void:
	super._ready()
	while not terrace_ready90: await get_tree().physics_frame
	rocks91=_rock_surfaces_script91().new();rocks91.world=self;add_child(rocks91)
	stone_ready91=true;_title35();time55.update_guide()
	print("STONE91_READY")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed and event.physical_keycode==KEY_K and is_instance_valid(rocks91):
		rocks91.set_enabled91(not rocks91.active91);time55.update_guide();return
	super._unhandled_input(event)
