extends "res://scripts/art/bridge_lake61.gd"

func _ready() -> void:
	super._ready()
	# Water mood exploration is parked; preserve the chosen paint and lowered level.
	set_motion(false)
	set_sparkles(false)
	set_distant_glow(false)
	world.water_material19.set_shader_parameter("frozen60",0.)
