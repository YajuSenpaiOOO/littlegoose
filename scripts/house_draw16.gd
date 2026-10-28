extends "res://scripts/yard_route15.gd"
## Front-facing sprite audition. Pitch and yaw are deliberately separate.
var draw_ready := false
var draw_profiles: Dictionary = {}
var draw_textures: Dictionary = {}
var contact_marks: Array[Dictionary] = []
var house_contacts: Array[Dictionary] = []
var prop_volumes: Array[Node3D] = []
var last_contact_camera := Transform3D()
var last_contact_terrain := true
var house_fits := [
	{"id":"slate","name":"青灰石板 · 白墙木骨","height":4.9,"width":4.25,"eave":1.95,"peak":4.30,"depth":3.30,"hip":false},
	{"id":"shingle","name":"深木瓦 · 宽木屋","height":3.2,"width":5.60,"eave":1.50,"peak":2.60,"depth":3.20,"hip":true},
	{"id":"moss","name":"苔绿屋顶 · 老石屋","height":4.9,"width":4.40,"eave":1.90,"peak":4.35,"depth":3.20,"hip":false}
]

func _ready() -> void:
	super._ready()
	draw_profiles = JSON.parse_string(FileAccess.get_file_as_string("res://assets/house16/profiles.json"))
	for id in draw_profiles:
		var image := _imported_image(draw_profiles[id].file)
		image.generate_mipmaps()
		draw_textures[id] = ImageTexture.create_from_image(image)
	draw_ready = true
	house_names = []
	for fit in house_fits: house_names.append(fit.name)
	_build_prop_contacts()
	_set_house_variant(0)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--house="): _set_house_variant(int(arg.trim_prefix("--house=")))
	if not "--view=forest" in OS.get_cmdline_user_args(): _teleport15(Vector2(-4.7,-2.6))
	_update_prop_contacts()
	_status()

func _set_house_variant(index: int) -> void:
	if not draw_ready:
		super._set_house_variant(index)
		return
	house_variant = clampi(index,0,2)
	var fit: Dictionary = house_fits[house_variant]
	_replace_sprite(house_art,fit.id,fit.height,{"profiles":draw_profiles,"textures":draw_textures})
	house_art.rotation_degrees = Vector3(-25,0,0)
	# Each design gets its own footprint, eaves and roof pitch. No reused red-roof volume.
	for child in shadow_volume.get_children():
		shadow_volume.remove_child(child)
		child.queue_free()
	shadow_volume.scale = Vector3.ONE
	_shadow_box(shadow_volume,Vector3(fit.width,fit.eave,fit.depth),Vector3(0,fit.eave*.5,-fit.depth*.5-.12))
	var roof := MeshInstance3D.new()
	roof.mesh = _hip_mesh(fit.width+.38,fit.eave,fit.peak,fit.depth+.3) if fit.hip else _gable_mesh(fit.width+.38,fit.eave,fit.peak,fit.depth+.3)
	roof.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	shadow_volume.add_child(roof)
	_shadow_box(shadow_volume,Vector3(.42,.85,.42),Vector3(-2.0 if fit.hip else 1.55,2.65 if fit.hip else 3.65,-1.4))
	var collider: CollisionShape3D = cottage_body.get_child(0)
	collider.shape = BoxShape3D.new()
	collider.shape.size = Vector3(fit.width,fit.eave,fit.depth)
	collider.position = Vector3(0,fit.eave*.5,-fit.depth*.5-.12)
	var plinth := BoxMesh.new()
	plinth.size = Vector3(fit.width,.10,.22)
	foundation.mesh = plinth
	foundation.position = Vector3(0,.05,-.12)
	_set_house_contact()
	_rebuild_house_contacts()
	_bake_root_shade()
	_status()

func _gable_mesh(width: float,eave: float,peak: float,depth: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var a := Vector3(-width*.5,eave,0)
	var b := Vector3(0,peak,0)
	var c := Vector3(width*.5,eave,0)
	var back := Vector3(0,0,-depth)
	for triangle in [[a,b,c],[a+back,c+back,b+back],[a,a+back,b],[b,a+back,b+back],[b,b+back,c],[c,b+back,c+back]]:
		st.set_normal((triangle[2]-triangle[0]).cross(triangle[1]-triangle[0]).normalized())
		for p in triangle: st.add_vertex(p)
	return st.commit()

func _hip_mesh(width: float,eave: float,peak: float,depth: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var a := Vector3(-width*.5,eave,.04)
	var b := Vector3(width*.5,eave,.04)
	var c := Vector3(width*.5,eave,-depth)
	var d := Vector3(-width*.5,eave,-depth)
	var left := Vector3(-width*.28,peak,-depth*.5)
	var right := Vector3(width*.28,peak,-depth*.5)
	for triangle in [[a,b,left],[b,right,left],[b,c,right],[c,d,right],[d,left,right],[d,a,left]]:
		st.set_normal((triangle[2]-triangle[0]).cross(triangle[1]-triangle[0]).normalized())
		for p in triangle: st.add_vertex(p)
	return st.commit()

func _shadow_box(parent: Node3D,size: Vector3,at: Vector3) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	node.mesh = box
	node.position = at
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	parent.add_child(node)
	return node

func _set_house_contact() -> void:
	super._set_house_contact()
	# Painted stone already includes its sill; an extra generic visible slab doubles it.
	if draw_ready: foundation.hide()
	for foot in house_contacts: foot.mark.visible = contact_enabled

func _rebuild_house_contacts() -> void:
	for foot in house_contacts: foot.mark.queue_free()
	house_contacts.clear()
	var profile: Dictionary = draw_profiles[house_fits[house_variant].id]
	var bounds: Array = profile.bounds
	var image: Image = house_art.texture.get_image()
	for fraction in [.16,.32,.5,.68,.84]:
		var x := int(float(bounds[0])+float(bounds[2])*fraction)
		var bottom := 0
		for y in range(image.get_height()-1,0,-1):
			if image.get_pixel(x,y).a>=.5: bottom = y+1; break
		var mark := MeshInstance3D.new()
		var plane := PlaneMesh.new()
		plane.size = Vector2(1.05,.40)
		mark.mesh = plane
		var material := ShaderMaterial.new()
		material.shader = preload("res://scripts/art/foot_contact16.gdshader")
		mark.material_override = material
		mark.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(mark)
		house_contacts.append({"pixel":Vector2(x,bottom),"mark":mark})
	_update_prop_contacts()

func _fit_prop_box(volume: Node3D,index: int,size: Vector3,at: Vector3) -> void:
	if index>=volume.get_child_count():
		_shadow_box(volume,size,at)
	else:
		var node: MeshInstance3D = volume.get_child(index)
		node.mesh.size = size
		node.position = at

func _rebuild_root_pieces() -> void:
	# Retain tree-root geometry, but never squash furniture legs into a single band.
	var saved := props15.duplicate()
	props15.clear()
	super._rebuild_root_pieces()
	props15.assign(saved)
	for prop in props15:
		prop.sprite.position = Vector3.ZERO
		prop.sprite.material_override.set_shader_parameter("root_cut_y",1.)
		prop.sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	last_contact_camera = Transform3D()

func _build_prop_contacts() -> void:
	for prop in props15:
		var volume := Node3D.new()
		volume.name = "FootFittedShadow_"+prop.id
		prop.root.add_child(volume)
		prop_volumes.append(volume)
		var profile: Dictionary = extra_profiles[prop.id]
		var bounds: Array = profile.bounds
		var image: Image = prop.sprite.texture.get_image()
		var fractions: Array = {"bench":[.08,.24,.82,.96],"wood":[.065,.76,.92],"wall":[.12,.43,.84]}[prop.id]
		var feet: Array[Dictionary] = []
		for fraction in fractions:
			var x := int(float(bounds[0])+float(bounds[2])*float(fraction))
			var bottom := 0
			for y in range(image.get_height()-1,0,-1):
				if image.get_pixel(x,y).a>=.5: bottom = y+1; break
			var mark := MeshInstance3D.new()
			var plane := PlaneMesh.new()
			plane.size = Vector2(.34,.30) if prop.id!="wall" else Vector2(.65,.4)
			mark.mesh = plane
			var material := ShaderMaterial.new()
			material.shader = preload("res://scripts/art/foot_contact16.gdshader")
			mark.material_override = material
			mark.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			add_child(mark)
			var foot := {"pixel":Vector2(x,bottom),"mark":mark,"prop":prop,"world":Vector3.ZERO}
			contact_marks.append(foot)
			feet.append(foot)
		prop.feet16 = feet
		prop.volume16 = volume

func _pixel_world(sprite: Sprite3D,pixel: Vector2) -> Vector3:
	var local := Vector3((pixel.x-sprite.texture.get_width()*.5+sprite.offset.x)*sprite.pixel_size,(sprite.texture.get_height()*.5-pixel.y+sprite.offset.y)*sprite.pixel_size,0)
	return sprite.to_global(local)

func _ground_below_image(point: Vector3) -> Vector3:
	# Intersect the actual perspective ray through this painted foot with terrain.
	var origin := camera.global_position
	var direction := (point-origin).normalized()
	var distance := (meadow.height_at(point.x,point.z,terrain_enabled)-origin.y)/direction.y
	for i in 7:
		var at := origin+direction*distance
		distance = (meadow.height_at(at.x,at.z,terrain_enabled)-origin.y)/direction.y
	var hit := origin+direction*distance
	hit.y = meadow.height_at(hit.x,hit.z,terrain_enabled)+.014
	return hit

func _update_prop_contacts() -> void:
	for foot in house_contacts:
		foot.mark.position = _ground_below_image(_pixel_world(house_art,foot.pixel))
		foot.mark.visible = contact_enabled
	for foot in contact_marks:
		foot.world = _ground_below_image(_pixel_world(foot.prop.sprite,foot.pixel))
		foot.mark.position = foot.world
		foot.mark.visible = contact_enabled and props_enabled
	for prop in props15:
		if not prop.has("volume16"): continue
		var volume: Node3D = prop.volume16
		var box_index := 0
		var low := Vector3(INF,0,INF)
		var high := Vector3(-INF,0,-INF)
		for foot in prop.feet16:
			var p: Vector3 = prop.root.to_local(foot.world)
			low = low.min(p)
			high = high.max(p)
			if prop.id!="wall":
				_fit_prop_box(volume,box_index,Vector3(.12,prop.height*.48,.12),p+Vector3.UP*prop.height*.24)
				box_index += 1
		var center := (low+high)*.5
		var span := high-low
		if prop.id=="bench":
			_fit_prop_box(volume,box_index,Vector3(maxf(span.x,.5),.13,maxf(span.z,.32)),center+Vector3.UP*prop.height*.48)
			_fit_prop_box(volume,box_index+1,Vector3(maxf(span.x,.5),prop.height*.44,.10),Vector3(center.x,prop.height*.76,low.z))
		else:
			_fit_prop_box(volume,box_index,Vector3(maxf(span.x,.5),prop.height*.75,maxf(span.z,.3)),center+Vector3.UP*prop.height*.375)
		volume.visible = contact_enabled
	last_contact_camera = camera.global_transform
	last_contact_terrain = terrain_enabled

func set_contact(enabled: bool) -> void:
	super.set_contact(enabled)
	if draw_ready: _update_prop_contacts()

func _process(delta: float) -> void:
	super._process(delta)
	if draw_ready and (not camera.global_transform.is_equal_approx(last_contact_camera) or terrain_enabled!=last_contact_terrain):
		_update_prop_contacts()
	for foot in contact_marks: foot.mark.visible = contact_enabled and props_enabled

func _bake_root_shade() -> void:
	if not draw_ready:
		super._bake_root_shade()
		return
	var mask := Image.create(512,512,false,Image.FORMAT_RGBA8)
	mask.fill(Color(0,0,0,1))
	for tree in trees:
		if not tree.root.visible: continue
		var at: Vector3 = tree.root.position
		_stamp(mask,Vector2(at.x,at.z),Vector2(2.5,2.),0)
		_stamp(mask,Vector2(at.x,at.z),Vector2(.55,.4),1)
	var fit: Dictionary = house_fits[house_variant]
	_stamp(mask,Vector2(-4.7,-4.95),Vector2(fit.width*.48,.36),2)
	shade_texture = ImageTexture.create_from_image(mask)
	for material in ground_materials+meadow_materials: material.set_shader_parameter("forest_mask",shade_texture)
	for material in ground_materials: material.set_shader_parameter("forest_layout",true)

func _status() -> void:
	if not draw_ready:
		super._status()
		return
	label.text = "正面小屋16 · %s · 25°俯视 / 左右旋转0°\n1 青灰石板 / 2 深木瓦 / 3 苔绿屋顶 · Tab 换房 · V 接地投影 · P 摆件\nWASD / Shift 移动 · 滚轮缩放 · F3 屋前 / F2 林口 / R 起点\nM 混合草 · N 光影 · B 远林 · F 遮挡淡出 · F1 隐藏"%house_names[house_variant]

func _unhandled_input(event: InputEvent) -> void:
	if draw_ready and event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode==KEY_TAB:
			_set_house_variant((house_variant+1)%3)
			return
	super._unhandled_input(event)
	if draw_ready and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_P:
		_update_prop_contacts()
