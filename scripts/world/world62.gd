extends "res://scripts/world/world61.gd"
var landmark62: Node3D
var old_sign62: Array[Node3D]=[]

func _bridge_script() -> Script:
	return preload("res://scripts/art/bridge_lake62.gd")

func _time_script() -> Script:
	return preload("res://scripts/world/world_time62.gd")

func _landmark_script() -> Script:
	return preload("res://scripts/art/landmark_studies62.gd")

func _build_wayfinding() -> void:
	var before := get_child_count()
	super._build_wayfinding()
	var at := _junction_sign_position()
	for i in range(before,get_child_count()):
		var child := get_child(i)
		if (child is MeshInstance3D or child is Label3D) and Vector2(child.position.x,child.position.z).distance_to(at)<1.:
			old_sign62.append(child)

func _ready() -> void:
	super._ready()
	while not is_instance_valid(bridge59) or not bridge59.is_node_ready(): await get_tree().physics_frame
	landmark62=_landmark_script().new()
	landmark62.world=self
	add_child(landmark62)
	if not "--combat" in OS.get_cmdline_user_args(): go_tree62()
	time55.update_guide()
	_title35()
	print("WORLD62_GREAT_TREE_AND_PAINTED_SIGN_READY")

func go_tree62() -> void:
	if combat_ready: _leave_encounter()
	_teleport15(meadow.landmarks.junction+Vector2(0,8.5))
	if is_instance_valid(landmark62): landmark62.start_review()

func go_sign62() -> void:
	if combat_ready: _leave_encounter()
	if is_instance_valid(landmark62): landmark62.review_view=false
	_teleport15(_junction_sign_position()+Vector2(0,2.8))

func _title35() -> void:
	var selected := "三版古树"
	if is_instance_valid(landmark62): selected=landmark62.LABELS[landmark62.variant] if not landmark62.old_tree else "旧占位树"
	DisplayServer.window_set_title("小白鹅 · 世界树62 · %s · Alt+5/6/7 古树 · Alt+N 路牌"%selected)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and is_instance_valid(landmark62):
		if event.alt_pressed and event.physical_keycode in [KEY_5,KEY_6,KEY_7]:
			landmark62.set_tree(event.physical_keycode-KEY_5)
			time55.update_guide()
			return
		if event.alt_pressed and event.physical_keycode==KEY_8:
			landmark62.set_old_tree(not landmark62.old_tree)
			time55.update_guide()
			return
		if event.alt_pressed and event.physical_keycode==KEY_N:
			landmark62.set_sign(not landmark62.painted_sign)
			time55.update_guide()
			return
		if event.ctrl_pressed and event.physical_keycode==KEY_F5:
			go_tree62()
			return
		if event.ctrl_pressed and event.physical_keycode==KEY_F7:
			go_sign62()
			return
	super._unhandled_input(event)
