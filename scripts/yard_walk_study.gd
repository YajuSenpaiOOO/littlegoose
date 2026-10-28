extends "res://scripts/prop_study_35.gd"
const GROUND_BOUNDS := Rect2(-1400,-1400,2800,2800)
var terrain: ColorRect
var textured_ground := true

func _ready() -> void:
	follow_enabled = true
	terrain = ColorRect.new()
	terrain.name = "ProjectedGround"
	terrain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	terrain.position = p(GROUND_BOUNDS.position)
	terrain.size = Vector2(GROUND_BOUNDS.size.x,GROUND_BOUNDS.size.y*sin(deg_to_rad(35.0)))
	terrain.z_index = -10
	var surface := ShaderMaterial.new()
	surface.shader = preload("res://scripts/art/yard_ground.gdshader")
	surface.set_shader_parameter("grass_texture",load("res://assets/environment/angle35/grass_ground_v1.png"))
	surface.set_shader_parameter("dirt_texture",load("res://assets/environment/angle35/dirt_ground_v1.png"))
	terrain.material = surface
	add_child(terrain)
	super._ready()
	camera.position = _camera_center(hero.position+Vector2(0,-160))
	camera.force_update_scroll()
	_refresh_status()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--walk-view="):
			match arg.trim_prefix("--walk-view="):
				"left": ground_position = Vector2(-570,170)
				"right": ground_position = Vector2(570,380)
				"north": ground_position = Vector2(0,-620)
			hero.position = p(ground_position)
			camera.position = _camera_center(hero.position+Vector2(0,-160))
			camera.force_update_scroll()

func _camera_center(target: Vector2) -> Vector2:
	var half := get_viewport_rect().size*0.5/camera.zoom
	var low := p(GROUND_BOUNDS.position)+half
	var high := p(GROUND_BOUNDS.end)-half
	return target.clamp(low,high)

func _draw_terrain() -> void:
	if not textured_ground: super._draw_terrain()

func _refresh_status() -> void:
	if status==null: return
	status.text = "A · 小屋门外实走    镜头跟随：%s\nWASD 移动   Shift 快走   C 跟随 / 固定\nT 地皮对比   B 摆件 / 白模   G 网格   O 投影\n35° 正交视角 · R 复位 · 团团为外观占位" % ("开" if follow_enabled else "关")

func _process(delta: float) -> void:
	super._process(delta)
	if camera: camera.position = _camera_center(camera.position)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	if event.physical_keycode==KEY_T:
		textured_ground = not textured_ground
		terrain.visible = textured_ground
		queue_redraw()
	elif event.physical_keycode==KEY_F1:
		status.get_parent().visible = not status.get_parent().visible
	else:
		super._unhandled_key_input(event)
	_refresh_status()
