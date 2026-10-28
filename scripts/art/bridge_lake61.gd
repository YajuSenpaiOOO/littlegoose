extends "res://scripts/art/bridge_lake60.gd"
var distant_glow := true

func _water_shader() -> Shader:
	return preload("res://scripts/art/lake61.gdshader")

func _ready() -> void:
	super._ready()
	name="StorybookLake61"
	set_distant_glow(true)
	_process(0.)

func set_distant_glow(enabled: bool) -> void:
	distant_glow=enabled
	world.water_material19.set_shader_parameter("distant_glow61",enabled)

func _process(delta: float) -> void:
	super._process(delta)
	if not is_instance_valid(world.hero) or not is_instance_valid(world.camera): return
	var view_point: Vector3=world.camera.global_transform.affine_inverse()*(world.hero.global_position+Vector3.UP*.7)
	world.water_material19.set_shader_parameter("focus61",-view_point.z)
