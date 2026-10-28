extends "res://scripts/world/world26.gd"
var aim_guide_mode := 0 # 0 muzzle trajectory, 1 old ground indicator, 2 none.
var precision_shots := true

func _ready() -> void:
	super._ready()
	while not is_instance_valid(trail_batch): await get_tree().physics_frame
	var previous: Node3D = reticle
	remove_child(previous)
	previous.queue_free()
	reticle = preload("res://scripts/combat/muzzle_reticle28.gd").new()
	reticle.battle = self
	add_child(reticle)
	reticle.update_target(aim_at_screen(get_viewport().get_mouse_position()))
	print("WORLD28_MUZZLE_GUIDE_READY")

func weapon_spread_radians() -> float:
	return 0. if precision_shots else super.weapon_spread_radians()

func preview_projectile_origin() -> Vector3:
	# Match the visible, interpolated goose rather than the hero or a fixed offset.
	if not is_instance_valid(goose): return projectile_origin()
	return goose.visual.get_global_transform_interpolated()*Vector3(.108 if goose.visual.flip_h else -.108,.416,0)

func _process(delta: float) -> void:
	super._process(delta)
	if is_instance_valid(perf_label):
		var caption := " · E %s · Z %s"%[["枪口线","地影","无辅助线"][aim_guide_mode],"精确直射" if precision_shots else "原散布"]
		if not perf_label.text.ends_with(caption):
			perf_label.text = perf_label.text.get_slice(" · E ",0)+caption

func _status() -> void:
	super._status()
	if world_ready:
		label.text = label.text.replace("连续世界26","连续世界28")
		if aim_guide_mode==0: label.text=label.text.replace("世界悬浮准星＋地影","世界悬浮准星＋枪口线")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode==KEY_E:
			aim_guide_mode = (aim_guide_mode+1)%3
			return
		if event.physical_keycode==KEY_Z:
			precision_shots = not precision_shots
			return
	super._unhandled_input(event)
