extends "res://scripts/world/woodland_world96.gd"
const PARK98=preload("res://scripts/world/park_layout98.gd")
var woodland_ready98 := false
var park98: Node3D
var swing_tree98: Dictionary={}
func _rebuild_root_pieces() -> void:
	extra_profiles["swing_oak98"]={"foot":[1000,1230],"height":1230,"cutoff":.5}
	for tree in trees:
		if tree.visual.has_meta("swing_oak98"): tree.extra_id="swing_oak98"
	super._rebuild_root_pieces()
func _replace_sprite(sprite: Sprite3D,id: String,height: float,pack: Dictionary) -> void:
	if not sprite.has_meta("swing_oak98"):
		super._replace_sprite(sprite,id,height,pack);return
	var texture: Texture2D=preload("res://assets/park98/swing_oak98.png")
	sprite.texture=texture;sprite.pixel_size=8.8/1230.
	sprite.offset=Vector2(texture.get_width()/2.-1000.,1230.-texture.get_height()/2.)
	sprite.material_override.set_shader_parameter("paint",texture)
func _forest_script87() -> Script: return preload("res://scripts/art/forest_props98.gd")
func _rock_surfaces_script91() -> Script: return preload("res://scripts/art/rock_surfaces98.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time98.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 98 · 林间自然游园 / 高崖树林 / 秋千踏桩")
func _build_lab_floor() -> void:
	super._build_lab_floor();meadow=preload("res://scripts/world/world_surface98.gd").new()
func _build_woodland() -> void:
	super._build_woodland()
	var g: Vector2=meadow.landmarks.grove
	for tree in trees:
		var p: Vector2=Vector2(tree.root.position.x,tree.root.position.z)-g
		var target := p
		if tree.root.has_meta("finger93"):
			if p.distance_to(Vector2(-8,-2))<.2: target=Vector2(-5.95,-6.375)
			elif p.distance_to(Vector2(-12,1))<.2: target=Vector2(-15.2,3.5)
			elif p.distance_to(Vector2(8,-9))<.2: target=Vector2(11.5,-12.5)
		if target!=p: tree.root.position=Vector3(g.x+target.x,meadow.height_at(g.x+target.x,g.y+target.y,true),g.y+target.y)
	for offset in [Vector2(-25,-24),Vector2(-25,-15),Vector2(-26,-6),Vector2(-25,3),Vector2(-26,11),Vector2(-22,-29),Vector2(-16,-8.5),Vector2(-4.8,-5.2),Vector2(11.55,-6.6)]:
		var at: Vector2=g+offset
		var near := false
		for tree in trees:
			if Vector2(tree.root.position.x,tree.root.position.z).distance_to(at)<2.: near=true;break
		if not near and meadow.normal_at(at.x,at.y,true).y>.95: _add_route_tree(at,8.3 if offset.x< -20. else 7.8)
	for tree in trees:
		var p := Vector2(tree.root.position.x,tree.root.position.z)-g
		if p.distance_to(Vector2(11.55,-6.6))<.3:
			tree.root.position.x=g.x+14.55
			tree.root.position.y=meadow.height_at(tree.root.position.x,tree.root.position.z,true)
			tree.height=8.8;tree.extra_id="swing_oak98";tree.visual.set_meta("swing_oak98",true)
			extra_profiles["swing_oak98"]={"foot":[1000,1230],"height":1230,"cutoff":.5}
			_replace_sprite(tree.visual,"oak",8.8,{})
			swing_tree98=tree;break
func _grass_growth92(at: Vector2) -> float:
	var growth := super._grass_growth92(at)
	var p: Vector2=at-Vector2(meadow.landmarks.grove)
	if PARK98.on_stairs98(p): return 0.
	return lerpf(growth,.04,1.-smoothstep(.75,1.5,PARK98.path_distance98(p)))
func _refresh_planting() -> void:
	super._refresh_planting()
	var g: Vector2=meadow.landmarks.grove
	for item in grass_poses92:
		var point: Vector3=item.node.to_global(item.after.origin)
		var p := Vector2(point.x,point.z)-g
		if PARK98.path_distance98(p)<.94 or PARK98.on_stairs98(p) or (p-PARK98.DECK).length()<2.9:
			item.after.basis=Basis(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO)
			item.before.basis=Basis(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO)
			item.node.multimesh.set_instance_transform(item.index,item.after)
func _ready() -> void:
	super._ready()
	while not woodland_ready96: await get_tree().physics_frame
	park98=preload("res://scripts/art/nature_park98.gd").new();park98.world=self;add_child(park98)
	await get_tree().physics_frame
	navigation.bake(get_world_3d().direct_space_state,meadow,meadow.landmarks.grove)
	woodland_ready98=true;_title35();time55.update_guide()
	print("WOODLAND98_READY")
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed:
		if event.physical_keycode==KEY_F2: set_review72(false);_teleport15(meadow.landmarks.grove+Vector2(-1,5));return
		if event.physical_keycode==KEY_F3: set_review72(false);_teleport15(meadow.landmarks.grove+Vector2(8,-2));return
	super._unhandled_input(event)
