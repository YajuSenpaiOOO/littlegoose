extends "res://scripts/world/woodland_world96.gd"
const PARK99=preload("res://scripts/world/park_layout99.gd")
var woodland_ready99 := false
var park99: Node3D
var swing_tree99: Dictionary={}
func _swing_root_profile99() -> Dictionary: return {"foot":[1000,1230],"height":1230,"cutoff":.5}
func _park_script99() -> Script: return preload("res://scripts/art/nature_park99.gd")
func _safe_spawn(wanted: Vector2,occupied: Array[Vector2]) -> Vector2:
	var player := Vector2(hero.position.x,hero.position.z)
	var original := super._safe_spawn(wanted,occupied)
	var route: PackedVector2Array=navigation.path(original,player)
	if not route.is_empty() and route[-1].distance_to(player)<1.1: return original
	# A walkable cell on a cliff top can be disconnected from the clearing.
	# Search the player's actual connected component at spawn time only.
	var start: Vector2i=navigation.nearest(player)
	var pending: Array[Vector2i]=[start];var seen := {start:true};var cursor := 0
	var best := original;var score := INF
	while cursor<pending.size():
		var cell: Vector2i=pending[cursor];cursor+=1
		var at: Vector2=navigation.origin+Vector2(cell)*navigation.CELL
		var available := at.distance_to(player)>=3.5
		for other in occupied:
			if at.distance_to(other)<1.2: available=false;break
		if available and at.distance_squared_to(wanted)<score:
			score=at.distance_squared_to(wanted);best=at
		for offset in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next: Vector2i=cell+offset
			if seen.has(next) or not navigation.grid.region.has_point(next) or navigation.grid.is_point_solid(next): continue
			seen[next]=true;pending.append(next)
	return best
func _rebuild_root_pieces() -> void:
	extra_profiles["swing_oak99"]=_swing_root_profile99()
	for tree in trees:
		if tree.visual.has_meta("swing_oak99"): tree.extra_id="swing_oak99"
	super._rebuild_root_pieces()
func _replace_sprite(sprite: Sprite3D,id: String,height: float,pack: Dictionary) -> void:
	if not sprite.has_meta("swing_oak99"):
		super._replace_sprite(sprite,id,height,pack);return
	var texture: Texture2D=preload("res://assets/park99/swing_oak99.png")
	sprite.texture=texture;sprite.pixel_size=8.8/1230.
	sprite.offset=Vector2(texture.get_width()/2.-1000.,1230.-texture.get_height()/2.)
	sprite.material_override.set_shader_parameter("paint",texture)
func _forest_script87() -> Script: return preload("res://scripts/art/forest_props99.gd")
func _rock_surfaces_script91() -> Script: return preload("res://scripts/art/rock_surfaces99.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time99.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 99 · 林间自然游园 / 高崖树林 / 秋千踏桩")
func _build_lab_floor() -> void:
	super._build_lab_floor();meadow=preload("res://scripts/world/world_surface99.gd").new()
func _build_woodland() -> void:
	super._build_woodland()
	var g: Vector2=meadow.landmarks.grove
	for tree in trees:
		var p: Vector2=Vector2(tree.root.position.x,tree.root.position.z)-g
		var target := p
		if tree.root.has_meta("finger93"):
			if p.distance_to(Vector2(-8,-2))<.2: target=Vector2(-5.2,-7.2)
			elif p.distance_to(Vector2(-12,1))<.2: target=Vector2(-11.2,4.8)
			elif p.distance_to(Vector2(8,-9))<.2: target=Vector2(4.5,-8.8)
		if target!=p: tree.root.position=Vector3(g.x+target.x,meadow.height_at(g.x+target.x,g.y+target.y,true),g.y+target.y)
	for offset in [Vector2(-25,-24),Vector2(-25,-15),Vector2(-26,-6),Vector2(-25,3),Vector2(-26,11),Vector2(-22,-29),Vector2(-15,-9),Vector2(-5.2,-7.2),Vector2(-11.2,4.8),Vector2(-10.6,8.6),Vector2(-6.8,10.5),Vector2(4.5,-8.8),Vector2(11.55,-6.6)]:
		var at: Vector2=g+offset
		var near := false
		for tree in trees:
			if Vector2(tree.root.position.x,tree.root.position.z).distance_to(at)<2.: near=true;break
		if not near and meadow.normal_at(at.x,at.y,true).y>.95: _add_route_tree(at,8.3 if offset.x< -20. else 7.8)
	for tree in trees:
		var p := Vector2(tree.root.position.x,tree.root.position.z)-g
		if p.distance_to(Vector2(11.55,-6.6))<.3:
			tree.root.position.x=g.x+11.55
			tree.root.position.z=g.y-4.7
			tree.root.position.y=meadow.height_at(tree.root.position.x,tree.root.position.z,true)
			tree.height=8.8;tree.extra_id="swing_oak99";tree.visual.set_meta("swing_oak99",true)
			extra_profiles["swing_oak99"]=_swing_root_profile99()
			_replace_sprite(tree.visual,"oak",8.8,{})
			swing_tree99=tree;break
func _grass_growth92(at: Vector2) -> float:
	var growth := super._grass_growth92(at)
	var p: Vector2=at-Vector2(meadow.landmarks.grove)
	if PARK99.on_stairs99(p): return 0.
	return lerpf(growth,.04,1.-smoothstep(.75,1.5,PARK99.path_distance99(p)))
func _refresh_planting() -> void:
	super._refresh_planting()
	var g: Vector2=meadow.landmarks.grove
	for item in grass_poses92:
		var point: Vector3=item.node.to_global(item.after.origin)
		var p := Vector2(point.x,point.z)-g
		if PARK99.path_distance99(p)<.94 or PARK99.on_stairs99(p) or (p-PARK99.DECK).length()<2.9:
			item.after.basis=Basis(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO)
			item.before.basis=Basis(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO)
			item.node.multimesh.set_instance_transform(item.index,item.after)
func _ready() -> void:
	super._ready()
	while not woodland_ready96: await get_tree().physics_frame
	park99=_park_script99().new();park99.world=self;add_child(park99)
	await get_tree().physics_frame
	navigation.bake(get_world_3d().direct_space_state,meadow,meadow.landmarks.grove)
	woodland_ready99=true;_title35();time55.update_guide()
	print("WOODLAND99_READY")
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed:
		if event.physical_keycode==KEY_F2: set_review72(false);_teleport15(meadow.landmarks.grove+Vector2(0,2.5));return
		if event.physical_keycode==KEY_F3: set_review72(false);_teleport15(meadow.landmarks.grove+Vector2(5,-1));return
	super._unhandled_input(event)
