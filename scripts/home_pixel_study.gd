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
var courtyard_ground: Node2D
var overview := false
var solar_union: Node2D
var sky_index := 1
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
var standing_flowers: Array[Node2D] = []

func _standing_flower(at: Vector2,variant: int) -> Node2D:
	var prop := Prop.new()
	prop.name = "Flower%03d" % standing_flowers.size()
	var names := ["flower_pink","flower_blue","flower_red"]
	prop.profile = load("res://assets/courtyard_v1/"+names[variant%3]+".tres")
	prop.position = at
	world.add_child(prop)
	prop.visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	prop.visual.modulate = Color(0.90,0.94,0.87)
	standing_flowers.append(prop)
	return prop

func _ready() -> void:
	process_priority = 200
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	DisplayServer.window_set_title("小白鹅 · 小屋入口 · 出发站素材体系")
	rig = Lighting.new()
	rig.name = "WorldLighting"
	rig.auto_update_projections = false
	add_child(rig)
	world = preload("res://scenes/world/courtyard_props.tscn").instantiate()
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
		if arg=="--sunset": sky_index = 0
		if arg=="--noon": sky_index = 1
		if arg=="--night": sky_index = 2
		if arg=="--dawn": sky_index = 3
		if arg=="--overview":
			overview = true
			follow = false
			camera.zoom = Vector2.ONE*2.1
			camera.position = _camera_center(Vector2(0,65))
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
	courtyard_ground = preload("res://scripts/world/courtyard_ground.gd").new()
	courtyard_ground.name = "CourtyardGround"
	add_child(courtyard_ground)
	paving_outline = courtyard_ground.paving_outline
	paving_border = paving_outline.duplicate()

func _build_groves() -> void:
	# Approved low vegetation forms continuous groups at the grove bases.
	for entry in [Vector3(-200,15,110),Vector3(-206,111,112),Vector3(-170,191,120),Vector3(198,-2,111),Vector3(225,96,86),Vector3(197,216,85),Vector3(-140,-115,88),Vector3(127,-108,82),Vector3(-105,184,59),Vector3(-51,189,45),Vector3(98,190,57),Vector3(148,172,55),Vector3(177,144,50),Vector3(179,92,50),Vector3(164,35,61),Vector3(-116,131,43),Vector3(-115,11,34),Vector3(66,12,39)]:
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
	add_child(ground_transitions)
	var rng := RandomNumberGenerator.new()
	rng.seed = 161016
	var centers := [Vector2(-120,166),Vector2(-79,180),Vector2(-30,179),Vector2(76,170),Vector2(121,161),Vector2(174,151),Vector2(171,112),Vector2(174,62),Vector2(146,17),Vector2(85,22),Vector2(-114,10),Vector2(-120,70),Vector2(-106,131),Vector2(-60,115),Vector2(-17,113),Vector2(75,131),Vector2(71,92),Vector2(-38,214),Vector2(96,225),Vector2(257,52),Vector2(264,131),Vector2(260,205),Vector2(238,-74)]
	for center in centers:
		for j in 22:
			var at: Vector2 = (center+Vector2(rng.randf_range(-18,18),rng.randf_range(-9,9))).snapped(Vector2.ONE)
			if courtyard_ground.on_dirt(at) or at.distance_to(Vector2(25,74))<20: continue
			var flower := j%2==0
			if flower:
				if j%6==0: _standing_flower(at,j/6+standing_flowers.size())
				continue
			var tex := _atlas(Rect2(64+16*(j%4),880,16,16))
			var spr := _ground_stamp(tex,at,Vector2(15,14))
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for tree in trees:
		for side in [-1,1]:
			var at: Vector2 = tree.position+Vector2(side*17,1)
			if courtyard_ground.on_dirt(at): continue
			var spr := _ground_stamp(_atlas(Rect2(64,880,16,16)),at,Vector2(17,15))
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for i in paving_outline.size():
		var a: Vector2 = paving_outline[i]
		var b: Vector2 = paving_outline[(i+1)%paving_outline.size()]
		var count := maxi(1,ceili(a.distance_to(b)/12))
		for j in count:
			if rng.randf()<0.25: continue
			var at := a.lerp(b,float(j)/count)+Vector2(rng.randf_range(-3,3),rng.randf_range(-2,2))
			if at.distance_to(Vector2(25,74))<20: continue
			var spr := _ground_stamp(_atlas(Rect2(64+16*(j%4),880,16,16)),at,Vector2(9,9))
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

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
	for at in [Vector2(-83,8),Vector2(-30,8)]:
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
	enemy.position = Vector2(-32,143)
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
	var half := get_viewport_rect().size/camera.zoom*0.5
	var low := BOUNDS.position+half
	var high := BOUNDS.end-half
	return Vector2(clampf(target.x,low.x,high.x) if low.x<=high.x else BOUNDS.get_center().x,clampf(target.y,low.y,high.y) if low.y<=high.y else BOUNDS.get_center().y)

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
	label.text = "小屋入口 · 出发站素材体系   WASD 移动 / Shift 快走\nN 天色：%s（出发站过渡）  O 光影   C 跟随   V 植被   H 碰撞   R 复位\nJ 地表衔接对比 / Tab 全院 / F1 面板   ·   团团为外观占位" % skies[sky_index]

func _update_lamps() -> void:
	var nighttime: float = 1.0-clampf(rig.current_energy/0.20,0,1)
	for emitter in emitters:
		emitter.set_energy(lerpf(emitter.profile.daytime_energy,emitter.profile.energy,nighttime))
		emitter.set_shadows(shadows)

func _process(delta: float) -> void:
	if not hero or not camera: return
	var target := Vector2(0,65) if overview else (hero.position+Vector2(0,-47) if follow else Vector2(25,27))
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
	for flower in standing_flowers: draw_circle(flower.position,1.0,Color("dfb5f2"))

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
			for flower in standing_flowers: flower.visible = transition_details and vegetation
		KEY_TAB:
			overview = not overview
			camera.zoom = Vector2.ONE*(2.1 if overview else 3.0)
		KEY_O: shadows = not shadows
		KEY_C: follow = not follow
		KEY_H: guides = not guides
		KEY_V:
			vegetation = not vegetation
			for node in world.get_children():
				if node.name.begins_with("Tree") or node.name.begins_with("Understory"): node.visible = vegetation
			nature.active = vegetation
			nature.visible = vegetation
			for flower in standing_flowers: flower.visible = transition_details and vegetation
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
