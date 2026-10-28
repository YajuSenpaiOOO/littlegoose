extends "res://scripts/art/night_accents57.gd"

func _cone_radius() -> float: return 2.5

func _ready() -> void:
	super._ready()
	stage_light.position=Vector3(0,6.,.3)
	stage_emitter.bind(preload("res://assets/lighting55/stage58.tres"),stage_light,stage_beam.material_override,&"strength57")
	stage_beam.hide()
	update_accents(0.)

func update_accents(delta: float) -> void:
	super.update_accents(delta)
	if not is_instance_valid(stage_beam): return
	# Replace the intersecting flat card with a depth-clipped cone integrated in
	# the existing postprocess. The invisible old mesh adds no drawing pass.
	stage_beam.hide()
	var focus: ShaderMaterial=world.atmosphere41.focus_material
	focus.set_shader_parameter("cone_strength58",strength if stage_enabled else 0.)
	if not stage_enabled or strength<.001: return
	var top: Vector3=stage_light.global_position
	var bottom: Vector3=global_position+Vector3.UP*.06
	focus.set_shader_parameter("cone_top58",top)
	focus.set_shader_parameter("cone_bottom58",bottom)
	var low := Vector2(1000.,1000.)
	var high := Vector2(-1000.,-1000.)
	var view_size: Vector2=world.get_viewport().get_visible_rect().size
	var bound := _cone_radius()
	for y in [top.y,bottom.y]:
		for x in [-bound,bound]:
			for z in [-bound,bound]:
				var point := Vector3(bottom.x+x,y,bottom.z+z)
				var screen: Vector2=world.camera.unproject_position(point)/view_size
				low=low.min(screen)
				high=high.max(screen)
	focus.set_shader_parameter("cone_bounds58",Vector4(low.x,low.y,high.x,high.y))
