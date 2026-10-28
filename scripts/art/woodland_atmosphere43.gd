extends "res://scripts/art/woodland_atmosphere42.gd"
var focus_level := 2
var grass_originals: Array[Dictionary]=[]
var grass_ready := false
var tall_count := 0

func _decor_script() -> Script:
	return preload("res://scripts/art/decorations43.gd")

func _ready() -> void:
	super._ready()
	focus_material.shader=preload("res://scripts/art/scenic_focus43.gdshader")
	_set_focus_level(2)
	_prepare_grass()
	_apply_grass(enabled)
	print("VEGETATION43_READY tall_grass=",tall_count)

func _prepare_grass() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed=430043
	for batch in world.grass_batches:
		var node: MultiMeshInstance3D=batch.node
		for i in batch.points.size():
			var original: Transform3D=batch.points[i]
			var at := Vector2(original.origin.x,original.origin.z)
			# First authored corridor only. Other areas keep the accepted baseline.
			if at.x< -14. or at.x>12. or at.y< -28. or at.y>5.: continue
			var d: float=world.meadow.route_distance(at)
			if d<1.15: continue
			var color: Color=node.multimesh.get_instance_custom_data(i)
			var patch: float=.5+.5*sin(at.x*.73+sin(at.y*.39)*1.4)*cos(at.y*.52)
			var chance: float=lerpf(.10,.66,smoothstep(.30,.8,patch))
			var tall := rng.randf()<chance
			var transform: Transform3D=node.multimesh.get_instance_transform(i)
			var high := transform
			var point_high := original
			if tall:
				var growth := rng.randf_range(1.45,1.9)
				high.basis.y*=growth
				point_high.basis.y*=growth
				tall_count+=1
			var high_color := color
			high_color.b=1. if tall else 0.
			grass_originals.append({"batch":batch,"index":i,"before":transform,"after":high,"point_before":original,"point_after":point_high,"color_before":color,"color_after":high_color})
	grass_ready=true

func _apply_grass(value: bool) -> void:
	if not grass_ready: return
	for entry in grass_originals:
		var multi: MultiMesh=entry.batch.node.multimesh
		multi.set_instance_transform(entry.index,entry.after if value else entry.before)
		multi.set_instance_custom_data(entry.index,entry.color_after if value else entry.color_before)
		entry.batch.points[entry.index]=entry.point_after if value else entry.point_before

func set_enabled(value: bool) -> void:
	super.set_enabled(value)
	_apply_grass(value)

func _set_focus_level(value: int) -> void:
	focus_level=clampi(value,0,3)
	focus_enabled=focus_level>0
	focus_material.set_shader_parameter("radius_pixels",[0.,3.4,6.2,9.][focus_level])
	focus_card.visible=enabled and focus_enabled
	world._title35()

func toggle_focus() -> void:
	_set_focus_level((focus_level+1)%4)

func _process(delta: float) -> void:
	super._process(delta)
	if is_instance_valid(focus_material):
		focus_material.set_shader_parameter("clear_span",7.5 if world.wave_state=="fighting" else 2.8)
