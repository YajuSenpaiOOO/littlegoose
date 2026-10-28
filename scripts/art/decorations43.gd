extends "res://scripts/art/decorations42.gd"
var layer_stage := 2
var stems_loaded := false
var stage_buttons: Array[Button]=[]
var focus_description: Label

func _build_flowers() -> void:
	if not stems_loaded:
		profiles.flowers=JSON.parse_string(FileAccess.get_file_as_string("res://assets/vegetation43/profiles.json"))
		var source: Image=preload("res://assets/vegetation43/flower_stems.png").get_image()
		if source.is_compressed(): source.decompress()
		textures.flowers.clear()
		for profile in profiles.flowers:
			var cell: Array=profile.cell
			var image := source.get_region(Rect2i(cell[0],cell[1],cell[2],cell[3]))
			image.generate_mipmaps()
			textures.flowers.append(ImageTexture.create_from_image(image))
		stems_loaded=true
	# Sparse individual stems among real grass, without a painted grass skirt.
	var positions: Array[Vector2]=[Vector2(-8.9,-3.1),Vector2(-8.5,-2.9),Vector2(-10.,.9),Vector2(-9.6,1.1),Vector2(-1.5,-3.6),Vector2(-1.9,-3.4),Vector2(1.8,-3.8),Vector2(2.1,-4.1),Vector2(3.1,-6.9),Vector2(3.4,-6.7),Vector2(7.9,-12.4),Vector2(8.2,-12.6)]
	var rng := RandomNumberGenerator.new()
	rng.seed=430061
	for variant in 4:
		var batch := MultiMeshInstance3D.new()
		batch.name="BareStemFlowers%d"%variant
		batch.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		batch.visibility_range_end=42.
		batch.extra_cull_margin=.3
		batch.material_override=_material("flowers",variant)
		var multi := MultiMesh.new()
		multi.transform_format=MultiMesh.TRANSFORM_3D
		multi.mesh=_mesh("flowers",variant)
		multi.instance_count=3
		for i in 3:
			var at := positions[variant+i*4]
			var height := rng.randf_range(.44,.65)
			var basis := Basis(Vector3.RIGHT,deg_to_rad(-25.)).scaled(Vector3(height,height,height))
			multi.set_instance_transform(i,Transform3D(basis,Vector3(at.x,world.floor_height(at)-.018,at.y)))
		batch.multimesh=multi
		add_child(batch)
		flower_batches.append(batch)

func _build_shrubs() -> void:
	var previous: int=selected.shrubs
	var specs := [Vector3(-10.8,1.02,-5.),Vector3(-10.6,1.18,-2.8),Vector3(-10.6,.90,.9),Vector3(.0,.98,-5.),Vector3(2.1,1.12,-6.9),Vector3(3.7,1.20,-10.3),Vector3(8.9,1.06,-14.4)]
	for i in specs.size():
		var spec: Vector3=specs[i]
		var at := Vector2(spec.x,spec.z)
		if world.meadow.route_distance(at)<1.5: continue
		selected.shrubs=2 if i%3==2 else 0
		_plant(at,spec.y)
	var route: PackedVector2Array=world.meadow.route
	for i in range(15,mini(route.size(),34),8):
		var tangent := (route[i+1]-route[i-1]).normalized()
		var at := route[i]+Vector2(-tangent.y,tangent.x)*2.4
		if world.meadow.route_distance(at)>1.5:
			selected.shrubs=0
			_plant(at,1.05)
	selected.shrubs=previous

func _build_stones() -> void:
	super._build_stones()
	var variants := [0,1,2,3,0,1,2,3]
	var rng := RandomNumberGenerator.new()
	rng.seed=430071
	for i in range(variants.size()-1,0,-1):
		var j := rng.randi_range(0,i)
		var saved: int=variants[i]
		variants[i]=variants[j]; variants[j]=saved
	for i in stones.size():
		var variant: int=variants[i]
		var stone: Dictionary=stones[i]
		world._replace_sprite(stone.sprite,str(variant),stone.height,{"profiles":{str(variant):profiles.stones[variant]},"textures":{str(variant):textures.stones[variant]}})
		stone.variant=variant
		stone.sprite.material_override.set_shader_parameter("flex",0.)

func set_layer_stage(value: int) -> void:
	layer_stage=clampi(value,0,2)
	for plant in planted: plant.root.visible=layer_stage>=1
	for batch in flower_batches: batch.visible=layer_stage>=2
	for i in stage_buttons.size(): stage_buttons[i].modulate=Color("e6eab8") if i==layer_stage else Color("a5b3a6")

func _pick_stage(value: int) -> void:
	set_layer_stage(value)
	toggle_catalog()

func _build_catalog() -> void:
	var layer := CanvasLayer.new()
	layer.layer=25
	add_child(layer)
	catalog=Control.new()
	catalog.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	catalog.mouse_filter=Control.MOUSE_FILTER_STOP
	layer.add_child(catalog)
	var veil := ColorRect.new()
	veil.color=Color(.025,.04,.035,.48)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	catalog.add_child(veil)
	var panel := Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left=-345; panel.offset_right=345
	panel.offset_top=-190; panel.offset_bottom=190
	var style := StyleBoxFlat.new()
	style.bg_color=Color("26382f")
	style.set_corner_radius_all(12)
	panel.add_theme_stylebox_override("panel",style)
	catalog.add_child(panel)
	_label(panel,"先看草，再看灌木，最后看花",25).position=Vector2(26,22)
	_label(panel,"同一机位分层对照 · 四种石子始终混合保留",16).position=Vector2(27,67)
	for i in 3:
		var button := Button.new()
		button.text=["① 高低草混合","② 加高灌木","③ 再加独立花"][i]
		button.add_theme_font_size_override("font_size",18)
		button.position=Vector2(26+i*214,116)
		button.size=Vector2(202,56)
		button.pressed.connect(_pick_stage.bind(i))
		panel.add_child(button)
		stage_buttons.append(button)
	var focus_button := Button.new()
	focus_button.text="切换景深：关 → 轻 → 浓 → 重"
	focus_button.position=Vector2(26,204)
	focus_button.size=Vector2(637,42)
	focus_button.pressed.connect(_cycle_focus)
	panel.add_child(focus_button)
	focus_description=_label(panel,"",16)
	focus_description.position=Vector2(27,254)
	_label(panel,"Ctrl+1/2/3 直接切层 · Alt+F12 景深 · Esc / Ctrl+F2 收起",15).position=Vector2(27,302)
	_label(panel,"Compatibility · 不改变镜头距离与战斗规则",14).position=Vector2(27,337)
	set_layer_stage(2)
	catalog.hide()

func _cycle_focus() -> void:
	world.atmosphere41.toggle_focus()
	_update_focus_description()

func _update_focus_description() -> void:
	if is_instance_valid(focus_description):
		focus_description.text="当前景深："+["关闭","轻","浓 · 默认","重"][world.atmosphere41.focus_level]

func toggle_catalog() -> void:
	super.toggle_catalog()
	if catalog.visible: _update_focus_description()
