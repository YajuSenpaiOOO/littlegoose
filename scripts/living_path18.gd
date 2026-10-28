extends "res://scripts/grounded_path17.gd"
var path_ready := false
var soil_spots := true
var tracks = preload("res://scripts/world/surface_tracks18.gd").new()
var uploaded_revision := -1

func _build_lab_floor() -> void:
	super._build_lab_floor()
	meadow = preload("res://scripts/art/path_surface18.gd").new()

func _ready() -> void:
	super._ready()
	for material in ground_materials:
		material.shader = preload("res://scripts/art/living_path18.gdshader")
		material.set_shader_parameter("road_relief",true)
		material.set_shader_parameter("surface_spots",true)
	path_ready = true
	tracks.reset_position(Vector2(hero.position.x,hero.position.z))
	_sync_tracks()
	for arg in OS.get_cmdline_user_args():
		if arg=="--flat-path": set_road_relief(false)
		if arg=="--no-spots": set_spots(false)
		if arg=="--no-tracks": set_tracks(false)
	_status()

func _teleport15(at: Vector2) -> void:
	super._teleport15(at)
	if is_instance_valid(tracks): tracks.reset_position(at)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not path_ready: return
	tracks.advance(delta,Vector2(hero.position.x,hero.position.z),hero.is_on_floor(),meadow.contains_soil)
	_sync_tracks()

func _sync_tracks() -> void:
	for material in ground_materials:
		material.set_shader_parameter("footprint_clock",tracks.elapsed)
		material.set_shader_parameter("footprint_lifetime",tracks.lifetime)
		material.set_shader_parameter("footprints_enabled",tracks.enabled)
		if uploaded_revision!=tracks.revision: material.set_shader_parameter("footprints",tracks.marks)
	uploaded_revision = tracks.revision

func set_road_relief(enabled: bool) -> void:
	meadow.profile.enabled = enabled
	for material in ground_materials: material.set_shader_parameter("road_relief",enabled)
	_rebuild_terrain()
	last_contact_camera = Transform3D()
	tracks.reset_position(Vector2(hero.position.x,hero.position.z))
	_status()

func set_spots(enabled: bool) -> void:
	soil_spots = enabled
	for material in ground_materials: material.set_shader_parameter("surface_spots",enabled)
	_status()

func set_tracks(enabled: bool) -> void:
	tracks.enabled = enabled
	tracks.clear()
	_sync_tracks()
	_status()

func _status() -> void:
	super._status()
	if path_ready:
		label.text = label.text.replace("接地与土径17","浅土径与脚印18")+"\nU 草坪厚度 %s / I 土色斑 %s / F4 脚印 %s（约4.5秒淡出）"%["开" if meadow.profile.enabled else "关","开" if soil_spots else "关","开" if tracks.enabled else "关"]
		var line_height: float = label.get_theme_font("font").get_height(label.get_theme_font_size("font_size"))+label.get_theme_constant("line_spacing")
		var height := line_height*label.get_line_count()+24.
		var panel: ColorRect = label.get_parent().get_child(0)
		var screen_height := get_viewport().get_visible_rect().size.y
		panel.position.y = screen_height-height-15.
		panel.size.y = height
		label.position.y = panel.position.y+10.

func _unhandled_input(event: InputEvent) -> void:
	if path_ready and event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_U: set_road_relief(not meadow.profile.enabled); return
			KEY_I: set_spots(not soil_spots); return
			KEY_F4: set_tracks(not tracks.enabled); return
	super._unhandled_input(event)
