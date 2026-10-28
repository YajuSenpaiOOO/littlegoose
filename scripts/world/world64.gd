extends "res://scripts/world/world63.gd"
var tree_bench64: Dictionary={}

func _ready() -> void:
	super._ready()
	while not is_instance_valid(landmark62) or not landmark62.is_node_ready(): await get_tree().physics_frame
	if not "--combat" in OS.get_cmdline_user_args(): go_roots64()
	time55.update_guide()

func go_roots64() -> void:
	if combat_ready: _leave_encounter()
	landmark62.review_view=false
	_teleport15(meadow.landmarks.junction+Vector2(0,6.2))

func _build_lab_grass() -> void:
	super._build_lab_grass()
	var center: Vector2=meadow.landmarks.junction+Vector2(0,1.1)
	for batch in grass_batches:
		var kept: Array[Transform3D]=[]
		var colors: Array[Color]=[]
		for i in batch.points.size():
			var original: Transform3D=batch.points[i]
			var at := Vector2(original.origin.x,original.origin.z)
			if ((at-center)/Vector2(4.6,3.8)).length()<1.: continue
			kept.append(original)
			colors.append(batch.node.multimesh.get_instance_custom_data(i))
		batch.points=kept
		batch.node.multimesh.instance_count=kept.size()
		for i in kept.size():
			batch.node.multimesh.set_instance_transform(i,kept[i])
			batch.node.multimesh.set_instance_custom_data(i,colors[i])

func _landmark_script() -> Script:
	return preload("res://scripts/art/willow_clearing64.gd")

func _time_script() -> Script:
	return preload("res://scripts/world/world_time64.gd")

func _build_props15() -> void:
	super._build_props15()
	_add_prop15("bench",meadow.landmarks.junction+Vector2(-5.3,4.8),1.05,Vector3(2.1,.8,.65))
	tree_bench64=props15[-1]
	tree_bench64.root.name="WillowRestBench64"

func _limit_prop_shadows() -> void:
	super._limit_prop_shadows()
	if tree_bench64.is_empty() or not is_instance_valid(landmark62): return
	var show_contact: bool=landmark62.understory_enabled and contact_enabled and props_enabled
	for foot in contact_marks:
		if foot.prop.root==tree_bench64.root: foot.mark.visible=show_contact

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 银柳树下64 · Alt+J 树下小景 · Alt+Y 根部接地对照")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.physical_keycode==KEY_F8 and is_instance_valid(landmark62):
		go_roots64()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.alt_pressed and is_instance_valid(landmark62):
		if event.physical_keycode==KEY_J:
			landmark62.set_understory(not landmark62.understory_enabled)
			time55.update_guide()
			return
		if event.physical_keycode==KEY_Y:
			landmark62.set_seated_roots(not landmark62.seated_roots)
			time55.update_guide()
			return
	super._unhandled_input(event)
