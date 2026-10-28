extends "res://scripts/world/world79.gd"
var ground_style80 := 0
const GROUND_NAMES80 := ["苔草过渡","浅色细砾","薄落叶地"]

func _rail_script72() -> Script: return preload("res://scripts/art/rail_station80.gd")
func _time_script() -> Script: return preload("res://scripts/world/world_time80.gd")
func _earth_clears_grass79() -> bool: return false

func stair_cuts80() -> PackedVector4Array:
	var foot: Vector2=meadow.stair_start73()
	return PackedVector4Array([Vector4(foot.x-2.249,foot.y-meadow.station_stair_run74()+.001,foot.x+2.249,foot.y-.001),Vector4(meadow.SIDE_TOP75.x+.001,meadow.SIDE_FOOT75.y-1.149,meadow.SIDE_FOOT75.x-.001,meadow.SIDE_FOOT75.y+1.149)])

func _assign_ground_materials() -> void:
	super._assign_ground_materials()
	var shader := preload("res://scripts/art/world_ground80.gdshader")
	for material in ground_materials:
		material.shader=shader;material.set_shader_parameter("stair_cuts80",stair_cuts80())
		material.set_shader_parameter("cut_stairs80",true)
		material.set_shader_parameter("cover_style80",ground_style80)
		if is_instance_valid(porch49): porch49.shade_material(material,shader)

func set_ground_style80(value: int) -> void:
	ground_style80=clampi(value,0,2)
	for material in ground_materials: material.set_shader_parameter("cover_style80",ground_style80)
	if is_instance_valid(time55): time55.update_guide()
	_title35()

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 石阶80 · 连续阶梯 / 地表："+GROUND_NAMES80[ground_style80])

func _ready() -> void:
	super._ready()
	while not is_instance_valid(accents79): await get_tree().physics_frame
	print("WORLD80_CLOSED_STAIRS_AND_CLEAN_GROUND_READY")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed and event.physical_keycode in [KEY_1,KEY_2,KEY_3]:
		set_ground_style80(event.physical_keycode-KEY_1);return
	super._unhandled_input(event)
