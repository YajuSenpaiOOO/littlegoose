extends Node2D
const Actor = preload("res://scripts/study_actor.gd")
const Prop = preload("res://scripts/study_prop.gd")
const Lighting = preload("res://scripts/art/world_lighting.gd")
const Profile = preload("res://scripts/art/world_light_profile.gd")
var world: Node2D
var rig: Node2D
var hero: CharacterBody2D
var enemy: CharacterBody2D
var props: Array[StaticBody2D] = []
var modes: Array[Resource] = []
var mode_index := 0
var help_label: Label
var status_label: Label
var guides := false
var actor_scale_index := 1
var capture_path := ""

func _ready() -> void:
	process_priority = 200
	RenderingServer.set_default_clear_color(Color("465347"))
	var ground := Sprite2D.new()
	ground.name = "Ground"
	ground.texture = load("res://assets/environment/yard_ground_v1.png")
	ground.centered = false
	ground.scale = Vector2(1600.0,1000.0)/ground.texture.get_size()
	ground.z_index = -10
	add_child(ground)
	world = Node2D.new()
	world.name = "FootSortedObjects"
	world.y_sort_enabled = true
	add_child(world)
	rig = Lighting.new()
	rig.auto_update_projections = false
	add_child(rig)
	_build_modes()
	rig.set_profile(modes[0],true)
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/environment/manifest.json"))
	_add_prop("Cottage",manifest.cottage,Vector2(775,470),430,Rect2(-210,-115,445,111))
	_add_prop("LeftTree",manifest.tree,Vector2(305,655),475,Rect2(-28,-26,56,34))
	_add_prop("RightTree",manifest.tree,Vector2(1300,600),435,Rect2(-25,-24,50,32))
	_add_prop("Stone",manifest.rock,Vector2(1090,800),88,Rect2(-69,-39,138,43))
	hero = Actor.new()
	hero.name = "Hero"
	hero.position = Vector2(775,735)
	world.add_child(hero)
	enemy = Actor.new()
	enemy.name = "Tuantuan"
	enemy.enemy = true
	enemy.target_height = 82
	enemy.position = Vector2(955,695)
	world.add_child(enemy)
	rig.project_sprite(hero,hero.visual,94,155)
	rig.project_sprite(enemy,enemy.visual,82,140)
	_boundaries()
	_build_ui()
	for projection in rig.projections: projection.update_shadow(0,true)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="): capture_path = argument.trim_prefix("--capture=")
		if argument=="--sunset": mode_index = 1
		if argument=="--night": mode_index = 2
	rig.set_profile(modes[mode_index],true)
	_refresh_ui()
	if not capture_path.is_empty(): _capture()

func _build_modes() -> void:
	for index in 3:
		var profile := Profile.new()
		profile.label = ["柔和日光","暮色","月夜"][index]
		profile.sky_color = [Color("dce4df"),Color("b1b9cf"),Color("657b9b")][index]
		profile.direct_color = [Color("fff2d8"),Color("ffd0a0"),Color("d5e4ff")][index]
		profile.direct_energy = [0.12,0.21,0.11][index]
		profile.shadow_azimuth_degrees = [38.0,28.0,-140.0][index]
		profile.elevation_degrees = [59.0,32.0,60.0][index]
		profile.shadow_opacity = [0.24,0.28,0.20][index]
		profile.shadow_tint = Color("4b5368")
		profile.ground_y_scale = 0.55
		modes.append(profile)

func _add_prop(id: String,data: Dictionary,at: Vector2,height: float,area: Rect2,plane := false) -> void:
	var prop := Prop.new()
	prop.name = id
	prop.label = id
	prop.position = at
	prop.configure(data.path,Vector2(data.foot[0],data.foot[1]),data.visible_height,height,area)
	world.add_child(prop)
	props.append(prop)
	if plane:
		rig.project_plane(prop,Rect2(-220,-75,455,105),PackedVector2Array([Vector2(-210,-110),Vector2(235,-110),Vector2(235,0),Vector2(-210,0)]),height*0.65,260)
	else:
		rig.project_sprite(prop,prop.visual,height*0.88,240 if height>100 else 95)

func _boundaries() -> void:
	for rect in [Rect2(0,-20,1600,20),Rect2(0,1000,1600,20),Rect2(-20,0,20,1000),Rect2(1600,0,20,1000)]:
		var body := StaticBody2D.new()
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		collision.shape = shape
		body.position = rect.get_center()
		body.add_child(collision)
		add_child(body)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.055,0.075,0.07,0.84)
	backdrop.position = Vector2(24,22)
	backdrop.size = Vector2(510,94)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(backdrop)
	help_label = Label.new()
	help_label.position = Vector2(42,33)
	help_label.add_theme_font_size_override("font_size",15)
	help_label.text = "小屋门外 · 手绘样板 01\nWASD / 方向键 移动   Shift 快走   N 天色   O 投影\nH 脚点与碰撞   [ / ] 人物比例   R 复位   F1 面板"
	layer.add_child(help_label)
	status_label = Label.new()
	status_label.position = Vector2(30,958)
	status_label.add_theme_font_size_override("font_size",18)
	status_label.add_theme_color_override("font_shadow_color",Color("18291c"))
	status_label.add_theme_constant_override("shadow_offset_x",1)
	status_label.add_theme_constant_override("shadow_offset_y",2)
	layer.add_child(status_label)
	help_label.set_meta("backdrop",backdrop)

func _refresh_ui() -> void:
	status_label.text = "%s  ·  人物比例 %d%%  ·  同一地表 / 独立摆件 / 动态日光影  ·  团团为外观占位" % [modes[mode_index].label,roundi([0.85,1.0,1.15][actor_scale_index]*100)]

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	match event.physical_keycode:
		KEY_ESCAPE: get_tree().quit()
		KEY_N:
			mode_index = (mode_index+1)%modes.size()
			rig.set_profile(modes[mode_index])
		KEY_O: rig.shadows_enabled = not rig.shadows_enabled
		KEY_H:
			guides = not guides
			for prop in props:
				prop.guides = guides
				prop.queue_redraw()
		KEY_R:
			hero.position = Vector2(775,735)
			hero.velocity = Vector2.ZERO
		KEY_BRACKETLEFT, KEY_BRACKETRIGHT:
			actor_scale_index = clampi(actor_scale_index+(-1 if event.physical_keycode==KEY_BRACKETLEFT else 1),0,2)
			hero.target_height = 94.0*[0.85,1.0,1.15][actor_scale_index]
			hero._render_pose()
			for projection in rig.projections:
				if projection.actor==hero: projection.body_height = hero.target_height
		KEY_F1:
			help_label.visible = not help_label.visible
			help_label.get_meta("backdrop").visible = help_label.visible
			status_label.visible = help_label.visible
	_refresh_ui()

func _process(delta: float) -> void:
	for projection in rig.projections: projection.update_shadow(delta,rig.shadows_enabled)

func _capture() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var result := get_viewport().get_texture().get_image().save_png(capture_path)
	print("STUDY_CAPTURE ",capture_path," result=",result)
	get_tree().quit(0 if result==OK else 1)
