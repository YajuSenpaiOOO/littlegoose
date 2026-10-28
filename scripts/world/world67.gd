extends "res://scripts/world/world65.gd"
var whole67: RefCounted
var frames66: CanvasLayer
var roots67: Dictionary={}
var root_revision67 := 0
var bound_revision67 := -1

func _frame_overlay_script67() -> Script: return preload("res://scripts/world/frame_overlay67.gd")

func _whole_fade_script67() -> Script:
	return preload("res://scripts/art/whole_tree_fade67.gd")

func _ready() -> void:
	super._ready()
	while not is_instance_valid(landmark62) or not landmark62.is_node_ready(): await get_tree().physics_frame
	whole67=_whole_fade_script67().new()
	whole67.world=self
	whole67.prepare()
	frames66=_frame_overlay_script67().new()
	frames66.world=self
	add_child(frames66)
	perf_label.hide()
	time55.update_guide()
	print("WORLD67_WHOLE_TREE_FADE_READY")

func _time_script() -> Script:
	return preload("res://scripts/world/world_time67.gd")

func _porch_script() -> Script:
	return preload("res://scripts/art/day_fill67.gd")

func _update_forest_occlusion(delta: float) -> void:
	if not is_instance_valid(whole67) or not whole67.improved:
		super._update_forest_occlusion(delta)
		return
	whole67.update(delta)
	var query := PhysicsRayQueryParameters3D.create(camera.position,hero.position+Vector3.UP*.8,2)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	var blocked: bool=fade_enabled and not hit.is_empty() and hit.collider==cottage_body
	var material: ShaderMaterial=house_art.material_override
	var previous: float=material.get_shader_parameter("fade")
	var next := move_toward(previous,.28 if blocked else 1.,delta*3.)
	if previous!=next: material.set_shader_parameter("fade",next)

func _rebuild_root_pieces() -> void:
	super._rebuild_root_pieces()
	root_revision67+=1
	if is_instance_valid(whole67): whole67.shader_dirty67=true

func _sync_root_fades15() -> void:
	if not is_instance_valid(whole67) or not whole67.improved:
		super._sync_root_fades15()
		return
	if bound_revision67!=root_revision67:
		roots67.clear()
		for piece in root_pieces:
			roots67[piece.sprite.get_instance_id()]=piece.node.material_override
			piece.node.material_override.set_shader_parameter("fade",piece.sprite.material_override.get_shader_parameter("fade"))
		bound_revision67=root_revision67
	for key in whole67.changed67:
		if roots67.has(key): roots67[key].set_shader_parameter("fade",whole67.entries[key].sprite.material_override.get_shader_parameter("fade"))

func _update_tree_blending() -> void:
	if not is_instance_valid(whole67) or not whole67.improved:
		super._update_tree_blending()
		return
	if whole67.shader_dirty67:
		super._update_tree_blending()
		whole67.shader_dirty67=false

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 林荫让路67 · 整树隐去 / 性能诊断")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.ctrl_pressed and is_instance_valid(frames66):
			if event.physical_keycode==KEY_F9:
				frames66.panel.visible=not frames66.panel.visible
				return
			if event.physical_keycode==KEY_F10:
				frames66.clear_samples()
				return
			if event.physical_keycode==KEY_F11:
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if DisplayServer.window_get_vsync_mode()==DisplayServer.VSYNC_DISABLED else DisplayServer.VSYNC_DISABLED)
				frames66.clear_samples()
				return
		if event.alt_pressed and event.physical_keycode==KEY_O and is_instance_valid(whole67):
			whole67.set_improved(not whole67.improved)
			time55.update_guide()
			return
	super._unhandled_input(event)
