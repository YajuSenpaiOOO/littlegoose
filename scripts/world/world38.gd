extends "res://scripts/world/world37.gd"
const EXPLORATION_ZOOM := 2.2

func _base_zoom_delta() -> float:
	# Keep the approved fighting frame, including breathers and the result.
	# Only free exploration uses the closer portrait-like framing.
	var in_encounter := wave_state in ["fighting","defeated"] or (wave_state=="cleared" and not result_dismissed)
	return LEGACY_BATTLE_ZOOM if in_encounter else EXPLORATION_ZOOM

func _preserve_framing_on_reset() -> bool:
	return true

func _reset_impact_state() -> void:
	var preserve: bool=_preserve_framing_on_reset() and feel_ready and is_instance_valid(camera)
	var previous_gain: float=camera_gain
	var previous_fov: float=camera.fov if is_instance_valid(camera) else 42.
	super._reset_impact_state()
	# Round resets still clear effects, but must not briefly flash out to the
	# old wide baseline before blending into the new framing.
	if preserve:
		camera_gain=previous_gain
		camera.fov=previous_fov

func _ready() -> void:
	super._ready()
	while not encounter37_ready: await get_tree().physics_frame
	_title35()
	print("WORLD38_EXPLORATION_CAMERA_READY")

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 林地遭遇38 · 探索近景 / 战斗全景 · F5 重试")

func _status() -> void:
	super._status()
	if world_ready: label.text=label.text.replace("连续世界37","连续世界38")
