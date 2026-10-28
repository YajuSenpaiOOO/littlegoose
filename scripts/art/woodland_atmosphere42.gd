extends "res://scripts/art/woodland_atmosphere41.gd"
var decor: Node3D

func _ready() -> void:
	# Keep Compatibility; the user prioritizes the hardware range of players.
	shafts_enabled=false
	super._ready()
	name="WoodlandDecor42"
	flowers.hide()
	for beam in shafts.get_children():
		beam.material_override.shader=preload("res://scripts/art/soft_shaft42.gdshader")
		beam.material_override.set_shader_parameter("strength",.17)
		var arrays: Array=beam.mesh.surface_get_arrays(0)
		var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
		var uv: PackedVector2Array=arrays[Mesh.ARRAY_TEX_UV]
		for i in vertices.size(): vertices[i].x+=(uv[i].x-.5)*lerpf(.6,1.8,uv[i].y)
		arrays[Mesh.ARRAY_VERTEX]=vertices
		var mesh := ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		beam.mesh=mesh
	focus_material.shader=preload("res://scripts/art/scenic_focus42.gdshader")
	decor=_decor_script().new()
	decor.world=world
	add_child(decor)
	decor.set_enabled(enabled)
	print("DECOR42_READY renderer=",RenderingServer.get_current_rendering_method())

func _decor_script() -> Script:
	return preload("res://scripts/art/decorations42.gd")

func set_enabled(value: bool) -> void:
	super.set_enabled(value)
	flowers.hide()
	if is_instance_valid(decor): decor.set_enabled(value)
