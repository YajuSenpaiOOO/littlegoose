extends "res://scripts/world/world65.gd"
var canopy66: RefCounted
var frames66: CanvasLayer

func _ready() -> void:
	super._ready()
	while not is_instance_valid(landmark62) or not landmark62.is_node_ready(): await get_tree().physics_frame
	canopy66=preload("res://scripts/art/canopy_occlusion66.gd").new()
	canopy66.world=self
	canopy66.reset_fades()
	frames66=preload("res://scripts/world/frame_overlay66.gd").new()
	frames66.world=self
	add_child(frames66)
	perf_label.hide()
	time55.update_guide()
	print("WORLD66_CANOPY_AND_FRAME_MONITOR_READY")

func _time_script() -> Script:
	return preload("res://scripts/world/world_time66.gd")

func _update_forest_occlusion(delta: float) -> void:
	if not is_instance_valid(canopy66) or not canopy66.local_enabled:
		super._update_forest_occlusion(delta)
		return
	canopy66.update(delta)
	# Keep the house's established raycast fade; only tree canopies change here.
	var query := PhysicsRayQueryParameters3D.create(camera.position,hero.position+Vector3.UP*.8,2)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	var blocked: bool=fade_enabled and not hit.is_empty() and hit.collider==cottage_body
	var material: ShaderMaterial=house_art.material_override
	var previous: float=material.get_shader_parameter("fade")
	var next := move_toward(previous,.28 if blocked else 1.,delta*3.)
	if previous!=next: material.set_shader_parameter("fade",next)

func _update_tree_blending() -> void:
	if not is_instance_valid(canopy66) or not canopy66.local_enabled or not is_instance_valid(porch49):
		super._update_tree_blending()
		return
	canopy66.sync_materials()

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 林间视野66 · 局部让开 / 帧率显示")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.ctrl_pressed and is_instance_valid(frames66):
			if event.physical_keycode==KEY_F9:
				frames66.panel.visible=not frames66.panel.visible
				return
			if event.physical_keycode==KEY_F10:
				frames66.clear_samples()
				return
		if event.alt_pressed and event.physical_keycode==KEY_O and is_instance_valid(canopy66):
			canopy66.set_local(not canopy66.local_enabled)
			time55.update_guide()
			return
	super._unhandled_input(event)
