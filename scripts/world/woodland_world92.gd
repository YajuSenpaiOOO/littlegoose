extends "res://scripts/world/stone_world91.gd"
var composition_trees92 := 0
var woodland_ready92 := false
var grass_changed92 := 0
var grass_poses92: Array[Dictionary]=[]
var grass_layout92 := true

func _build_lab_floor() -> void:
	super._build_lab_floor()
	meadow=preload("res://scripts/world/world_surface92.gd").new()

func _rock_surfaces_script91() -> Script: return preload("res://scripts/art/rock_surfaces92.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time92.gd")
func _forest_script87() -> Script: return preload("res://scripts/art/forest_props92.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 92 · 林缘开合 / 草势层次 / 手绘岩面")

func _tree_support92(at: Vector2) -> bool:
	var g: Vector2=meadow.landmarks.grove
	if ((at-g)/Vector2(20.,15.)).length()<1.12 or meadow.route_distance(at)<3.1: return false
	if not meadow.world_bounds.grow(-1.5).has_point(at) or meadow.normal_at(at.x,at.y,true).y<.96: return false
	var low := INF;var high := -INF
	for offset in [Vector2.ZERO,Vector2(-1.,0),Vector2(1.,0),Vector2(0,1.8)]:
		var h: float=meadow.height_at(at.x+offset.x,at.y+offset.y,true);low=minf(low,h);high=maxf(high,h)
	return high-low<.32

func _build_woodland() -> void:
	super._build_woodland()
	var g: Vector2=meadow.landmarks.grove
	var assigned: Dictionary={}
	for offset in [Vector2(9.,16.),Vector2(24.,7.),Vector2(-21.,10.),Vector2(-20.,-11.),Vector2(22.,-5.),Vector2(20.,-12.)]:
		var at: Vector2=g+offset
		if not _tree_support92(at): continue
		var chosen: Dictionary={};var distance := 7.5
		for tree in trees:
			if assigned.has(tree.root.get_instance_id()) or tree.root==landmark_tree.root: continue
			var d := Vector2(tree.root.position.x,tree.root.position.z).distance_to(at)
			if d<distance: chosen=tree;distance=d
		if chosen.is_empty():
			_add_route_tree(at,6.0+composition_trees92*.13);chosen=trees[-1]
		else: chosen.root.position=Vector3(at.x,meadow.height_at(at.x,at.y,true),at.y)
		chosen.root.set_meta("composition92",true);assigned[chosen.root.get_instance_id()]=true
		composition_trees92+=1

func _grass_growth92(at: Vector2) -> float:
	var g: Vector2=meadow.landmarks.grove
	var pockets := 0.
	for spec in [Vector4(-14.,8.,7.,4.2),Vector4(12.,-8.,6.5,5.),Vector4(4.,13.,8.,3.2)]:
		var d := ((at-g-Vector2(spec.x,spec.y))/Vector2(spec.z,spec.w)).length()
		pockets=maxf(pockets,1.-smoothstep(.3,1.,d))
	var lane := 1.-smoothstep(1.3,2.8,meadow.route_distance(at))
	return lerpf(.38,1.5,pockets)*(1.-lane*.55)

func _refresh_planting() -> void:
	super._refresh_planting()
	grass_poses92.clear();grass_changed92=0
	var g: Vector2=meadow.landmarks.grove
	for batch in grass_batches:
		for i in batch.points.size():
			var at3: Vector3=batch.points[i].origin
			var at := Vector2(at3.x,at3.z)
			var radius := ((at-g)/Vector2(23.,18.)).length()
			if radius>1.15: continue
			var before: Transform3D=batch.node.multimesh.get_instance_transform(i)
			var after := before
			var grow := lerpf(_grass_growth92(at),1.,smoothstep(.88,1.15,radius))
			after.basis.y*=grow
			var scatter := fposmod(sin(at.x*127.1+at.y*311.7)*43758.5,1.)
			if grow<.65 and scatter<.55: after.basis=after.basis.scaled(Vector3.ZERO)
			grass_poses92.append({"node":batch.node,"index":i,"before":before,"after":after})
			batch.node.multimesh.set_instance_transform(i,after if grass_layout92 else before)
			grass_changed92+=1

func set_grass_layout92(value: bool) -> void:
	grass_layout92=value
	for item in grass_poses92: item.node.multimesh.set_instance_transform(item.index,item.after if value else item.before)

func _ready() -> void:
	super._ready()
	while not stone_ready91: await get_tree().physics_frame
	woodland_ready92=true;time55.update_guide();_title35()
	print("WOODLAND92_READY tree_groups=",composition_trees92," grass_instances=",grass_changed92)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed:
		if event.physical_keycode==KEY_M: set_grass_layout92(not grass_layout92);return
		if event.physical_keycode==KEY_F1:
			time55.expanded92=not time55.expanded92;time55.update_guide();return
	super._unhandled_input(event)
