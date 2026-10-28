extends Node3D
## Real 3D foundation, fixed 25-degree perspective camera, painted billboard art.
var hero: CharacterBody3D
var camera: Camera3D
var sun: DirectionalLight3D
var ground: MeshInstance3D
var target: Area3D
var target_visual: Sprite3D
var grass: MultiMeshInstance3D
var grass_material: ShaderMaterial
var trees: Array[Dictionary] = []
var house_materials: Array[ShaderMaterial] = []
var shots: Array[Dictionary] = []
var label: Label
var crosshair: Control
var follow_camera := true
var fade_enabled := true
var camera_distance := 22.0
var hits := 0
var blocks := 0
var cooldown := 0.0
var hit_flash := 0.0
var clock := 0.0
var trail := PackedVector4Array()
var stamp_index := 0
var last_stamp := Vector3(1000,1000,1000)
var reference_posts: Array[MeshInstance3D] = []
var hero_contact: MeshInstance3D
var patch_grass: MultiMeshInstance3D
var quiet_ground := true
var plants_enabled := true
var house_meshes: Array[MeshInstance3D] = []
var house_art: Sprite3D
var painted_house := true
var painted_grass := true
var grass_profile: Dictionary

class Crosshair extends Control:
	func _draw() -> void:
		var at := get_local_mouse_position()
		draw_arc(at,8,0,TAU,24,Color("ffe2a2"),1.5,true)
		for axis in [Vector2.RIGHT,Vector2.DOWN]:
			draw_line(at+axis*11,at+axis*16,Color("ffe2a2"),1.5,true)
			draw_line(at-axis*11,at-axis*16,Color("ffe2a2"),1.5,true)

func _ready() -> void:
	get_tree().physics_interpolation = true
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	process_physics_priority = 100
	_build_lighting()
	_build_ground()
	_build_house()
	_build_house_art()
	_build_trees()
	_build_reference_posts()
	hero = preload("res://scripts/perspective_actor.gd").new()
	hero.position = Vector3(0,0.15,5)
	add_child(hero)
	_shadow_proxy(hero,1.4,0.18)
	hero_contact = _contact(hero)
	_build_target()
	_build_grass()
	camera = Camera3D.new()
	camera.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	camera.fov = 42
	camera.near = 0.1
	camera.far = 220
	camera.rotation_degrees.x = -25
	add_child(camera)
	camera.make_current()
	_update_camera(0,true)
	_build_ui()
	for i in 8: trail.append(Vector4(1000,1000,-100,1))
	var capture := ""
	for arg in OS.get_cmdline_user_args():
		if arg=="--orthographic": camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		if arg=="--view=slope": teleport(Vector3(10,0,-3))
		if arg=="--view=depth": teleport(Vector3(1,0,12))
		if arg=="--view=art":
			camera_distance = 18.
			teleport(Vector3(-1,0,1))
		if arg=="--old-ground": _set_ground_mode(false)
		if arg=="--model-house": _set_house_art(false)
		if arg.begins_with("--capture="): capture = arg.trim_prefix("--capture=")
	_update_camera(0,true)
	if not capture.is_empty(): _capture(capture)

func terrain_design_height(x: float,z: float) -> float:
	return 1.6*smoothstep(6.,8.,x)*(1.-smoothstep(14.,16.,x))*smoothstep(1.,8.,-z)

func terrain_height(x: float,z: float) -> float:
	# Use the same two triangles per cell as the actual collision mesh.
	var x0 := floorf(x/2.)*2.
	var z0 := floorf(z/2.)*2.
	var fx := (x-x0)/2.
	var fz := (z-z0)/2.
	var a := terrain_design_height(x0,z0)
	var b := terrain_design_height(x0+2,z0)
	var c := terrain_design_height(x0,z0+2)
	var d := terrain_design_height(x0+2,z0+2)
	return a+fx*(b-a)+fz*(c-a) if fx+fz<=1. else d+(1.-fx)*(c-d)+(1.-fz)*(b-d)

func _build_lighting() -> void:
	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("8fa4a1")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("b6c5d0")
	settings.ambient_light_energy = 0.50
	settings.fog_enabled = true
	settings.fog_density = .0025
	settings.fog_light_color = Color("9cadaa")
	settings.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	environment.environment = settings
	add_child(environment)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48,-32,0)
	sun.light_color = Color("fff4e1")
	sun.light_energy = 0.55
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 70
	add_child(sun)

func _build_ground() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var width := 121
	var depth := 161
	for iz in depth:
		for ix in width:
			var x := float(ix*2-120)
			var z := float(iz*2-260)
			var dx := (terrain_height(x+.05,z)-terrain_height(x-.05,z))/.1
			var dz := (terrain_height(x,z+.05)-terrain_height(x,z-.05))/.1
			st.set_normal(Vector3(-dx,1,-dz).normalized())
			st.set_uv(Vector2(x,z))
			st.add_vertex(Vector3(x,terrain_height(x,z),z))
	for iz in depth-1:
		for ix in width-1:
			var a := iz*width+ix
			# Godot front faces are clockwise; the collision surface must face up.
			for index in [a,a+1,a+width,a+1,a+width+1,a+width]: st.add_index(index)
	ground = MeshInstance3D.new()
	ground.name = "DetailedGroundWithSlope"
	ground.mesh = st.commit()
	var material := ShaderMaterial.new()
	material.shader = preload("res://scripts/art/perspective_ground.gdshader")
	var image := preload("res://assets/world_restart_v1/forest_floor.png").get_image()
	if image.is_compressed(): image.decompress()
	image.generate_mipmaps()
	material.set_shader_parameter("grass_texture",ImageTexture.create_from_image(image))
	material.set_shader_parameter("earth_texture",preload("res://assets/courtyard_v1/ground_materials_v2.png"))
	ground.material_override = material
	add_child(ground)
	ground.create_trimesh_collision()
	ground.get_child(0).collision_layer = 1
	# Playable test clearing; terrain continues beyond this small trial boundary.
	_box(Vector3(0,2,-27),Vector3(43,5,.3),Color.TRANSPARENT,true,false)
	_box(Vector3(0,2,19),Vector3(43,5,.3),Color.TRANSPARENT,true,false)
	for x in [-21.,21.]: _box(Vector3(x,2,-4),Vector3(.3,5,46),Color.TRANSPARENT,true,false)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1
	material.metallic_specular = 0
	return material

func _box(at: Vector3,size: Vector3,color: Color,solid := true,visible_mesh := true) -> MeshInstance3D:
	var box := MeshInstance3D.new()
	box.position = at
	var mesh := BoxMesh.new()
	mesh.size = size
	box.mesh = mesh
	box.material_override = _material(color)
	box.visible = visible_mesh
	add_child(box)
	if solid:
		var body := StaticBody3D.new()
		body.collision_layer = 2
		body.collision_mask = 4
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		body.add_child(collision)
		box.add_child(body)
	return box

func _house_part(at: Vector3,size: Vector3,color: Color,kind := 3) -> void:
	var box := _box(at,size,color,false)
	box.material_override = _house_material(color,kind)
	house_meshes.append(box)

func _house_material(color: Color,kind := 0) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = preload("res://scripts/art/perspective_solid.gdshader")
	material.set_shader_parameter("paint",color)
	material.set_shader_parameter("fade",1.0)
	material.set_shader_parameter("surface_kind",kind)
	house_materials.append(material)
	return material

func _build_house() -> void:
	var wall := _box(Vector3(-2,1.6,-9),Vector3(6,3.2,4),Color("e0c6a0"))
	wall.material_override = _house_material(Color("e0c6a0"),1)
	house_meshes.append(wall)
	# Gabled roof is real geometry; side faces change naturally in perspective.
	var a := Vector3(-5.4,3.2,-6.6)
	var b := Vector3(-2,4.9,-6.6)
	var c := Vector3(1.4,3.2,-6.6)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var back := Vector3(0,0,-4.8)
	for triangle in [[a,b,c],[a+back,c+back,b+back],[a,a+back,b],[b,a+back,b+back],[b,b+back,c],[c,b+back,c+back]]:
		st.set_normal((triangle[2]-triangle[0]).cross(triangle[1]-triangle[0]).normalized())
		for point in triangle: st.add_vertex(point)
	var roof := MeshInstance3D.new()
	roof.mesh = st.commit()
	roof.material_override = _house_material(Color("914a35"),2)
	add_child(roof)
	house_meshes.append(roof)
	roof.create_trimesh_collision()
	_house_part(Vector3(-2,1.05,-6.97),Vector3(1.05,2.1,.12),Color("64452f"))
	for x in [-4.,0.]:
		_house_part(Vector3(x,1.6,-6.94),Vector3(1.05,1.1,.16),Color("77553a"))
		_house_part(Vector3(x,1.6,-6.83),Vector3(.82,.88,.03),Color("ffd58a"),0)
		_house_part(Vector3(x,1.6,-6.78),Vector3(.06,.9,.05),Color("77553a"))
		_house_part(Vector3(x,1.6,-6.78),Vector3(.85,.06,.05),Color("77553a"))
	_house_part(Vector3(-2,.1,-6.5),Vector3(1.8,.2,.7),Color("9c927e"),1)
	for x in [-4.96,.96]:
		_house_part(Vector3(x,1.65,-6.86),Vector3(.12,3.1,.13),Color("78533c"))
	_house_part(Vector3(-2,2.65,-6.86),Vector3(.12,1.1,.13),Color("78533c"))
	for y in [.92,3.1]:
		_house_part(Vector3(-2,y,-6.85),Vector3(6,.13,.14),Color("78533c"))
	# Side walls receive their own projected material and timber, not a stretched facade.
	for x in [-5.04,1.04]:
		_house_part(Vector3(x,1.65,-9),Vector3(.12,3.1,.13),Color("78533c"))
		_house_part(Vector3(x,3.1,-9),Vector3(.13,.13,4),Color("78533c"))
	house_meshes.append(_box(Vector3(-4,4.5,-9.8),Vector3(.6,1.5,.7),Color("726c64"),false))
	# Calibration cubes are retired; the visible slope is the terrain itself.

func _build_house_art() -> void:
	var profile: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/perspective09/cottage_profile.json"))
	house_art = _sprite(load(profile.texture),Vector2(profile.foot[0],profile.foot[1]),5.8,float(profile.visible_height))
	house_art.name = "PaintedCottageCandidate"
	house_art.position = Vector3(-2,0,-6.58)
	add_child(house_art)
	_set_house_art(true)

func _set_house_art(painted: bool) -> void:
	painted_house = painted
	house_art.visible = painted
	for mesh in house_meshes:
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY if painted else GeometryInstance3D.SHADOW_CASTING_SETTING_ON

func _sprite(texture: Texture2D,foot: Vector2,height: float,visible_pixels: float) -> Sprite3D:
	var sprite := Sprite3D.new()
	sprite.texture = texture
	sprite.pixel_size = height/visible_pixels
	sprite.offset = Vector2(texture.get_width()/2.-foot.x,foot.y-texture.get_height()/2.)
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Fixed camera yaw: upright cutouts stay parallel to the camera's horizontal axis.
	# Explicit alpha discard and screen-door fading also work in Compatibility.
	var material := ShaderMaterial.new()
	material.shader = preload("res://scripts/art/perspective_cutout.gdshader")
	material.set_shader_parameter("paint",texture)
	material.set_shader_parameter("fade",1.0)
	sprite.material_override = material
	return sprite

func _build_trees() -> void:
	var texture := preload("res://assets/hero_environment_v1/oak.png")
	var image := texture.get_image()
	var root_bottom := 0
	for y in range(image.get_height()-1,-1,-1):
		for x in image.get_width():
			if image.get_pixel(x,y).a>=.5:
				root_bottom = y+1
				break
		if root_bottom>0: break
	var foot := Vector2(605,root_bottom+2)
	var positions := [Vector2(-7,2),Vector2(7,5),Vector2(-9,-8),Vector2(13,-11),Vector2(-12,10),Vector2(11,13),Vector2(-16,-20),Vector2(3,-23),Vector2(17,-24),Vector2(-7,-26)]
	for i in positions.size():
		var at: Vector2 = positions[i]
		var root := Node3D.new()
		root.position = Vector3(at.x,terrain_height(at.x,at.y),at.y)
		add_child(root)
		var height := 5.0+float(i%3)*.5
		# All opaque root tips must remain above the ground, not just the trunk centre.
		var sprite := _sprite(texture,foot,height,foot.y-75)
		root.add_child(sprite)
		var body := StaticBody3D.new()
		body.collision_layer = 2
		var collision := CollisionShape3D.new()
		var cylinder := CylinderShape3D.new()
		cylinder.radius = .4
		cylinder.height = 3
		collision.shape = cylinder
		collision.position.y = 1.5
		body.add_child(collision)
		root.add_child(body)
		_shadow_proxy(root,height,.3)
		var crown := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 1.65
		sphere.height = 2.8
		crown.mesh = sphere
		crown.position.y = height*.73
		crown.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		root.add_child(crown)
		trees.append({"root":root,"visual":sprite,"height":height})

func _shadow_proxy(parent: Node3D,height: float,radius: float) -> void:
	var proxy := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	proxy.mesh = mesh
	proxy.position.y = height/2
	proxy.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	parent.add_child(proxy)

func _contact(parent: Node3D) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = .23
	mesh.bottom_radius = .23
	mesh.height = .008
	node.mesh = mesh
	node.position.y = .025
	var material := _material(Color(0.08,.10,.13,.28))
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(node)
	return node

func _build_target() -> void:
	target = Area3D.new()
	target.name = "Target"
	target.position = Vector3(3,terrain_height(3,-1),-1)
	target.collision_layer = 8
	target.collision_mask = 0
	add_child(target)
	var shape := SphereShape3D.new()
	shape.radius = .58
	var collision := CollisionShape3D.new()
	collision.position.y = .65
	collision.shape = shape
	target.add_child(collision)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/tuantuan_v2/motion_v1.json")).idle
	target_visual = _sprite(load(data.texture),Vector2(data.foot[0],data.foot[1]),1.4,float(data.visible_height)/float(data.scale))
	target.add_child(target_visual)
	_shadow_proxy(target,1.1,.32)
	_contact(target)

func _build_reference_posts() -> void:
	# Exactly equal one-unit posts demonstrate perspective without art-size tricks.
	for z in [11.,1.,-11.]:
		var post := _box(Vector3(4.8,.5,z),Vector3(.45,1.,.45),Color("c6a46d"))
		post.visible = false
		post.get_child(0).collision_layer = 0
		reference_posts.append(post)

func _build_grass() -> void:
	grass_material = ShaderMaterial.new()
	grass_material.shader = preload("res://scripts/art/perspective_grass.gdshader")
	grass_material.set_shader_parameter("atlas",preload("res://assets/tiles/exterior.png"))
	grass_profile = JSON.parse_string(FileAccess.get_file_as_string("res://assets/perspective09/grass_profile.json"))
	var image := load(grass_profile.texture).get_image() as Image
	if image.is_compressed(): image.decompress()
	image.generate_mipmaps()
	grass_material.set_shader_parameter("painted_atlas",ImageTexture.create_from_image(image))
	var regions := PackedVector4Array()
	for cell in grass_profile.cells:
		var r: Array = cell.region
		regions.append(Vector4(float(r[0])/grass_profile.size[0],float(r[1])/grass_profile.size[1],float(r[2])/grass_profile.size[0],float(r[3])/grass_profile.size[1]))
	grass_material.set_shader_parameter("grass_regions",regions)
	grass = _grass_batch(4200,true)
	patch_grass = _grass_batch(900,false)
	_set_ground_mode(true)

func _grass_allowed(at: Vector2) -> bool:
	if absf(at.x-sin(at.y*.18)*1.2)<1.55: return false
	if at.x>-.2 and at.x<11.8 and absf(at.y-.7)<1.15: return false
	if absf(at.x-10.)<1.18 and at.y<1.2: return false
	if Rect2(-5.5,-11.5,7,5).has_point(at): return false
	for tree in trees:
		var root: Vector3 = tree.root.position
		if at.distance_to(Vector2(root.x,root.z))<.7: return false
	return true

func _grass_batch(count: int,spread: bool) -> MultiMeshInstance3D:
	var batch := MultiMeshInstance3D.new()
	batch.name = "PaintedMeadow4200" if spread else "LegacyPatchGrass900"
	var instances := MultiMesh.new()
	instances.transform_format = MultiMesh.TRANSFORM_3D
	instances.use_custom_data = true
	var quad := QuadMesh.new()
	quad.size = Vector2(.55,.55)
	quad.center_offset.y = .275
	instances.mesh = quad
	instances.instance_count = count
	batch.multimesh = instances
	batch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	batch.extra_cull_margin = .6
	batch.material_override = grass_material
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026101707
	var centers := [Vector2(-3.5,4),Vector2(3,8),Vector2(-5,-3),Vector2(7,1),Vector2(11,-5),Vector2(-8,10)]
	for i in count:
		var at := Vector2.ZERO
		for attempt in 100:
			at = Vector2(rng.randf_range(-20,20),rng.randf_range(-26,18)) if spread else centers[i%centers.size()]+Vector2(rng.randf_range(-2,2),rng.randf_range(-2.5,2.5))
			var density := clampf(.45+.3*sin(at.x*.7+sin(at.y*.37))+.25*cos(at.y*.5-at.x*.19),.10,1.)
			if _grass_allowed(at) and (not spread or rng.randf()<density): break
		if i==0: at = Vector2(-3.5,4)
		var basis := Basis.IDENTITY.scaled(Vector3(rng.randf_range(.55,1.15),rng.randf_range(.65,1.25) if spread else rng.randf_range(.7,1.5),1))
		if spread:
			var height := rng.randf_range(.17,.28) if i%8<4 else rng.randf_range(.29,.48)
			basis = Basis.IDENTITY.scaled(Vector3(height*float(grass_profile.cells[i%8].aspect)/.55,height/.55,1))
		instances.set_instance_transform(i,Transform3D(basis,Vector3(at.x,terrain_height(at.x,at.y)+.025,at.y)))
		instances.set_instance_custom_data(i,Color(float(i%8)/8.,0,0,1))
	add_child(batch)
	return batch

func _set_ground_mode(quiet: bool) -> void:
	quiet_ground = quiet
	ground.material_override.set_shader_parameter("quiet_ground",quiet)
	grass_material.set_shader_parameter("natural_blades",quiet)
	grass_material.set_shader_parameter("painted_grass",painted_grass and quiet)
	grass.visible = plants_enabled and quiet
	patch_grass.visible = plants_enabled and not quiet

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := ColorRect.new()
	panel.position = Vector2(22,get_viewport().get_visible_rect().size.y-155)
	panel.size = Vector2(1160,140)
	panel.color = Color(.06,.10,.12,.88)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(panel)
	label = Label.new()
	label.position = Vector2(38,get_viewport().get_visible_rect().size.y-145)
	label.add_theme_font_size_override("font_size",19)
	layer.add_child(label)
	crosshair = Crosshair.new()
	crosshair.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(crosshair)
	_status()

func _physics_process(delta: float) -> void:
	_update_camera(delta)
	cooldown = maxf(0,cooldown-delta)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and cooldown<=0:
		var hit := pick_screen(get_viewport().get_mouse_position())
		if not hit.is_empty(): fire_at(hit.position)
		cooldown = .2
	_step_shots(delta)

func _process(delta: float) -> void:
	clock += delta
	_update_grass()
	_update_occlusion(delta)
	hit_flash = maxf(0,hit_flash-delta)
	target_visual.modulate = Color(1,.65,.5) if hit_flash>0 else Color.WHITE
	# Contact follows the actual terrain normal under the capsule.
	var at := hero.position
	var dx := (terrain_height(at.x+.1,at.z)-terrain_height(at.x-.1,at.z))/.2
	var dz := (terrain_height(at.x,at.z+.1)-terrain_height(at.x,at.z-.1))/.2
	hero_contact.rotation = Vector3(atan(dz),0,-atan(dx))
	crosshair.queue_redraw()
	_status()

func _update_camera(delta: float,snap := false) -> void:
	if camera.projection==Camera3D.PROJECTION_ORTHOGONAL:
		camera.size = 2.*camera_distance*tan(deg_to_rad(camera.fov/2.))
	if not follow_camera: return
	var focus := hero.position+Vector3(0,.85,0)
	var offset := Vector3(0,sin(deg_to_rad(25.)),cos(deg_to_rad(25.)))*camera_distance
	var desired := focus+offset
	camera.position = desired if snap else camera.position.lerp(desired,1.-exp(-delta*9.))
	if snap: camera.reset_physics_interpolation()

func pick_screen(point: Vector2) -> Dictionary:
	var start := camera.project_ray_origin(point)
	var query := PhysicsRayQueryParameters3D.create(start,start+camera.project_ray_normal(point)*200.,11,[hero.get_rid()])
	query.collide_with_areas = true
	return get_world_3d().direct_space_state.intersect_ray(query)

func _projectile_mesh_enabled24() -> bool: return true
func _projectile_node110() -> Variant: return MeshInstance3D.new()
func _attach_projectile110(node: Variant) -> void:
	add_child(node)
	node.reset_physics_interpolation()
func _projectile_record110(node: Variant,velocity: Vector3) -> Dictionary:
	return {"node":node,"velocity":velocity,"life":3.0}

func fire_at(destination: Vector3) -> void:
	var origin := projectile_origin()
	if origin.distance_to(destination)<.05: return
	var node: Variant = _projectile_node110()
	if _projectile_mesh_enabled24():
		var mesh := SphereMesh.new()
		mesh.radius = .075
		mesh.height = .15
		node.mesh = mesh
		var material := _material(Color("ffe3a2"))
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		node.material_override = material
	node.position = origin
	node.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	_attach_projectile110(node)
	shots.append(_projectile_record110(node,origin.direction_to(destination)*22.))

func projectile_origin() -> Vector3:
	return hero.position+Vector3(0,.85,0)

func _step_shots(delta: float) -> void:
	for i in range(shots.size()-1,-1,-1):
		var shot := shots[i]
		var start: Vector3 = shot.node.position
		var end: Vector3 = start+shot.velocity*delta
		var query := PhysicsRayQueryParameters3D.create(start,end,11,[hero.get_rid()])
		query.collide_with_areas = true
		var hit := get_world_3d().direct_space_state.intersect_ray(query)
		shot.life -= delta
		if not hit.is_empty():
			if hit.collider==target:
				hits += 1
				hit_flash = .15
			else: blocks += 1
		if not hit.is_empty() or shot.life<=0:
			shot.node.queue_free()
			shots.remove_at(i)
		else: shot.node.position = end

func _update_grass() -> void:
	if not plants_enabled: return
	var at := hero.get_global_transform_interpolated().origin
	if at.distance_to(last_stamp)>3:
		for i in trail.size(): trail[i] = Vector4(1000,1000,-100,1)
	if at.distance_to(last_stamp)>.15:
		trail[stamp_index] = Vector4(at.x,at.z,clock,1. if at.x>=last_stamp.x else -1.)
		stamp_index = (stamp_index+1)%8
		last_stamp = at
	var low := Vector2(at.x,at.z)-Vector2.ONE*.7
	var high := low+Vector2.ONE*1.4
	for point in trail:
		if clock-point.z<.9:
			low = low.min(Vector2(point.x,point.y)-Vector2.ONE*.65)
			high = high.max(Vector2(point.x,point.y)+Vector2.ONE*.65)
	grass_material.set_shader_parameter("walker",at)
	grass_material.set_shader_parameter("clock",clock)
	grass_material.set_shader_parameter("trail",trail)
	grass_material.set_shader_parameter("touch_bounds",Vector4(low.x,low.y,high.x,high.y))

func _update_occlusion(delta: float) -> void:
	var head := camera.unproject_position(hero.position+Vector3(0,.9,0))
	for tree in trees:
		var root: Vector3 = tree.root.position
		if camera.is_position_behind(root) or camera.is_position_behind(root+Vector3.UP*tree.height):
			tree.visual.material_override.set_shader_parameter("fade",1.0)
			continue
		var top := camera.unproject_position(root+Vector3.UP*tree.height)
		var foot := camera.unproject_position(root)
		var side := camera.unproject_position(root+Vector3.RIGHT*tree.height*.45)
		var rect := Rect2(Vector2(foot.x-absf(side.x-foot.x),top.y),Vector2(absf(side.x-foot.x)*2,foot.y-top.y)).abs()
		var obscures: bool = fade_enabled and root.z>hero.position.z and rect.has_point(head)
		var material: ShaderMaterial = tree.visual.material_override
		var alpha: float = material.get_shader_parameter("fade")
		material.set_shader_parameter("fade",move_toward(alpha,.22 if obscures else 1.,delta*4))
	var ray := PhysicsRayQueryParameters3D.create(camera.position,hero.position+Vector3(0,.9,0),2,[hero.get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(ray)
	var house_blocks: bool = fade_enabled and not hit.is_empty() and hit.position.x>=-5.5 and hit.position.x<=1.5 and hit.position.z< -6.5
	for material in house_materials:
		var alpha: float = material.get_shader_parameter("fade")
		material.set_shader_parameter("fade",move_toward(alpha,.22 if house_blocks else 1.,delta*4))
	var house_fade: float = house_art.material_override.get_shader_parameter("fade")
	house_art.material_override.set_shader_parameter("fade",move_toward(house_fade,.22 if house_blocks else 1.,delta*4))

func _status() -> void:
	label.text = "3D美术对照09 · 25°%s · %s\nWASD 移动 / Shift 快走 / 左键射击 / 滚轮缩放 / 中键复位 / F1 隐藏说明\nB 房屋贴片↔体块 · J 新旧草形 · V 地面 · P 透视↔正交 · C 跟随 %s · G 草 · O 影\n命中 %d / 拦截 %d · 新生成小屋与草叶为候选美术；整屋贴片侧面不会随视点变化" % ["透视" if camera.projection==Camera3D.PROJECTION_PERSPECTIVE else "正交","有纹理地表＋分疏密草叶" if quiet_ground else "旧地皮＋局部草","开" if follow_camera else "关",hits,blocks]

func teleport(at: Vector3) -> void:
	hero.position = at+Vector3(0,terrain_height(at.x,at.z)+.1,0)
	hero.velocity = Vector3.ZERO
	hero.reset_physics_interpolation()
	_update_camera(0,true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var previous_distance := camera_distance
		if event.button_index==MOUSE_BUTTON_WHEEL_UP: camera_distance = maxf(13.,camera_distance/1.10)
		if event.button_index==MOUSE_BUTTON_WHEEL_DOWN: camera_distance = minf(34.,camera_distance*1.10)
		if event.button_index==MOUSE_BUTTON_MIDDLE:
			camera_distance = 22.
			_update_camera(0,true)
		if not follow_camera:
			camera.position += camera.global_basis.z*(camera_distance-previous_distance)
			_update_camera(0)
	if not event is InputEventKey or not event.pressed or event.echo: return
	match event.physical_keycode:
		KEY_B: _set_house_art(not painted_house)
		KEY_J:
			painted_grass = not painted_grass
			_set_ground_mode(quiet_ground)
		KEY_P:
			camera.projection = Camera3D.PROJECTION_ORTHOGONAL if camera.projection==Camera3D.PROJECTION_PERSPECTIVE else Camera3D.PROJECTION_PERSPECTIVE
			camera.size = 2.*camera_distance*tan(deg_to_rad(camera.fov/2.))
		KEY_C: follow_camera = not follow_camera
		KEY_F: fade_enabled = not fade_enabled
		KEY_G:
			plants_enabled = not plants_enabled
			_set_ground_mode(quiet_ground)
		KEY_V: _set_ground_mode(not quiet_ground)
		KEY_O: sun.shadow_enabled = not sun.shadow_enabled
		KEY_F1:
			label.visible = not label.visible
			label.get_parent().get_child(0).visible = label.visible
		KEY_1,KEY_R: teleport(Vector3(0,0,5))
		KEY_2: teleport(Vector3(10,0,1))
		KEY_3: teleport(Vector3(-3,0,4))
		KEY_4: teleport(Vector3(1,0,12))
		KEY_ESCAPE: get_tree().quit()

func _capture(path: String) -> void:
	for i in 40: await get_tree().physics_frame
	set_process(false)
	set_physics_process(false)
	hero.set_physics_process(false)
	_update_camera(0,true)
	crosshair.hide()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var result := get_viewport().get_texture().get_image().save_png(path)
	print("PERSPECTIVE_CAPTURE ",path," result=",result)
	get_tree().quit(0 if result==OK else 1)
