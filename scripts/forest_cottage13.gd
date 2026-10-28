extends "res://scripts/ground_style_lab.gd"
## Woodland composition built on the approved meadow. The material-only lab stays separate.
var scenery_ready := false
var depth_lighting := true
var far_forest := true
var distant_roots: Array[Node3D] = []
var cottage_root: Node3D
var cottage_body: StaticBody3D
var shade_texture: ImageTexture
var art_profiles: Dictionary
var art_textures: Dictionary = {}
var mixed_grass := true

func _ready() -> void:
	meadow = preload("res://scripts/art/forest_landscape13.gd").new()
	terrain_enabled = true
	grass_variant = 2
	super._ready()
	art_profiles = JSON.parse_string(FileAccess.get_file_as_string("res://assets/forest13/profiles.json"))
	for id in ["oak","young","cottage"]:
		var image: Image = load("res://assets/forest13/%s.png"%id).get_image()
		if image.is_compressed(): image.decompress()
		image.generate_mipmaps()
		art_textures[id] = ImageTexture.create_from_image(image)
	_build_woodland()
	_build_cottage()
	_bake_root_shade()
	scenery_ready = true
	_set_depth_lighting(true)
	if not "--close" in OS.get_cmdline_user_args():
		camera_distance = 15.
		_update_camera(0,true)
	for arg in OS.get_cmdline_user_args():
		if arg=="--flat-light": _set_depth_lighting(false)
		if arg=="--open-distance": _set_far_forest(false)
	_status()

func _build_lab_grass() -> void:
	super._build_lab_grass()
	# Keep the approach, doorstep and occupied building footprint free of grass.
	var keep: Array[Transform3D] = []
	var data: Array[Color] = []
	for i in planting.size():
		var p := Vector2(planting[i].origin.x,planting[i].origin.z)
		var a := Vector2(-.4,-1.8)
		var b := Vector2(-4.7,-4.8)
		var v := b-a
		var along := clampf((p-a).dot(v)/v.length_squared(),0.,1.)
		var approach := p.distance_to(a+v*along)<.86
		var house := p.x> -8.3 and p.x< -1.1 and p.y> -9.4 and p.y< -4.4
		if approach or house: continue
		keep.append(planting[i])
		data.append(grass.multimesh.get_instance_custom_data(i))
	planting = keep
	grass.multimesh.instance_count = keep.size()
	for i in keep.size():
		grass.multimesh.set_instance_transform(i,keep[i])
		var at := keep[i].origin
		var chance: float = .18+.18*smoothstep(2.5,9.,absf(at.x))+meadow.noise.get_noise_2d(at.x,at.z)*.18
		var color := data[i]
		color.b = 1. if color.g<chance else 0.
		grass.multimesh.set_instance_custom_data(i,color)

func set_candidate(index: int) -> void:
	super.set_candidate(index)
	var mixing := mixed_grass and solid_grass and grass_variant>0
	if mixing: grass.multimesh.mesh = meadow_meshes[2]
	for material in meadow_materials: material.set_shader_parameter("mixed_grass",mixing)

func _art(id: String,height: float) -> Sprite3D:
	var profile: Dictionary = art_profiles[id]
	var texture: Texture2D = art_textures[id]
	var sprite := _sprite(texture,Vector2(profile.foot[0],profile.foot[1]),height,float(profile.height))
	# The existing helper supplies anchored geometry; this shader receives scene light.
	var material := ShaderMaterial.new()
	material.shader = preload("res://scripts/art/forest_cutout13.gdshader")
	material.set_shader_parameter("paint",texture)
	material.set_shader_parameter("fade",1.)
	sprite.material_override = material
	sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return sprite

func _build_woodland() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026101613
	var positions: Array[Vector2] = []
	# Overlapping rear ranks close the view at every available zoom distance.
	for row in 3:
		for col in 15:
			positions.append(Vector2(-26.+float(col)*3.7+float(row%2)*1.65+rng.randf_range(-.35,.35),-17.-float(row)*4.2+rng.randf_range(-.4,.4)))
	# Side woods taper towards the playable clearing, with deliberate gaps at paths.
	for side in [-1.,1.]:
		for row in 9:
			positions.append(Vector2(side*(13.8+rng.randf_range(-.8,.8)),-14.+float(row)*3.8))
			positions.append(Vector2(side*(18.+rng.randf_range(-.7,.7)),-16.+float(row)*4.))
	positions.append_array([Vector2(-11,-8),Vector2(-10,-12),Vector2(7,-11),Vector2(10,-6),Vector2(-11,1),Vector2(10,3),Vector2(-10,9),Vector2(11,11)])
	for i in positions.size():
		var at := positions[i]
		var root := Node3D.new()
		root.name = "Tree%03d"%i
		root.position = Vector3(at.x,meadow.height_at(at.x,at.y,terrain_enabled),at.y)
		add_child(root)
		var height := rng.randf_range(5.5,7.3)
		var sprite := _art("oak" if i%3!=1 else "young",height)
		root.add_child(sprite)
		var material: ShaderMaterial = sprite.material_override
		var tint := Color("edf1d7") if at.y< -21. else Color.WHITE
		material.set_shader_parameter("tint",tint)
		var body := StaticBody3D.new()
		body.collision_layer = 2
		var collision := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = .35
		shape.height = 2.6
		collision.shape = shape
		collision.position.y = 1.3
		body.add_child(collision)
		root.add_child(body)
		trees.append({"root":root,"visual":sprite,"height":height})
		if at.y< -15. or absf(at.x)>15.: distant_roots.append(root)

func _build_cottage() -> void:
	cottage_root = Node3D.new()
	cottage_root.name = "CottageOnLevelPad"
	cottage_root.position = Vector3(-4.7,meadow.height_at(-4.7,-4.8,terrain_enabled),-4.8)
	add_child(cottage_root)
	house_art = _art("cottage",4.9)
	house_art.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	house_art.rotation_degrees.x = -25
	cottage_root.add_child(house_art)
	cottage_body = StaticBody3D.new()
	cottage_body.collision_layer = 2
	cottage_body.name = "CottageFootprint"
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(6.3,3.8,3.8)
	collision.shape = shape
	collision.position = Vector3(0,1.9,-2.25)
	cottage_body.add_child(collision)
	cottage_root.add_child(cottage_body)

func _stamp(mask: Image,at: Vector2,radius: Vector2,channel: int) -> void:
	var size := mask.get_width()
	var center := (at+Vector2.ONE*32.)/64.*float(size)
	var extent := radius/64.*float(size)*2.4
	var rect := Rect2i(Vector2i(center-extent),Vector2i(extent*2.)+Vector2i.ONE).intersection(Rect2i(0,0,size,size))
	for y in range(rect.position.y,rect.end.y):
		for x in range(rect.position.x,rect.end.x):
			var world := Vector2(float(x)+.5,float(y)+.5)/float(size)*64.-Vector2.ONE*32.
			var delta := (world-at)/radius
			var strength := exp(-delta.length_squared()*1.7)
			var color := mask.get_pixel(x,y)
			color[channel] = maxf(color[channel],strength)
			mask.set_pixel(x,y,color)

func _bake_root_shade() -> void:
	var mask := Image.create(512,512,false,Image.FORMAT_RGBA8)
	mask.fill(Color(0,0,0,1))
	for tree in trees:
		if not tree.root.visible: continue
		var at: Vector3 = tree.root.position
		_stamp(mask,Vector2(at.x,at.z),Vector2(2.5,2.),0)
		_stamp(mask,Vector2(at.x,at.z),Vector2(.55,.4),1)
	_stamp(mask,Vector2(-4.7,-5.1),Vector2(3.5,.75),2)
	shade_texture = ImageTexture.create_from_image(mask)
	for material in ground_materials+meadow_materials:
		material.set_shader_parameter("forest_mask",shade_texture)
	for material in ground_materials: material.set_shader_parameter("forest_layout",true)

func _set_depth_lighting(enabled: bool) -> void:
	depth_lighting = enabled
	for child in get_children():
		if child is WorldEnvironment:
			var environment: Environment = child.environment
			environment.ambient_light_energy = .36 if enabled else .50
			environment.ambient_light_color = Color("c4cdb8") if enabled else Color("b6c5d0")
			environment.fog_density = .004 if enabled else .0025
	sun.light_color = Color("ffedd1") if enabled else Color.WHITE
	sun.light_energy = .72 if enabled else .65
	for material in ground_materials+meadow_materials: material.set_shader_parameter("forest_depth",enabled)

func _set_far_forest(enabled: bool) -> void:
	far_forest = enabled
	for root in distant_roots: root.visible = enabled
	if scenery_ready: _bake_root_shade()

func _rebuild_terrain() -> void:
	super._rebuild_terrain()
	for tree in trees:
		var at: Vector3 = tree.root.position
		tree.root.position.y = meadow.height_at(at.x,at.z,terrain_enabled)
	if is_instance_valid(cottage_root): cottage_root.position.y = meadow.height_at(-4.7,-4.8,terrain_enabled)

func _process(delta: float) -> void:
	super._process(delta)
	if not scenery_ready: return
	_update_forest_occlusion(delta)

func _update_forest_occlusion(delta: float) -> void:
	var head := camera.unproject_position(hero.position+Vector3.UP*.9)
	for tree in trees:
		var at: Vector3 = tree.root.position
		var blocks := false
		if fade_enabled and at.z>hero.position.z and not camera.is_position_behind(at):
			var top := camera.unproject_position(at+Vector3.UP*tree.height)
			var foot := camera.unproject_position(at)
			var side := camera.unproject_position(at+Vector3.RIGHT*tree.height*.43)
			var radius := absf(side.x-foot.x)
			var rect := Rect2(Vector2(foot.x-radius,top.y),Vector2(radius*2,foot.y-top.y)).abs()
			blocks = rect.has_point(head)
		var material: ShaderMaterial = tree.visual.material_override
		var previous: float = material.get_shader_parameter("fade")
		var next := move_toward(previous,.25 if blocks else 1.,delta*3.)
		if previous!=next: material.set_shader_parameter("fade",next)
	var query := PhysicsRayQueryParameters3D.create(camera.position,hero.position+Vector3.UP*.8,2)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	var blocked: bool = fade_enabled and not hit.is_empty() and hit.collider==cottage_body
	var material: ShaderMaterial = house_art.material_override
	var previous: float = material.get_shader_parameter("fade")
	material.set_shader_parameter("fade",move_toward(previous,.28 if blocked else 1.,delta*3.))

func _status() -> void:
	if not is_instance_valid(label): return
	label.text = "林间小屋13 · 25°固定透视 · %s · 林带 %s\nWASD / Shift 移动 · 滚轮缩放 · N 光影层次 · B 远处林带 · F 遮挡淡出\nM 短高混合 %s · 7 短草 / 8 高草 / 9 圆叶 · 1—6 地皮 · T 地形 · F1 隐藏\n树干碰撞，房屋固定角度贴片；R 起点 · F2 远看 · F3 屋前" % ["光影层次开" if depth_lighting else "原平光","开" if far_forest else "关","开" if mixed_grass else "关"]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode in [KEY_7,KEY_8,KEY_9,KEY_0]: mixed_grass = false
		match event.physical_keycode:
			KEY_M:
				mixed_grass = not mixed_grass
				grass_variant = 2
				solid_grass = true
				_refresh_planting()
				set_candidate(candidate)
				return
			KEY_N: _set_depth_lighting(not depth_lighting); return
			KEY_B: _set_far_forest(not far_forest); return
			KEY_F: fade_enabled = not fade_enabled; return
			KEY_F2,KEY_F3:
				var at := Vector2(0,9) if event.physical_keycode==KEY_F2 else Vector2(-4.7,-2.6)
				hero.position = Vector3(at.x,meadow.height_at(at.x,at.y,terrain_enabled)+.08,at.y)
				hero.velocity = Vector3.ZERO
				hero.reset_physics_interpolation()
				_update_camera(0,true)
				return
	super._unhandled_input(event)
