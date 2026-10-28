extends Node3D
var world: Node3D
var profiles: Dictionary
var textures: Dictionary = {}
var selected := {"flowers":0,"shrubs":1,"stones":0}
var names := {"flowers":["小雏菊","蓝风铃","淡金花","粉苜蓿"],"shrubs":["野枝矮丛","林下蕨叶","蓝果小丛","蔷薇嫩枝"],"stones":["暖灰卵石","青灰圆石","微苔碎石","浅色石片"]}
var flower_batches: Array[MultiMeshInstance3D] = []
var planted: Array[Dictionary] = []
var stones: Array[Dictionary] = []
var catalog: Control
var choices: Dictionary = {}
var kick_enabled := true
var kick_count := 0
var previous_controls := true
var layout_revision := 0

func _ready() -> void:
	name="DecorCandidateSet42"
	profiles=JSON.parse_string(FileAccess.get_file_as_string("res://assets/decor42/profiles.json"))
	_load_preferences()
	for kind in ["flowers","shrubs","stones"]:
		var source: Image=load("res://assets/decor42/%s.png"%kind).get_image()
		if source.is_compressed(): source.decompress()
		textures[kind]=[]
		for profile in profiles[kind]:
			var cell: Array=profile.cell
			var image := source.get_region(Rect2i(cell[0],cell[1],cell[2],cell[3]))
			image.generate_mipmaps()
			textures[kind].append(ImageTexture.create_from_image(image))
	_build_flowers()
	_build_shrubs()
	_build_stones()
	_build_catalog()

func _mesh(kind: String,index: int) -> ArrayMesh:
	var profile: Dictionary=profiles[kind][index]
	var texture: Texture2D=textures[kind][index]
	var scale := 1./float(profile.height)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for uv in [Vector2(0,0),Vector2(0,1),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(1,0)]:
		st.set_uv(uv)
		st.set_normal(Vector3(0,.85,.53).normalized())
		st.add_vertex(Vector3((uv.x*texture.get_width()-profile.foot[0])*scale,(profile.foot[1]-uv.y*texture.get_height())*scale,0))
	return st.commit()

func _material(kind: String,index: int) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader=preload("res://scripts/art/decor_plant42.gdshader")
	material.set_shader_parameter("paint",textures[kind][index])
	material.set_shader_parameter("flex",.0 if kind=="stones" else .025)
	return material

func _build_flowers() -> void:
	var index: int=selected.flowers
	var batch := MultiMeshInstance3D.new()
	batch.name="ChosenLowFlowers"
	batch.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	batch.visibility_range_end=42.
	batch.extra_cull_margin=.2
	batch.material_override=_material("flowers",index)
	var multi := MultiMesh.new()
	multi.transform_format=MultiMesh.TRANSFORM_3D
	multi.mesh=_mesh("flowers",index)
	var positions: Array[Vector2]=[]
	var rng := RandomNumberGenerator.new()
	rng.seed=420042
	var colonies: Array[Vector2]=[Vector2(-8.8,-3.5),Vector2(-1.5,-4.),Vector2(-8.1,.8),Vector2(-10.2,.8),Vector2(-2.2,-1.),Vector2(1.4,-2.8),Vector2(3.7,-4.7),Vector2(4.4,-7.8)]
	var route: PackedVector2Array=world.meadow.route
	for i in range(6,mini(route.size(),34),6):
		var tangent := (route[i+1]-route[i-1]).normalized()
		colonies.append(route[i]+Vector2(-tangent.y,tangent.x)*1.3)
	for center in colonies:
		for i in rng.randi_range(4,7):
			var at := center+Vector2(rng.randf_range(-.65,.65),rng.randf_range(-.3,.3))
			if world.meadow.route_distance(at)<.92 or world.meadow.is_water(at): continue
			positions.append(at)
	multi.instance_count=positions.size()
	for i in positions.size():
		var at := positions[i]
		var height := rng.randf_range(.18,.29)
		var basis := Basis(Vector3.RIGHT,deg_to_rad(-25.)).scaled(Vector3(height,height,height))
		multi.set_instance_transform(i,Transform3D(basis,Vector3(at.x,world.floor_height(at)-.018,at.y)))
	batch.multimesh=multi
	add_child(batch)
	flower_batches.append(batch)

func _plant(at: Vector2,height: float) -> void:
	var index: int=selected.shrubs
	var profile: Dictionary=profiles.shrubs[index]
	var texture: Texture2D=textures.shrubs[index]
	var root := Node3D.new()
	root.position=Vector3(at.x,world.floor_height(at),at.y)
	add_child(root)
	var sprite: Sprite3D=world._sprite(texture,Vector2(profile.foot[0],profile.foot[1]),height,float(profile.height))
	sprite.billboard=BaseMaterial3D.BILLBOARD_DISABLED
	sprite.material_override=_material("shrubs",index)
	root.add_child(sprite)
	# Use the established root skirt rather than floating a wide baseline on slopes.
	var result: Dictionary=world.grounding.root_skirt(texture,profile,height,root.position,world.meadow,world.terrain_enabled,.035)
	sprite.position.y=-float(result.drop)
	sprite.material_override.set_shader_parameter("root_cut_y",result.cut)
	var roots := MeshInstance3D.new()
	roots.mesh=result.mesh
	roots.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	roots.material_override=_material("shrubs",index)
	roots.material_override.set_shader_parameter("flex",0.)
	root.add_child(roots)
	planted.append({"root":root,"sprite":sprite,"height":height})

func _build_shrubs() -> void:
	for spec in [Vector3(-9.2,.48,-4.4),Vector3(-10.1,.59,-2.9),Vector3(-10.6,.4,.9),Vector3(-1.,.44,-5.),Vector3(2.2,.57,-5.5),Vector3(4.8,.62,-8.),Vector3(5.6,.52,-12.)]:
		_plant(Vector2(spec.x,spec.z),spec.y)
	var route: PackedVector2Array=world.meadow.route
	for i in range(9,mini(route.size(),34),9):
		var tangent := (route[i+1]-route[i-1]).normalized()
		var at := route[i]+Vector2(-tangent.y,tangent.x)*2.05
		if world.meadow.route_distance(at)>1.4: _plant(at,.56)

func _build_stones() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed=420071
	var route: PackedVector2Array=world.meadow.route
	var samples := [1,3,6,9,13,17,21,25]
	for i in samples.size():
		var index := mini(int(samples[i]),route.size()-2)
		var tangent := (route[index+1]-route[index]).normalized()
		var at := route[index].lerp(route[index+1],.45)+Vector2(-tangent.y,tangent.x)*rng.randf_range(-.42,.42)
		if i==0: at=Vector2(-4.6,-1.9)
		var root := Node3D.new()
		root.position=Vector3(at.x,world.floor_height(at),at.y)
		add_child(root)
		var variant: int=selected.stones
		var height := rng.randf_range(.13,.19)
		var profile: Dictionary=profiles.stones[variant]
		var sprite: Sprite3D=world._sprite(textures.stones[variant],Vector2(profile.foot[0],profile.foot[1]),height,float(profile.height))
		sprite.billboard=BaseMaterial3D.BILLBOARD_DISABLED
		sprite.material_override=_material("stones",variant)
		sprite.position.y=-.012
		root.add_child(sprite)
		var contact := MeshInstance3D.new()
		var plane := PlaneMesh.new()
		plane.size=Vector2(height*1.25,height*.6)
		contact.mesh=plane
		var material := ShaderMaterial.new()
		material.shader=preload("res://scripts/art/foot_contact16.gdshader")
		contact.material_override=material
		contact.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		contact.position.y=.009
		root.add_child(contact)
		stones.append({"root":root,"sprite":sprite,"velocity":Vector2.ZERO,"lift":0.,"up":0.,"gate":0.,"home":at,"height":height})

func choose(kind: String,index: int) -> void:
	if not selected.has(kind) or index<0 or index>3: return
	selected[kind]=index
	if kind=="flowers":
		for batch in flower_batches: batch.queue_free()
		flower_batches.clear()
		_build_flowers()
	elif kind=="shrubs":
		for plant in planted: plant.root.queue_free()
		planted.clear()
		_build_shrubs()
	else:
		for stone in stones:
			var profile: Dictionary=profiles.stones[index]
			# Preserve the original world size instead of growing on each selection.
			world._replace_sprite(stone.sprite,str(index),stone.height,{"profiles":{str(index):profile},"textures":{str(index):textures.stones[index]}})
			stone.sprite.material_override.set_shader_parameter("flex",0.)
	layout_revision+=1
	_refresh_choices()

func _label(parent: Node,text: String,size: int) -> Label:
	var label := Label.new()
	label.text=text
	label.add_theme_font_size_override("font_size",size)
	label.add_theme_color_override("font_color",Color("e8e5ce"))
	label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _build_catalog() -> void:
	var layer := CanvasLayer.new()
	layer.layer=25
	layer.name="DecorationChoices42"
	add_child(layer)
	catalog=Control.new()
	catalog.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	catalog.mouse_filter=Control.MOUSE_FILTER_STOP
	layer.add_child(catalog)
	var veil := ColorRect.new()
	veil.color=Color(.025,.04,.035,.67)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	catalog.add_child(veil)
	var panel := Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left=-456; panel.offset_top=-337
	panel.offset_right=456; panel.offset_bottom=337
	var style := StyleBoxFlat.new()
	style.bg_color=Color("26382f")
	style.border_color=Color("64775d")
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	panel.add_theme_stylebox_override("panel",style)
	catalog.add_child(panel)
	_label(panel,"林间小物 · 候选素材",25).position=Vector2(26,18)
	_label(panel,"每类选四选一，点击后回到同一场景看搭配。",15).position=Vector2(27,57)
	var close := Button.new()
	close.text="回到场景"
	close.position=Vector2(770,23)
	close.size=Vector2(113,38)
	close.pressed.connect(toggle_catalog)
	panel.add_child(close)
	for row in 3:
		var kind: String=["flowers","shrubs","stones"][row]
		_label(panel,["低矮小花","林缘灌木","土径小石"][row],16).position=Vector2(28,96+row*164)
		choices[kind]=[]
		for index in 4:
			var button := Button.new()
			button.position=Vector2(132+index*187,91+row*164)
			button.size=Vector2(172,149)
			button.focus_mode=Control.FOCUS_NONE
			button.pressed.connect(_choose_from_catalog.bind(kind,index))
			panel.add_child(button)
			var preview := TextureRect.new()
			preview.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
			preview.texture=textures[kind][index]
			preview.position=Vector2(12,5)
			preview.size=Vector2(148,112)
			preview.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			preview.mouse_filter=Control.MOUSE_FILTER_IGNORE
			button.add_child(preview)
			var caption := _label(button,names[kind][index],15)
			caption.position=Vector2(0,117)
			caption.size=Vector2(172,26)
			caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
			choices[kind].append(button)
	var kicks := CheckButton.new()
	kicks.text="轻碰踢开石子（不阻挡角色，不影响弹丸）"
	kicks.position=Vector2(29,596)
	kicks.button_pressed=kick_enabled
	kicks.toggled.connect(func(value: bool): kick_enabled=value; _save_preferences())
	panel.add_child(kicks)
	_label(panel,"Ctrl+F2 / Esc 收起 · Ctrl+F12 柔光 · Alt+F12 景深（默认关闭）",14).position=Vector2(29,638)
	_refresh_choices()
	catalog.hide()

func _refresh_choices() -> void:
	for kind in choices:
		for i in 4:
			var style := StyleBoxFlat.new()
			style.bg_color=Color("40513d") if i==selected[kind] else Color("2e4035")
			style.border_color=Color("c4c993") if i==selected[kind] else Color("52644d")
			style.set_border_width_all(2 if i==selected[kind] else 1)
			style.set_corner_radius_all(7)
			for state in ["normal","hover","pressed"]: choices[kind][i].add_theme_stylebox_override(state,style)

func toggle_catalog() -> void:
	if catalog.visible:
		catalog.hide()
		world.hero.controls_enabled=previous_controls
	else:
		if world.wave_state!="waiting" or world.draft_open: return
		previous_controls=world.hero.controls_enabled
		world.hero.controls_enabled=false
		world.hero.locomotion=Vector2.ZERO
		world.hero.velocity.x=0.; world.hero.velocity.z=0.
		world._cancel_charge()
		catalog.show()

func _choose_from_catalog(kind: String,index: int) -> void:
	choose(kind,index)
	_save_preferences()

func _save_preferences() -> void:
	var file := FileAccess.open("user://decor42_choices.json",FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"selected":selected,"kick_enabled":kick_enabled}))

func _load_preferences() -> void:
	if not FileAccess.file_exists("user://decor42_choices.json"): return
	var value: Variant=JSON.parse_string(FileAccess.get_file_as_string("user://decor42_choices.json"))
	if not value is Dictionary: return
	var saved: Variant=value.get("selected",{})
	if saved is Dictionary:
		for kind in selected:
			if saved.has(kind): selected[kind]=clampi(int(saved[kind]),0,3)
	kick_enabled=bool(value.get("kick_enabled",true))

func set_enabled(value: bool) -> void:
	visible=value
	set_process(value)
	if not value and is_instance_valid(catalog) and catalog.visible: toggle_catalog()

func _process(delta: float) -> void:
	for batch in flower_batches:
		batch.material_override.set_shader_parameter("walker",world.hero.global_position)
		batch.material_override.set_shader_parameter("clock",world.clock)
	for plant in planted:
		plant.sprite.material_override.set_shader_parameter("walker",world.hero.global_position)
		plant.sprite.material_override.set_shader_parameter("clock",world.clock)
	if catalog.visible: return
	for stone in stones: _step_stone(stone,minf(delta,.05))

func _step_stone(stone: Dictionary,delta: float) -> void:
	var at := Vector2(stone.root.position.x,stone.root.position.z)
	var hero_at := Vector2(world.hero.position.x,world.hero.position.z)
	stone.gate=maxf(0.,stone.gate-delta)
	var motion := Vector2(world.hero.velocity.x,world.hero.velocity.z)
	if kick_enabled and stone.gate<=0. and at.distance_to(hero_at)<.32 and motion.length()>.6 and absf(world.hero.position.y-stone.root.position.y)<.6:
		stone.velocity=(motion.normalized()*.85+(at-hero_at).normalized()*.7).limit_length(1.6)
		stone.up=1.25
		stone.gate=.5
		kick_count+=1
	if stone.velocity.length_squared()<.0001 and stone.lift<=0.: return
	var next: Vector2=at+stone.velocity*delta
	var start: Vector3=stone.root.position+Vector3.UP*.15
	var query := PhysicsRayQueryParameters3D.create(start,Vector3(next.x,start.y,next.y),2)
	var hit: Dictionary=world.get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty() or world.meadow.is_water(next):
		stone.velocity*=-.25
		next=at
	stone.root.position=Vector3(next.x,world.floor_height(next),next.y)
	stone.velocity=stone.velocity.move_toward(Vector2.ZERO,2.3*delta)
	stone.up-=10.*delta
	stone.lift=maxf(0.,stone.lift+stone.up*delta)
	if stone.lift<=0.: stone.up=0.
	stone.sprite.position.y=stone.lift-.012
	stone.sprite.rotation.z=sin(world.clock*18.)*stone.velocity.length()*.08
