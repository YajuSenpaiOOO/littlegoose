extends "res://scripts/world/world48.gd"
var porch49: Node3D

func _ready() -> void:
	super._ready()
	while not is_instance_valid(lighting47): await get_tree().physics_frame
	porch49=_porch_script().new()
	porch49.world=self
	add_child(porch49)
	_title35()
	print("WORLD49_PORCH_STUDY_READY")

func _porch_script() -> Script:
	return preload("res://scripts/art/porch_study49.gd")

func _update_tree_blending() -> void:
	if not is_instance_valid(porch49) or not porch49.is_node_ready():
		super._update_tree_blending()
		return
	for piece in root_pieces:
		var fade: float=piece.sprite.material_override.get_shader_parameter("fade")
		var shader: Shader
		if woodland_life.tree_ids.has(piece.sprite.get_instance_id()):
			shader=preload("res://scripts/art/forest_wind_fade46.gdshader") if fade<.999 else preload("res://scripts/art/forest_wind46.gdshader")
		else:
			shader=preload("res://scripts/art/world_tree19.gdshader") if fade<.999 else preload("res://scripts/art/forest_cutout17.gdshader")
		porch49.shade_material(piece.sprite.material_override,shader)
		porch49.shade_material(piece.node.material_override,shader)

func _title35() -> void:
	var selected := "林荫暖院"
	if is_instance_valid(porch49): selected=porch49.LABELS[porch49.profile]
	DisplayServer.window_set_title("小白鹅 · 暖院样板49 · %s · Ctrl+7 原版 / 8 檐下暗部 / 9 暖院"%selected)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and is_instance_valid(porch49):
		if event.physical_keycode in [KEY_7,KEY_8,KEY_9]:
			porch49.set_profile(event.physical_keycode-KEY_7)
			return
	super._unhandled_input(event)

func _status() -> void:
	super._status()
	if world_ready:
		label.text=label.text.replace("连续世界48","暖院样板49")
		label.text=label.text.replace("Ctrl+7/8/9 原版/层次/层次＋柔光","Ctrl+7/8/9 48原版/檐下暗部/林荫暖院")
