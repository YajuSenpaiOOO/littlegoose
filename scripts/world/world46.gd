extends "res://scripts/world/world45.gd"
var woodland_life: Node3D

func _rebuild_root_pieces() -> void:
	super._rebuild_root_pieces()
	if is_instance_valid(woodland_life): woodland_life.rebind_trees()

func _ready() -> void:
	super._ready()
	while not is_instance_valid(garden): await get_tree().physics_frame
	woodland_life=_life_script().new()
	woodland_life.world=self
	add_child(woodland_life)
	_update_tree_blending()
	_title35()
	print("WORLD46_LIVING_WOODLAND_READY")

func _life_script() -> Script:
	return preload("res://scripts/art/woodland_life46.gd")

func _update_tree_blending() -> void:
	if not is_instance_valid(woodland_life):
		super._update_tree_blending()
		return
	for piece in root_pieces:
		var fade: float=piece.sprite.material_override.get_shader_parameter("fade")
		var is_tree: bool=woodland_life.tree_ids.has(piece.sprite.get_instance_id())
		var shader: Shader
		if is_tree:
			shader=preload("res://scripts/art/forest_wind_fade46.gdshader") if fade<.999 else preload("res://scripts/art/forest_wind46.gdshader")
		else:
			shader=preload("res://scripts/art/world_tree19.gdshader") if fade<.999 else preload("res://scripts/art/forest_cutout17.gdshader")
		if piece.sprite.material_override.shader!=shader: piece.sprite.material_override.shader=shader
		if piece.node.material_override.shader!=shader: piece.node.material_override.shader=shader

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 林间生活46 · Ctrl+B 树冠 / Ctrl+K 落叶 / Ctrl+L 小灯")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and is_instance_valid(woodland_life):
		if event.physical_keycode==KEY_B:
			woodland_life.set_wind(not woodland_life.wind_enabled)
			return
		if event.physical_keycode==KEY_K:
			woodland_life.set_leaves(not woodland_life.leaves_enabled)
			return
		if event.physical_keycode==KEY_L:
			woodland_life.set_lantern(not woodland_life.lantern_enabled)
			return
	super._unhandled_input(event)

func _status() -> void:
	super._status()
	if world_ready:
		label.text=label.text.replace("连续世界45","连续世界46")
		label.text=label.text.replace("\nCtrl+T 材质：原版 → 手绘木纹 → 木纹＋石面 · Ctrl+H 新增摆件影 · Ctrl+F3 菜园","\nCtrl+B/K/L 树冠/落叶/小灯 · Ctrl+T 材质 · Ctrl+F3 菜园")
