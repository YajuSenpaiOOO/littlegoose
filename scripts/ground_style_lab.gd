extends "res://scripts/perspective_playground.gd"
## Controlled material lab. No mixed houses, trees or combat props are instantiated.
var candidate := 3
var titles := ["A · 细节像素","B · 柔和绘本","C · 简洁可爱","D · 低细节绘本，无土斑","E · 简洁卡通，无土斑","F · 纯色底＋立体草"]
var ground_materials: Array[ShaderMaterial] = []
var grass_materials: Array[ShaderMaterial] = []
var wind_enabled := true
var albedo_view := false
var capture_path := ""
var solid_grass := true
var blade_materials: Array[ShaderMaterial] = []
var cross_mesh: ArrayMesh
var blade_mesh: ArrayMesh
var meadow = preload("res://scripts/art/meadow_lab12.gd").new()
var grass_variant := 1
var grass_names := ["旧11尖叶草","贴地短草","弯叶高草","圆叶卡通草"]
var meadow_meshes: Array[ArrayMesh] = []
var meadow_materials: Array[ShaderMaterial] = []
var terrain_enabled := false
var varied_height := true
var floor_collider: CollisionShape3D
var planting: Array[Transform3D] = []

func _hero_script() -> Script:
	return preload("res://scripts/perspective_actor.gd")

func _ready() -> void:
	get_tree().physics_interpolation = true
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	process_physics_priority = 100
	get_viewport().msaa_3d = Viewport.MSAA_4X
	_build_lighting()
	sun.light_color = Color.WHITE
	sun.light_energy = .65
	_build_materials()
	_build_lab_floor()
	hero = _hero_script().new()
	hero.position = Vector3(0,.1,3)
	add_child(hero)
	_shadow_proxy(hero,1.4,.18)
	hero_contact = _contact(hero)
	_build_lab_grass()
	camera = Camera3D.new()
	camera.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	camera.fov = 42
	camera.far = 160
	camera.rotation_degrees.x = -25
	add_child(camera)
	camera.make_current()
	camera_distance = 18.
	_update_camera(0,true)
	_build_ui()
	for i in 8: trail.append(Vector4(1000,1000,-100,1))
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--style="): candidate = clampi(int(arg.trim_prefix("--style="))-1,0,5)
		if arg.begins_with("--capture="): capture_path = arg.trim_prefix("--capture=")
		if arg=="--bare": plants_enabled = false
		if arg=="--cards": solid_grass = false
		if arg=="--terrain": terrain_enabled = true
		if arg.begins_with("--grass="): grass_variant = clampi(int(arg.trim_prefix("--grass=")),0,3)
		if arg=="--close": camera_distance = 12.; _update_camera(0,true)
	if terrain_enabled: _rebuild_terrain()
	_refresh_planting()
	set_candidate(candidate)
	if not capture_path.is_empty(): _capture(capture_path)

func _build_materials() -> void:
	var profiles: Array = JSON.parse_string(FileAccess.get_file_as_string("res://assets/ground_lab10/profiles.json"))
	for profile in profiles:
		var ground_image := load("res://assets/ground_lab10/%s_ground.png"%profile.id).get_image() as Image
		ground_image.generate_mipmaps()
		var ground_material := ShaderMaterial.new()
		ground_material.shader = preload("res://scripts/art/ground_lab_floor.gdshader")
		ground_material.set_shader_parameter("paint",ImageTexture.create_from_image(ground_image))
		ground_materials.append(ground_material)
		var grass_image := load("res://assets/ground_lab10/%s_grass.png"%profile.id).get_image() as Image
		var layers: Array[Image] = []
		var regions := PackedVector4Array()
		var size := Vector2i(profile.cell_size[0],profile.cell_size[1])
		for i in 4:
			var layer := grass_image.get_region(Rect2i(i*size.x,0,size.x,size.y))
			layer.fix_alpha_edges()
			layer.generate_mipmaps()
			layers.append(layer)
			var r: Array = profile.cells[i]
			regions.append(Vector4(float(r[0])/size.x,float(r[1])/size.y,float(r[2])/size.x,float(r[3])/size.y))
		var texture := Texture2DArray.new()
		texture.create_from_images(layers)
		var material := ShaderMaterial.new()
		material.shader = preload("res://scripts/art/ground_lab_grass.gdshader")
		material.set_shader_parameter("paint",texture)
		material.set_shader_parameter("regions",regions)
		grass_materials.append(material)
	for id in ["d","e","f"]:
		var material := ShaderMaterial.new()
		material.shader = preload("res://scripts/art/ground_lab_floor.gdshader")
		if id=="f":
			material.set_shader_parameter("flat_ground",true)
			material.set_shader_parameter("flat_color",Color("719052"))
		else:
			var image := load("res://assets/ground_lab11/%s_ground.png"%id).get_image() as Image
			image.generate_mipmaps()
			material.set_shader_parameter("paint",ImageTexture.create_from_image(image))
		ground_materials.append(material)
		grass_materials.append(grass_materials[1 if id=="d" else 2])
	# Paired palettes, same geometry and planting positions across all six grounds.
	var palettes := [["66743c","8d9c52"],["67804b","95a65d"],["739c48","a0bb65"],["65864f","8fa365"],["67934d","93af65"],["668b48","91a85e"]]
	for palette in palettes:
		var material := ShaderMaterial.new()
		material.shader = preload("res://scripts/art/ground_lab_blades.gdshader")
		material.set_shader_parameter("base_color",Color(palette[0]))
		material.set_shader_parameter("tip_color",Color(palette[1]))
		blade_materials.append(material)
	for floor_material in ground_materials:
		var material := ShaderMaterial.new()
		material.shader = preload("res://scripts/art/meadow_blades12.gdshader")
		material.set_shader_parameter("ground_paint",floor_material.get_shader_parameter("paint"))
		material.set_shader_parameter("flat_ground",floor_material.get_shader_parameter("flat_ground"))
		material.set_shader_parameter("flat_color",floor_material.get_shader_parameter("flat_color"))
		meadow_materials.append(material)

func _build_lab_floor() -> void:
	ground = MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(180,180)
	ground.mesh = plane
	ground.material_override = ground_materials[0]
	add_child(ground)
	var body := StaticBody3D.new()
	body.collision_layer = 1
	floor_collider = CollisionShape3D.new()
	floor_collider.shape = plane.create_trimesh_shape()
	body.add_child(floor_collider)
	ground.add_child(body)
	for x in [-15.,15.]: _box(Vector3(x,2,0),Vector3(.3,5,32),Color.TRANSPARENT,true,false)
	for z in [-15.,15.]: _box(Vector3(0,2,z),Vector3(32,5,.3),Color.TRANSPARENT,true,false)

func _rebuild_terrain() -> void:
	ground.mesh = meadow.terrain(terrain_enabled)
	floor_collider.shape = ground.mesh.create_trimesh_shape()
	if is_instance_valid(grass): _refresh_planting()
	if is_instance_valid(hero):
		hero.position.y = meadow.height_at(hero.position.x,hero.position.z,terrain_enabled)+.06
		hero.velocity.y = 0.
		hero.reset_physics_interpolation()
	if is_instance_valid(camera): _update_camera(0,true)

func _refresh_planting() -> void:
	for i in planting.size():
		var original: Transform3D = planting[i]
		var at := original.origin
		var normal: Vector3 = meadow.normal_at(at.x,at.z,terrain_enabled)
		var right := Vector3.RIGHT.slide(normal).normalized()
		var frame := Basis(right,normal,right.cross(normal))
		var basis := frame*original.basis
		if solid_grass and grass_variant>0 and varied_height:
			var patch: float = meadow.noise.get_noise_2d(at.x*1.5,at.z*1.5)
			var individual: float = grass.multimesh.get_instance_custom_data(i).g
			var damp := 1.-smoothstep(-.3,1.4,meadow.height_at(at.x,at.z,true))
			basis.y *= clampf(.8+patch*.8+individual*.5+damp*.18,.55,1.65)
		var y: float = meadow.height_at(at.x,at.z,terrain_enabled)
		# New blades start 3.5cm beneath this surface, preventing a cut-out root gap.
		if not solid_grass or grass_variant==0: y += .012
		grass.multimesh.set_instance_transform(i,Transform3D(basis,Vector3(at.x,y,at.z)))

func _cross_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for angle in [0.,PI/2.]:
		var right := Vector3(cos(angle),0,sin(angle))*.26
		var points := [-right,right,right+Vector3.UP*.42,-right+Vector3.UP*.42]
		var uv := [Vector2(0,1),Vector2(1,1),Vector2(1,0),Vector2(0,0)]
		for index in [0,1,2,0,2,3]:
			st.set_normal(Vector3.UP)
			st.set_uv(uv[index])
			st.add_vertex(points[index])
	return st.commit()

func _blade_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Five separated curved blades, each three broad sections and a pointed tip.
	# Actual silhouette geometry lets MSAA handle the edges without alpha sorting.
	for leaf in 5:
		var angle := float(leaf)*2.4
		var right := Vector3(cos(angle),0,sin(angle))
		var lean := Vector3(-sin(angle),0,cos(angle))
		var base := right*(float(leaf%3)-1.)*.09+lean*.035
		var height := .22+float(leaf%3)*.045
		var rows: Array[Vector3] = []
		for row in 4:
			var t := float(row)/3.
			var center := base+Vector3.UP*height*t+lean*.13*t*t
			var width: float = [.024,.033,.022,0.][row]
			rows.append(center-right*width)
			rows.append(center+right*width)
		for section in 3:
			var indices := [section*2,section*2+1,section*2+3,section*2,section*2+3,section*2+2]
			if section==2: indices = [4,5,6]
			for index in indices:
				st.set_normal(Vector3.UP)
				st.set_color(Color(float(leaf%2),0,0))
				st.set_uv(Vector2(float(index%2),float(index/2)/3.))
				st.add_vertex(rows[index])
	return st.commit()

func _build_lab_grass() -> void:
	grass = MultiMeshInstance3D.new()
	grass.name = "ReactiveGrass3600"
	var instances := MultiMesh.new()
	instances.transform_format = MultiMesh.TRANSFORM_3D
	instances.use_custom_data = true
	cross_mesh = _cross_mesh()
	blade_mesh = _blade_mesh()
	meadow_meshes.append(blade_mesh)
	for kind in range(1,4): meadow_meshes.append(meadow.blades(kind))
	instances.mesh = blade_mesh if solid_grass else cross_mesh
	instances.instance_count = 3600
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026101810
	for i in 3600:
		var at := Vector2.ZERO
		while true:
			at = Vector2(rng.randf_range(-14,14),rng.randf_range(-14,14))
			if absf(at.x-sin(at.y*.25)*.9)>.85: break
		if i==0: at = Vector2(-2.2,3.)
		var basis := Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3(rng.randf_range(.7,1.1),rng.randf_range(.6,1.05),1))
		instances.set_instance_transform(i,Transform3D(basis,Vector3(at.x,.012,at.y)))
		planting.append(Transform3D(basis,Vector3(at.x,0,at.y)))
		instances.set_instance_custom_data(i,Color(float(i%4)/4.,rng.randf(),0,1))
	grass.multimesh = instances
	grass.extra_cull_margin = .5
	grass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(grass)

func set_candidate(index: int) -> void:
	candidate = clampi(index,0,5)
	ground.material_override = ground_materials[candidate]
	grass_material = (meadow_materials[candidate] if grass_variant>0 else blade_materials[candidate]) if solid_grass else grass_materials[candidate]
	grass.multimesh.mesh = meadow_meshes[grass_variant] if solid_grass else cross_mesh
	grass.material_override = grass_material
	grass.visible = plants_enabled
	for material in ground_materials: material.set_shader_parameter("albedo_view",albedo_view)
	for material in grass_materials+blade_materials+meadow_materials:
		material.set_shader_parameter("albedo_view",albedo_view)
		material.set_shader_parameter("wind_strength",1. if wind_enabled else 0.)
	_update_grass()
	_status()

func _physics_process(delta: float) -> void:
	_update_camera(delta)

func _process(delta: float) -> void:
	clock += delta
	_update_grass()
	var at := hero.position
	if hero_contact.visible or not bool(get("combat_budget105")):
		var normal: Vector3 = meadow.normal_at(at.x,at.z,terrain_enabled)
		hero_contact.rotation = Vector3(atan2(-normal.z,normal.y),0,atan2(normal.x,normal.y))
	_status()

func _status() -> void:
	if not is_instance_valid(label): return
	label.text = "草与地形对照12 · %s · %s · %s\n7 贴地短草 / 8 弯叶高草 / 9 圆叶草 / 0 旧11草 · T 缓坡/平地 · H 高低变化 %s\n1—6 地皮 · J 实体/旧贴片 · G 草 · K 风 · L 原色/受光 · 滚轮缩放 · F1 隐藏\nWASD / Shift 移动 · C 跟随 · R 复位；新草根埋入地面、沿用脚下底色，缓坡有真实碰撞" % [titles[candidate],grass_names[grass_variant] if solid_grass else "旧透明贴片","连续缓坡" if terrain_enabled else "平地","开" if varied_height else "关"]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var previous_distance := camera_distance
		if event.button_index==MOUSE_BUTTON_WHEEL_UP: camera_distance = maxf(12.,camera_distance/1.1)
		if event.button_index==MOUSE_BUTTON_WHEEL_DOWN: camera_distance = minf(28.,camera_distance*1.1)
		if event.button_index==MOUSE_BUTTON_MIDDLE: camera_distance = 18.
		if not follow_camera:
			camera.position += camera.global_basis.z*(camera_distance-previous_distance)
	if not event is InputEventKey or not event.pressed or event.echo: return
	match event.physical_keycode:
		KEY_1: set_candidate(0)
		KEY_2: set_candidate(1)
		KEY_3: set_candidate(2)
		KEY_4: set_candidate(3)
		KEY_5: set_candidate(4)
		KEY_6: set_candidate(5)
		KEY_7,KEY_8,KEY_9,KEY_0:
			grass_variant = {KEY_7:1,KEY_8:2,KEY_9:3,KEY_0:0}[event.physical_keycode]
			solid_grass = true
			_refresh_planting()
			set_candidate(candidate)
		KEY_T:
			terrain_enabled = not terrain_enabled
			_rebuild_terrain()
		KEY_H:
			varied_height = not varied_height
			_refresh_planting()
		KEY_J:
			solid_grass = not solid_grass
			_refresh_planting()
			set_candidate(candidate)
		KEY_G:
			plants_enabled = not plants_enabled
			grass.visible = plants_enabled
		KEY_K:
			wind_enabled = not wind_enabled
			set_candidate(candidate)
		KEY_L:
			albedo_view = not albedo_view
			set_candidate(candidate)
		KEY_C: follow_camera = not follow_camera
		KEY_R:
			hero.position = Vector3(0,meadow.height_at(0,3,terrain_enabled)+.1,3)
			hero.velocity = Vector3.ZERO
			hero.reset_physics_interpolation()
			_update_camera(0,true)
		KEY_F1:
			label.visible = not label.visible
			label.get_parent().get_child(0).visible = label.visible
		KEY_ESCAPE: get_tree().quit()
