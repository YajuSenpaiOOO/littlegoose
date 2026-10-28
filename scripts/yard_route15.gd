extends "res://scripts/forest_styles14.gd"
## Selected style A: grounded roots, two camera-fit cottages and a mapped route slice.
var grounding = preload("res://scripts/art/grounding15.gd").new()
var contact_enabled := true
var props_enabled := true
var house_variant := 1
var house_names := ["A · 远景机位参照","B · 屋前25°参照","原14正面贴片"]
var extra_profiles: Dictionary = {}
var extra_textures: Dictionary = {}
var root_pieces: Array[Dictionary] = []
var props15: Array[Dictionary] = []
var foundation: MeshInstance3D
var shadow_volume: Node3D
var slice_ready := false

func _build_lab_floor() -> void:
	meadow = preload("res://scripts/art/home_route15.gd").new()
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
	for x in [-16.,16.]: _box(Vector3(x,2,-10),Vector3(.3,5,52),Color.TRANSPARENT,true,false)
	for z in [-36.,16.]: _box(Vector3(0,2,z),Vector3(32,5,.3),Color.TRANSPARENT,true,false)

func _build_lab_grass() -> void:
	super._build_lab_grass()
	var source := planting.duplicate()
	var colors: Array[Color] = []
	for i in source.size(): colors.append(grass.multimesh.get_instance_custom_data(i))
	planting.clear()
	var kept: Array[Color] = []
	for i in source.size():
		var at: Vector3 = source[i].origin
		if meadow.route_distance(Vector2(at.x,at.z))<1.05: continue
		if Vector2(at.x,at.z).distance_to(Vector2(7,-7))<1.4: continue
		if at.x< -6.2 and at.z> -.8 and at.z<1.: continue
		planting.append(source[i])
		kept.append(colors[i])
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026101615
	while planting.size()<5600:
		var at := Vector2(rng.randf_range(-14,14),rng.randf_range(-33,-14))
		if meadow.route_distance(at)<1.05: continue
		var basis := Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3(rng.randf_range(.7,1.1),rng.randf_range(.6,1.05),1))
		planting.append(Transform3D(basis,Vector3(at.x,0,at.y)))
		var seed_value := rng.randf()
		kept.append(Color(0,seed_value,1. if seed_value<.32 else 0.,1))
	grass.multimesh.instance_count = planting.size()
	for i in planting.size():
		grass.multimesh.set_instance_transform(i,planting[i])
		grass.multimesh.set_instance_custom_data(i,kept[i])

func _build_woodland() -> void:
	super._build_woodland()
	# Reopen the path through old rear ranks rather than placing trunks across it.
	for tree in trees:
		var at: Vector3 = tree.root.position
		if meadow.route_distance(Vector2(at.x,at.z))<2.25:
			at.x += -3.8 if at.x< -.5 else 3.8
			tree.root.position = Vector3(at.x,meadow.height_at(at.x,at.z,terrain_enabled),at.z)
	var rng := RandomNumberGenerator.new()
	rng.seed = 150015
	for row in 7:
		for side in [-1.,1.]:
			_add_route_tree(Vector2(side*(5.2+rng.randf_range(0,2.3)),-15.-float(row)*2.65),5.4+rng.randf()*.9)
	for row in 2:
		for col in 10: _add_route_tree(Vector2(-18.+float(col)*3.9,-34.-float(row)*3.8),6.3+rng.randf())

func _add_route_tree(at: Vector2,height: float) -> void:
	if meadow.route_distance(at)<2.3: at.x += 3.5
	var root := Node3D.new()
	root.position = Vector3(at.x,meadow.height_at(at.x,at.y,terrain_enabled),at.y)
	add_child(root)
	var visual := _art("oak",height)
	root.add_child(visual)
	var body := StaticBody3D.new()
	body.collision_layer = 2
	var collider := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = .35
	cylinder.height = 2.6
	collider.shape = cylinder
	collider.position.y = 1.3
	body.add_child(collider)
	root.add_child(body)
	trees.append({"root":root,"visual":visual,"height":height})
	distant_roots.append(root)

func _ready() -> void:
	art_style = 1
	super._ready()
	set_art_style(1)
	extra_profiles = JSON.parse_string(FileAccess.get_file_as_string("res://assets/yard15/profiles.json"))
	for id in extra_profiles:
		var profile: Dictionary = extra_profiles[id]
		var image := _imported_image(profile.file)
		if profile.has("cell"):
			var r: Array = profile.cell
			image = image.get_region(Rect2i(r[0],r[1],r[2],r[3]))
			var padded := Image.create(image.get_width()+8,image.get_height()+8,false,Image.FORMAT_RGBA8)
			padded.fill(Color.TRANSPARENT)
			padded.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),Vector2i(4,4))
			image = padded
		image.generate_mipmaps()
		extra_textures[id] = ImageTexture.create_from_image(image)
	for i in trees.size():
		if i>=89 or i in [81,83,85,87]:
			var id := "tree_%d"%(i%3)
			_replace_sprite(trees[i].visual,id,trees[i].height,{"profiles":extra_profiles,"textures":extra_textures})
			trees[i].extra_id = id
	_build_foundation()
	_build_props15()
	_configure_route()
	slice_ready = true
	_rebuild_root_pieces()
	_set_house_variant(1)
	_bake_root_shade()
	for arg in OS.get_cmdline_user_args():
		if arg=="--old-contact": set_contact(false)
		if arg.begins_with("--house="): _set_house_variant(clampi(int(arg.trim_prefix("--house=")),0,2))
		if arg=="--view=door": _teleport15(Vector2(-4.7,-2.6))
		if arg=="--view=forest": _teleport15(meadow.main_route[-1])
	_status()

func _configure_route() -> void:
	var segments := PackedVector4Array()
	for i in range(meadow.route.size()-1):
		var a: Vector2 = meadow.route[i]
		var b: Vector2 = meadow.route[i+1]
		segments.append(Vector4(a.x,a.y,b.x,b.y))
	var count := segments.size()
	while segments.size()<32: segments.append(Vector4.ZERO)
	for material in ground_materials:
		material.set_shader_parameter("route_layout",true)
		material.set_shader_parameter("route_segments",segments)
		material.set_shader_parameter("route_count",count)

func _build_foundation() -> void:
	foundation = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(4.12,.17,.30)
	foundation.mesh = box
	foundation.position = Vector3(-.08,.085,-.26)
	var stone := ShaderMaterial.new()
	stone.shader = preload("res://scripts/art/foundation15.gdshader")
	foundation.material_override = stone
	cottage_root.add_child(foundation)
	shadow_volume = Node3D.new()
	shadow_volume.name = "GabledBuildingShadowVolume"
	shadow_volume.scale = Vector3(.76,1.,.80)
	cottage_root.add_child(shadow_volume)
	var collider: CollisionShape3D = cottage_body.get_child(0)
	collider.shape.size = Vector3(4.6,3.8,3.)
	collider.position = Vector3(0,1.9,-1.9)
	var wall := MeshInstance3D.new()
	var volume := BoxMesh.new()
	volume.size = Vector3(6.1,2.9,3.8)
	wall.mesh = volume
	wall.position = Vector3(0,1.45,-1.9)
	wall.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	shadow_volume.add_child(wall)
	var roof := MeshInstance3D.new()
	roof.mesh = grounding.roof_shadow()
	roof.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	shadow_volume.add_child(roof)

func _set_house_variant(index: int) -> void:
	house_variant = clampi(index,0,2)
	if house_variant<2:
		_replace_sprite(house_art,"cottage_a" if house_variant==0 else "cottage_b",4.9,{"profiles":extra_profiles,"textures":extra_textures})
	else: _replace_sprite(house_art,"cottage",4.9,style_packs[1])
	_set_house_contact()

func _set_house_contact() -> void:
	if not is_instance_valid(foundation): return
	foundation.visible = contact_enabled
	shadow_volume.visible = contact_enabled
	house_art.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if contact_enabled else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	var material: ShaderMaterial = house_art.material_override
	material.shader = preload("res://scripts/art/cottage_cutout15.gdshader") if contact_enabled else preload("res://scripts/art/forest_cutout13.gdshader")
	material.set_shader_parameter("paint",house_art.texture)
	material.set_shader_parameter("fade",1.)

func _rebuild_root_pieces() -> void:
	for piece in root_pieces:
		piece.node.get_parent().remove_child(piece.node)
		piece.node.queue_free()
	root_pieces.clear()
	for i in trees.size():
		var tree: Dictionary = trees[i]
		var sprite: Sprite3D = tree.visual
		var profile: Dictionary = extra_profiles[tree.extra_id] if tree.has("extra_id") else style_packs[1].profiles["oak" if i%3!=1 else "young"]
		var result: Dictionary = grounding.root_skirt(sprite.texture,profile,tree.height,tree.root.position,meadow,terrain_enabled)
		for child in tree.root.get_children():
			if child is StaticBody3D:
				child.get_child(0).position.x = float(result.collider_x)
		var patch := MeshInstance3D.new()
		patch.name = "RootsOnTerrain"
		patch.mesh = result.mesh
		patch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var material: ShaderMaterial = sprite.material_override.duplicate()
		material.set_shader_parameter("root_cut_y",1.)
		patch.material_override = material
		tree.root.add_child(patch)
		root_pieces.append({"node":patch,"sprite":sprite,"drop":result.drop,"cut":result.cut})
	for prop in props15:
		var sprite: Sprite3D = prop.sprite
		var result: Dictionary = grounding.root_skirt(sprite.texture,extra_profiles[prop.id],prop.height,prop.root.position,meadow,terrain_enabled,.12)
		var patch := MeshInstance3D.new()
		patch.mesh = result.mesh
		patch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var material: ShaderMaterial = sprite.material_override.duplicate()
		material.set_shader_parameter("root_cut_y",1.)
		patch.material_override = material
		prop.root.add_child(patch)
		root_pieces.append({"node":patch,"sprite":sprite,"drop":result.drop,"cut":result.cut})
	_apply_root_contact()

func _apply_root_contact() -> void:
	for piece in root_pieces:
		piece.node.visible = contact_enabled
		piece.sprite.position.y = -float(piece.drop) if contact_enabled else 0.
		piece.sprite.material_override.set_shader_parameter("root_cut_y",float(piece.cut) if contact_enabled else 1.)

func set_contact(enabled: bool) -> void:
	contact_enabled = enabled
	_apply_root_contact()
	_set_house_contact()

func _build_props15() -> void:
	_add_prop15("wood",Vector2(-7.9,-4.45),.95,Vector3(1.5,.8,.65))
	_add_prop15("bench",Vector2(7,-7),1.15,Vector3(2.1,.8,.65))
	_add_prop15("wall",Vector2(-7.4,.0),.75,Vector3(2.5,.7,.65))
	_add_prop15("wall",Vector2(-10.,.15),.72,Vector3(2.4,.7,.65))

func _add_prop15(id: String,at: Vector2,height: float,size: Vector3) -> void:
	var root := Node3D.new()
	root.position = Vector3(at.x,meadow.height_at(at.x,at.y,terrain_enabled),at.y)
	add_child(root)
	var profile: Dictionary = extra_profiles[id]
	var sprite := _sprite(extra_textures[id],Vector2(profile.foot[0],profile.foot[1]),height,float(profile.height))
	root.add_child(sprite)
	var material := ShaderMaterial.new()
	material.shader = preload("res://scripts/art/forest_cutout13.gdshader")
	material.set_shader_parameter("paint",extra_textures[id])
	material.set_shader_parameter("fade",1.)
	sprite.material_override = material
	sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	var body := StaticBody3D.new()
	body.collision_layer = 2
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	collider.position.y = size.y/2.
	body.add_child(collider)
	root.add_child(body)
	props15.append({"root":root,"body":body,"size":size,"sprite":sprite,"id":id,"height":height})

func _bake_root_shade() -> void:
	super._bake_root_shade()
	if props15.is_empty(): return
	var mask := shade_texture.get_image()
	for prop in props15:
		if not prop.root.visible: continue
		var at: Vector3 = prop.root.position
		_stamp(mask,Vector2(at.x,at.z),Vector2(prop.size.x*.5,.38),1)
	shade_texture.update(mask)

func _rebuild_terrain() -> void:
	super._rebuild_terrain()
	if not slice_ready: return
	for prop in props15:
		var at: Vector3 = prop.root.position
		prop.root.position.y = meadow.height_at(at.x,at.z,terrain_enabled)
	_rebuild_root_pieces()

func _process(delta: float) -> void:
	super._process(delta)
	_sync_root_fades15()

func _sync_root_fades15() -> void:
	for piece in root_pieces:
		var fade: float = piece.sprite.material_override.get_shader_parameter("fade")
		piece.node.material_override.set_shader_parameter("fade",fade)

func _teleport15(at: Vector2) -> void:
	hero.position = Vector3(at.x,meadow.height_at(at.x,at.y,terrain_enabled)+.08,at.y)
	hero.velocity = Vector3.ZERO
	hero.reset_physics_interpolation()
	_update_camera(0,true)

func _status() -> void:
	if not is_instance_valid(label): return
	label.text = "小屋—林间道路15 · 2号轻像素风 · %s · 接地 %s\n1 远景参照房 / 2 屋前参照房 / 3 原14房 · V 接地/投影对照 · P 摆件\nWASD / Shift 移动 · 滚轮缩放 · M 混合草 · B 远林 · N 光影 · F 遮挡淡出\nF2 林口 / F3 屋前 · R 起点 · F1 隐藏；沿道路可从小屋走到林口" % [house_names[house_variant],"开" if contact_enabled else "原贴片"]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_1: _set_house_variant(0); return
			KEY_2: _set_house_variant(1); return
			KEY_3: _set_house_variant(2); return
			KEY_4,KEY_5,KEY_6,KEY_TAB: return
			KEY_V: set_contact(not contact_enabled); return
			KEY_P:
				props_enabled = not props_enabled
				for prop in props15:
					prop.root.visible = props_enabled
					prop.body.collision_layer = 2 if props_enabled else 0
				_bake_root_shade()
				return
			KEY_F2: _teleport15(meadow.main_route[-1]); return
	super._unhandled_input(event)
