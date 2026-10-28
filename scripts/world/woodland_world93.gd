extends "res://scripts/world/woodland_world92.gd"
var woodland_ready93 := false
var fingers93: Array[Vector2]=[]

func _forest_script87() -> Script: return preload("res://scripts/art/forest_props93.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 93 · 林缘内伸 / 相连林隙")

func _support93(at: Vector2) -> bool:
	if meadow.route_distance(at)<2.8 or meadow.normal_at(at.x,at.y,true).y<.96: return false
	var low := INF;var high := -INF
	for offset in [Vector2.ZERO,Vector2(-.8,0),Vector2(.8,0),Vector2(0,1.)]:
		var h: float=floor_height(at+offset);low=minf(low,h);high=maxf(high,h)
	return high-low<.3

func _build_woodland() -> void:
	super._build_woodland()
	var g: Vector2=meadow.landmarks.grove
	# Two staggered fingers grow out of the existing edge. The central spawn
	# area and the signed routes stay open; these are not scattered islands.
	for offset in [Vector2(-19,9),Vector2(-16,5),Vector2(-12,1),Vector2(-8,-2),Vector2(20,-9),Vector2(16,-9),Vector2(12,-9.5),Vector2(8,-9)]:
		var at: Vector2=g+offset
		if not _support93(at):
			print("FINGER93_OMIT ",offset," road=",meadow.route_distance(at));continue
		var nearby := false
		for tree in trees:
			if Vector2(tree.root.position.x,tree.root.position.z).distance_to(at)<1.8: nearby=true;break
		if nearby: continue
		_add_route_tree(at,5.8+sin(float(fingers93.size())*2.)*.65)
		trees[-1].root.set_meta("finger93",true);fingers93.append(at)

func _grass_growth92(at: Vector2) -> float:
	var growth := super._grass_growth92(at)
	var g: Vector2=meadow.landmarks.grove
	for spec in [Vector4(-17,6,6,5),Vector4(-10,0,5,4),Vector4(14,-9,9,3.5)]:
		var d := ((at-g-Vector2(spec.x,spec.y))/Vector2(spec.z,spec.w)).length()
		var fringe := 1.-smoothstep(.45,1.1,d)
		growth=lerpf(growth,1.65,fringe*smoothstep(1.2,2.8,meadow.route_distance(at)))
	return growth

func _ready() -> void:
	super._ready()
	while not woodland_ready92: await get_tree().physics_frame
	woodland_ready93=true;_title35()
	print("WOODLAND93_READY finger_trees=",fingers93.size())
