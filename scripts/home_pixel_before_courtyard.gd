extends Node2D
## Mature station palette and lighting, composed as the cottage entrance of layout A.
const Prop = preload("res://scripts/world/world_prop.gd")
const Profile = preload("res://scripts/world/world_prop_profile.gd")
const Actor = preload("res://scripts/study_actor.gd")
const Lighting = preload("res://scripts/art/world_lighting.gd")
const LocalShadow = preload("res://scripts/art/projected_actor_shadow.gd")
const BOUNDS := Rect2(-335,-245,670,565)
var world: Node2D
var rig: Node2D
var hero: CharacterBody2D
var enemy: CharacterBody2D
var camera: Camera2D
var local_sources: Array[Dictionary] = []
var registered_props: Array[Node2D] = []
var actor_projections: Array[Node2D] = []
var emitters: Array[Node2D] = []
var trees: Array[Node2D] = []
var nature: Node2D
var solar_union: Node2D
var sky_index := 0
var skies := ["sunset","noon","night","dawn"]
var shadows := true
var vegetation := true
var follow := true
var guides := false
var label: Label
var paving_outline: PackedVector2Array
var paving_border: PackedVector2Array
var ground_transitions: Node2D
var transition_details := true
var transition_stamps: Array[Sprite2D] = []

func _ready() -> void:
	process_priority = 200
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	DisplayServer.window_set_title("小白鹅 · 小屋入口 · 出发站素材体系")
	rig = Lighting.new()
	rig.name = "WorldLighting"
	rig.auto_update_projections = false
	add_child(rig)
	world = preload("res://scenes/world/home_props.tscn").instantiate()
	add_child(world)
	for child in world.get_children():
		if child.name.begins_with("Tree"): trees.append(child)
	_ground()
	_build_groves()
	_build_details()
	_build_ground_transitions()
	_build_actors()
	_boundaries()
	camera = Camera2D.new()
	camera.zoom = Vector2.ONE*3
	camera.position = _camera_center(hero.position+Vector2(0,-47))
	add_child(camera)
	camera.make_current()
	_build_ui()
	for arg in OS.get_cmdline_user_args():
		if arg=="--noon": sky_index = 1
		if arg=="--night": sky_index = 2
		if arg=="--dawn": sky_index = 3
	rig.set_profile(load("res://assets/world_lighting_v1/"+skies[sky_index]+".tres"),true)
	_finish.call_deferred()

func _finish() -> void:
	for prop in registered_props:
		if prop.emitter:
			emitters.append(prop.emitter)
			local_sources.append(prop.emitter.projection_source())
	for projection in rig.projections: projection.update_shadow(0,true)
	solar_union = preload("res://scripts/art/solar_union.gd").new()
	solar_union.rig = rig
	add_child(solar_union)
	for projection in rig.projections: solar_union.register(projection)
	camera.force_update_scroll()
	solar_union.sync(shadows)
	_build_leaves()
	_update_lamps()
	_status()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): _capture(arg.trim_prefix("--capture="))

func _atlas(rect: Rect2) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = load("res://assets/tiles/exterior.png")
	texture.region = rect
	texture.filter_clip = true
	return texture

func _ground() -> void:
	var grass := TileMapLayer.new()
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(16,16)
	var source := TileSetAtlasSource.new()
	source.texture = load("res://assets/tiles/exterior.png")
	source.texture_region_size = Vector2i(16,16)
	source.create_tile(Vector2i(2,18))
	tile_set.add_source(source,0)
	grass.tile_set = tile_set
	grass.collision_enabled = false
	grass.z_index = -8
	add_child(grass)
	for y in range(-17,23):
		for x in range(-23,23): grass.set_cell(Vector2i(x,y),0,Vector2i(2,18))
	var contour := PackedVector2Array([Vector2(-103,-9),Vector2(-55,-13),Vector2(68,-8),Vector2(112,3),Vector2(137,29),Vector2(128,66),Vector2(105,85),Vector2(111,110),Vector2(83,130),Vector2(49,136),Vector2(48,330),Vector2(9,330),Vector2(10,146),Vector2(-20,130),Vector2(-58,116),Vector2(-84,92),Vector2(-111,74),Vector2(-125,43)])
	paving_border = contour.duplicate()
	var rng := RandomNumberGenerator.new()
	rng.seed = 151086
	for i in contour.size():
		var a := contour[i]
		var b := contour[(i+1)%contour.size()]
		var count := maxi(1,ceili(a.distance_to(b)/9))
		for j in count:
			var point := a.lerp(b,float(j)/count)
			if j>0: point += (b-a).normalized().orthogonal()*rng.randf_range(-2,2)
			paving_outline.append(point.snapped(Vector2.ONE))
	var paving := Polygon2D.new()
	paving.name = "ContinuousDoorstepAndPath"
	paving.polygon = paving_outline
	paving.texture = load("res://assets/departure_plaza_v1/paving.png")
	paving.texture_repeat = CanvasItem.TEXTURE_REPEAT_MIRROR
	var uv := PackedVector2Array()
	var unit := 128.0/paving.texture.get_width()
	for point in paving_outline: uv.append(point/unit)
	paving.uv = uv
	paving.z_index = -7
	add_child(paving)

func _build_groves() -> void:
	# Approved low vegetation forms continuous groups at the grove bases.
	for entry in [Vector3(-200,15,110),Vector3(-206,111,112),Vector3(-170,191,120),Vector3(198,-2,111),Vector3(207,96,115),Vector3(172,196,110),Vector3(-140,-115,88),Vector3(127,-108,82)]:
		var prop := Prop.new()
		prop.name = "Understory%02d" % world.get_child_count()
		var profile := Profile.new()
		profile.texture = load("res://assets/departure_plaza_v1/understory_bed_v2.png")
		profile.anchor_px = Vector2(1063,687)
		profile.draw_scale = entry.z/2051.0
		profile.footprint = Vector2.ZERO
		profile.contact_size = Vector2(entry.z*0.7,8)
		profile.projection_kind = 2
		prop.profile = profile
		prop.position = Vector2(entry.x,entry.y)
		world.add_child(prop)
		prop.visual.material = _cutout()
func _cutout() -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = preload("res://scripts/art/station_cutout.gdshader")
	return material

func _ground_stamp(texture: Texture2D,at: Vector2,size: Vector2,angle := 0.0) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = at
	sprite.scale = size/texture.get_size()
	sprite.rotation = angle
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.z_as_relative = false
	sprite.z_index = -3
	ground_transitions.add_child(sprite)
	transition_stamps.append(sprite)
	return sprite

func _build_ground_transitions() -> void:
	ground_transitions = Node2D.new()
	ground_transitions.name = "PavingAndRootTransitions"
	ground_transitions.z_index = 0
	add_child(ground_transitions)
	var rng := RandomNumberGenerator.new()
	rng.seed = 151516
	var verge: Texture2D = load("res://assets/departure_plaza_v1/paving_verge_v1.png")
	var moss: Texture2D = load("res://assets/departure_plaza_v1/moss_chips_v1.png")
	# Broken flat verge pieces follow the actual paving contour, not a rectangle.
	for i in paving_border.size():
		var a := paving_border[i]
		var b := paving_border[(i+1)%paving_border.size()]
		if minf(a.y,b.y)<0: continue
		var length := a.distance_to(b)
		var count := maxi(1,ceili(length/38.0))
		for j in count:
			if rng.randf()<0.30: continue
			var at := a.lerp(b,(j+0.5)/count)
			var width := length/count+rng.randf_range(1,6)
			var strip := AtlasTexture.new()
			strip.atlas = verge
			strip.region = Rect2([20,650,1270][(i+j)%3],280,630,280)
			strip.filter_clip = true
			_ground_stamp(strip,at,Vector2(width,width*0.50),(b-a).angle())
			var outer := (b-a).normalized().orthogonal()
			if Geometry2D.is_point_in_polygon(at+outer*5,paving_outline): outer = -outer
			if j%2==0:
				var chips := _ground_stamp(moss,at+outer*6,Vector2(17,9),(b-a).angle())
				chips.flip_h = i%2==0
			for side in [-1,1]:
				if rng.randf()<0.30: continue
				var spot: Vector2 = at+(b-a).normalized()*float(side)*width*0.3+outer*rng.randf_range(4,9)
				if Geometry2D.is_point_in_polygon(spot,paving_outline): continue
				_ground_stamp(_atlas(Rect2(64+16*(j%4),880,16,16)),spot,Vector2(9,9))
	# Small low tufts attach to each authored tree root and avoid its trunk center.
	var leaves: Texture2D = load("res://assets/departure_plaza_v1/fallen_leaves_v1.png")
	for i in trees.size():
		var tree: Node2D = trees[i]
		for side in [-1,1]:
			var at := tree.position+Vector2(side*rng.randf_range(14,22),rng.randf_range(-1,5))
			if Geometry2D.is_point_in_polygon(at,paving_outline): continue
			_ground_stamp(_atlas(Rect2(64+16*(i%4),880,16,16)),at,Vector2(13,12))
		if i%3==0:
			var at := tree.position+Vector2(12,7)
			if not Geometry2D.is_point_in_polygon(at,paving_outline):
				_ground_stamp(leaves,at,Vector2(22,12))

func _build_details() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 151088
	for center in [Vector2(-123,22),Vector2(-139,91),Vector2(-105,139),Vector2(-163,174),Vector2(137,19),Vector2(147,83),Vector2(123,150),Vector2(98,193),Vector2(-38,148),Vector2(69,179)]:
		for j in 8:
			var at: Vector2 = center+Vector2(rng.randf_range(-19,19),rng.randf_range(-12,12))
			if Geometry2D.is_point_in_polygon(at,paving_outline): continue
			var sprite := Sprite2D.new()
			sprite.texture = _atlas(Rect2(64+(j%4)*16,880,16,16))
			sprite.position = at
			sprite.scale = Vector2.ONE*rng.randf_range(0.7,1.0)
			sprite.flip_h = j%2==0
			sprite.z_index = -6
			add_child(sprite)
	for at in [Vector2(-87,15),Vector2(75,13)]:
		var prop := Prop.new()
		prop.name = "WindowFlowerBox%02d" % world.get_child_count()
		var profile := Profile.new()
		profile.texture = load("res://assets/departure_plaza_v1/flower_box_v1.png")
		profile.anchor_px = Vector2(887,633)
		profile.draw_scale = 0.035
		profile.footprint = Vector2(32,8)
		profile.footprint_offset = Vector2(0,-2)
		profile.contact_size = Vector2(35,6)
		profile.height = 12
		profile.projection_kind = 1
		profile.raised_plane = Rect2(-16,-5,32,5)
		profile.contacts = PackedVector2Array([Vector2(-16,0),Vector2(16,0)])
		prop.profile = profile
		prop.position = at
		world.add_child(prop)
		prop.visual.material = _cutout()

func _build_actors() -> void:
	hero = Actor.new()
	hero.name = "Hero"
	hero.target_height = 31.3
	hero.move_speed = 78.3
	hero.fast_speed = 120
	hero.position = Vector2(25,74)
	world.add_child(hero)
	hero.visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	hero.get_node("Footprint").scale = Vector2.ONE/3
	hero.get_node("Footprint").position.y = -2
	_surface_mask(hero)
	enemy = Actor.new()
	enemy.name = "Tuantuan"
	enemy.enemy = true
	enemy.target_height = 26
	enemy.position = Vector2(75,86)
	world.add_child(enemy)
	enemy.visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	enemy.get_node("Footprint").scale = Vector2.ONE/3
	enemy.get_node("Footprint").position.y = -2
	_surface_mask(enemy)
	for actor in [hero,enemy]:
		rig.project_sprite(actor,actor.visual,actor.target_height,100)
		var shadow := LocalShadow.new()
		shadow.actor = actor
		shadow.visual = actor.visual
		shadow.body_height = actor.target_height
		shadow.max_length = 65
		shadow.sources = local_sources
		shadow.natural_light = rig
		add_child(shadow)
		actor_projections.append(shadow)

func _surface_mask(node: Node) -> void:
	if node is CanvasItem: node.light_mask = 2
	for child in node.get_children(): _surface_mask(child)

func register_world_prop(prop: Node2D) -> void:
	registered_props.append(prop)
	# These objects already use finite height projections, as in the station.
	# Adding footprint occluders duplicates them with long point-light wedges.

func _build_leaves() -> void:
	nature = preload("res://scripts/art/garden_tree_leaves.gd").new()
	nature.world = world
	for tree in trees:
		var sprite: Sprite2D = tree.visual
		var image: Image = sprite.texture.get_image()
		nature.sources.append({"node":tree,"visual":sprite,"image":image,"crown":Rect2(4,4,image.get_width()-8,image.get_height()*0.6)})
	add_child(nature)

func _boundaries() -> void:
	for rect in [Rect2(-351,-261,702,16),Rect2(-351,320,702,16),Rect2(-351,-245,16,565),Rect2(335,-245,16,565)]:
		var body := StaticBody2D.new()
		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = rect.size
		shape.shape = rectangle
		body.position = rect.get_center()
		body.add_child(shape)
		add_child(body)

func _camera_center(target: Vector2) -> Vector2:
	var half := get_viewport_rect().size/Vector2(3,3)*0.5
	return target.clamp(BOUNDS.position+half,BOUNDS.end-half)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	label = Label.new()
	label.position = Vector2(22,18)
	label.add_theme_font_size_override("font_size",18)
	label.add_theme_color_override("font_outline_color",Color("202735"))
	label.add_theme_constant_override("outline_size",5)
	layer.add_child(label)

func _status() -> void:
	label.text = "小屋入口 · 出发站素材体系   WASD 移动 / Shift 快走\nN 天色：%s（出发站过渡）  O 光影   C 跟随   V 植被   H 碰撞   R 复位\nJ 地表衔接对比 / F1 面板   ·   团团为外观占位" % skies[sky_index]

func _update_lamps() -> void:
	var nighttime: float = 1.0-clampf(rig.current_energy/0.20,0,1)
	for emitter in emitters:
		emitter.set_energy(lerpf(emitter.profile.daytime_energy,emitter.profile.energy,nighttime))
		emitter.set_shadows(shadows)

func _process(delta: float) -> void:
	if not hero or not camera: return
	var target := hero.position+Vector2(0,-47) if follow else Vector2(25,27)
	camera.position = camera.position.lerp(_camera_center(target),1-exp(-delta*5))
	_update_lamps()
	for projection in rig.projections: projection.update_shadow(delta,shadows)
	for prop in registered_props:
		prop.local_projection.update_shadow(delta,shadows)
	for projection in actor_projections: projection.update_shadow(delta,shadows)
	if solar_union:
		camera.force_update_scroll()
		solar_union.sync(shadows)
	queue_redraw()

func _draw() -> void:
	if not guides: return
	for prop in registered_props:
		var profile: Resource = prop.profile
		draw_rect(Rect2(prop.position+(prop.effective_offset()-prop.effective_footprint()*0.5)*prop.size_factor,prop.effective_footprint()*prop.size_factor),Color(1,0.8,0.2,0.85),false,0.8)
		draw_circle(prop.position,1.6,Color.CYAN)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	match event.physical_keycode:
		KEY_N:
			sky_index = (sky_index+1)%skies.size()
			rig.set_profile(load("res://assets/world_lighting_v1/"+skies[sky_index]+".tres"))
		KEY_J:
			transition_details = not transition_details
			ground_transitions.visible = transition_details
			for sprite in transition_stamps: sprite.visible = transition_details
		KEY_O: shadows = not shadows
		KEY_C: follow = not follow
		KEY_H: guides = not guides
		KEY_V:
			vegetation = not vegetation
			for node in world.get_children():
				if node.name.begins_with("Tree") or node.name.begins_with("Understory"): node.visible = vegetation
			nature.active = vegetation
			nature.visible = vegetation
		KEY_R:
			hero.position = Vector2(25,74)
			hero.velocity = Vector2.ZERO
		KEY_F1: label.visible = not label.visible
		KEY_ESCAPE: get_tree().quit()
	_status()

func _capture(path: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var result := get_viewport().get_texture().get_image().save_png(path)
	print("PIXEL_HOME_CAPTURE ",path," result=",result)
	get_tree().quit(0 if result==OK else 1)
