extends "res://scripts/angle_study.gd"
## Isolated art/gameplay calibration. Ground simulation is never screen-space.
const SHOT_HEIGHT := 35.0
const TARGET_RADIUS := 25.0
var world: Node2D
var layout_scale := 1.0
var routes: Array = []
var plan := {"routes":[]}
var field: Node
var terrain: Node2D
var camera: Camera2D
var target_ground := Vector2(280,180)
var shots: Array[Dictionary] = []
var hits := 0
var blocked_shots := 0
var cooldown := 0.0
var hit_flash := 0.0
var fade_enabled := true
var aim_guides := true
var crosshair: Node2D
var zoom_value := 1.0
var shadow_plane: Node2D
var follow_camera := true

class GroundShadows extends Node2D:
	var sample: Node2D
	func _draw() -> void:
		if not sample.shadows: return
		var tint := Color(0.13,0.19,0.27,0.30)
		for item in [{"at":Vector2(-443,28),"height":270.0},{"at":Vector2(452,-32),"height":245.0}]:
			var shift: Vector2 = Vector2(0.65,0.4)*item.height
			draw_line(sample.p(item.at),sample.p(item.at+shift),tint,12,true)
			var crown := PackedVector2Array()
			for i in 40:
				crown.append(sample.p(item.at+shift+Vector2(cos(TAU*i/40.0)*104,sin(TAU*i/40.0)*84)))
			draw_colored_polygon(crown,tint)
		for pair in [{"rect":sample.footprints[0],"height":190.0},{"rect":sample.footprints[3],"height":55.0}]:
			var rect: Rect2 = pair.rect
			var cloud := PackedVector2Array()
			for at in [rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]:
				cloud.append(sample.p(at))
				cloud.append(sample.p(at+Vector2(0.65,0.4)*pair.height))
			draw_colored_polygon(Geometry2D.convex_hull(cloud),tint)
		for at in [sample.ground_position,sample.target_ground]:
			# Ground contact stays at the feet; the directional cast begins here.
			var contact := PackedVector2Array()
			for i in 32:
				contact.append(sample.p(at+Vector2(cos(TAU*i/32.0)*12,sin(TAU*i/32.0)*8)))
			draw_colored_polygon(contact,Color(0.10,0.14,0.20,0.42))
			draw_colored_polygon(PackedVector2Array([sample.p(at+Vector2(-8,0)),sample.p(at+Vector2(8,0)),sample.p(at+Vector2(37,14)),sample.p(at+Vector2(9,14))]),tint)
			var points := PackedVector2Array()
			for i in 32:
				points.append(sample.p(at+Vector2(23,14)+Vector2(cos(TAU*i/32.0)*27,sin(TAU*i/32.0)*13)))
			draw_colored_polygon(points,tint)

class AimOverlay extends Node2D:
	var sample: Node2D
	func _draw() -> void:
		var cursor := get_global_mouse_position()
		var color := Color("ffe2a2")
		draw_arc(cursor,9,0,TAU,24,color,1.5,true)
		for axis in [Vector2.RIGHT,Vector2.DOWN]:
			draw_line(cursor+axis*12,cursor+axis*17,color,1.5,true)
			draw_line(cursor-axis*12,cursor-axis*17,color,1.5,true)
		if sample.aim_guides:
			var muzzle: Vector2 = sample.p(sample.ground_position,sample.SHOT_HEIGHT)
			draw_dashed_line(muzzle,cursor,Color(1,0.9,0.65,0.40),1,9)
			var ring := PackedVector2Array()
			for i in 41:
				ring.append(sample.p(sample.target_ground+Vector2.from_angle(TAU*i/40.0)*sample.TARGET_RADIUS,sample.SHOT_HEIGHT))
			draw_polyline(ring,Color(1,0.8,0.4,0.5),1.5,true)

func _ready() -> void:
	angle_index = 0
	grid = false
	super._ready()
	# Fixed 25-degree specimen: number keys cannot invalidate vegetation placement.
	angle_index = 0
	world = sorted
	hero.target_height = 76
	hero._render_pose()
	enemy.target_height = 70
	enemy.visual.scale *= 70.0/82.0
	enemy.position = p(target_ground)
	_build_terrain()
	shadow_plane = GroundShadows.new()
	shadow_plane.sample = self
	shadow_plane.z_index = -5
	add_child(shadow_plane)
	field = preload("res://scripts/reactive_grass_field.gd").new()
	field.scene = self
	field.requested_count = 720
	field.patch_radius = Vector2(112,55)
	for center in [Vector2(-300,260),Vector2(-290,470),Vector2(190,390),Vector2(365,180),Vector2(485,400),Vector2(-580,-300),Vector2(430,-340)]:
		field.centers_override.append(p(center))
	field.placement_test = _grass_allowed
	add_child(field)
	for tuft in field.tufts:
		tuft.scale *= 1.5
		tuft.modulate = Color(0.78,0.89,0.64)
	camera = Camera2D.new()
	camera.position = hero.position+Vector2(0,-110)
	camera.process_callback = Camera2D.CAMERA2D_PROCESS_IDLE
	add_child(camera)
	camera.make_current()
	crosshair = AimOverlay.new()
	crosshair.sample = self
	crosshair.z_index = 100
	add_child(crosshair)
	# Base panel remains screen-fixed and contains controls, not world coordinates.
	status.get_parent().get_child(0).size = Vector2(1110,148)
	_update_status()

func unproject(screen: Vector2,height := 0.0) -> Vector2:
	return Vector2(screen.x-origin.x,(screen.y-origin.y+height*cos(deg_to_rad(25.0)))/sin(deg_to_rad(25.0)))

func _grass_allowed(at: Vector2) -> bool:
	var ground := unproject(at)
	for rect in footprints:
		if rect.grow(24).has_point(ground): return false
	# Keep a genuinely clear footpath; plants grow at its irregular edges.
	return absf(ground.x)>115 or ground.y < -160

func _surface(points: PackedVector2Array,surface: int) -> void:
	var shape := Polygon2D.new()
	shape.polygon = points
	var m := ShaderMaterial.new()
	m.shader = preload("res://scripts/art/restart_ground.gdshader")
	m.set_shader_parameter("grass_texture",preload("res://assets/world_restart_v1/forest_floor.png"))
	m.set_shader_parameter("earth_texture",preload("res://assets/courtyard_v1/ground_materials_v2.png"))
	m.set_shader_parameter("hero_style",false)
	m.set_shader_parameter("surface",surface)
	m.set_shader_parameter("tone",Color(1.10,1.10,0.99))
	if surface==1:
		var edge := points.duplicate()
		edge.resize(64)
		m.set_shader_parameter("edge_points",edge)
		m.set_shader_parameter("edge_count",points.size())
	shape.material = m
	terrain.add_child(shape)

func _build_terrain() -> void:
	terrain = Node2D.new()
	terrain.position = origin
	terrain.scale.y = sin(deg_to_rad(25.0))
	terrain.z_index = -10
	add_child(terrain)
	_surface(PackedVector2Array([Vector2(-2000,-2400),Vector2(2000,-2400),Vector2(2000,2200),Vector2(-2000,2200)]),0)
	_surface(PackedVector2Array([Vector2(-90,-130),Vector2(90,-130),Vector2(105,220),Vector2(150,520),Vector2(360,1100),Vector2(120,1100),Vector2(-105,540),Vector2(-130,150)]),1)
	_surface(PackedVector2Array([Vector2(70,150),Vector2(570,100),Vector2(620,200),Vector2(70,280)]),1)

func _draw_terrain() -> void:
	# Textured plane is a child in ground coordinates; avoid the flat study fill.
	pass

func _process(delta: float) -> void:
	super._process(delta)
	_follow_camera(delta)
	cooldown = maxf(0,cooldown-delta)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and cooldown<=0:
		fire_at(get_global_mouse_position())
		cooldown = 0.19
	step_shots(delta)
	hit_flash = maxf(0,hit_flash-delta)
	enemy.modulate = Color(1.5,0.85,0.6) if hit_flash>0 else Color.WHITE
	_update_fading(delta)
	shadow_plane.queue_redraw()
	crosshair.queue_redraw()
	_update_status()

func _follow_camera(delta: float,snap := false) -> void:
	if not follow_camera: return
	# Actor and camera are both updated in this idle frame; no second smoothing pass.
	var target := hero.position+Vector2(0,-110)/zoom_value
	camera.position = target if snap else camera.position.lerp(target,1.0-exp(-delta*10.0))
	camera.force_update_scroll()

func _draw() -> void:
	# Shadow layer explicitly sits between textured terrain and sorted objects.
	pass

func fire_at(cursor: Vector2) -> void:
	var destination := unproject(cursor,SHOT_HEIGHT)
	var direction := ground_position.direction_to(destination)
	if direction==Vector2.ZERO: return
	var node := Node2D.new()
	node.position = p(ground_position)
	var streak := Polygon2D.new()
	streak.color = Color("ffe5a0")
	var heading := Vector2(direction.x,direction.y*sin(deg_to_rad(25.0))).normalized()
	var normal := heading.orthogonal()*2.5
	var lift := Vector2(0,-SHOT_HEIGHT*cos(deg_to_rad(25.0)))
	streak.polygon = PackedVector2Array([lift+heading*8,lift+normal,lift-heading*8,lift-normal])
	node.add_child(streak)
	world.add_child(node)
	shots.append({"at":ground_position,"direction":direction,"life":2.2,"node":node})

func segment_rect_fraction(a: Vector2,b: Vector2,rect: Rect2) -> float:
	if rect.has_point(a): return 0.0
	var best := 2.0
	var corners := [rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]
	for i in 4:
		var point: Variant = Geometry2D.segment_intersects_segment(a,b,corners[i],corners[(i+1)%4])
		if point!=null: best = minf(best,a.distance_to(point)/maxf(a.distance_to(b),0.001))
	return best

func segment_target_fraction(a: Vector2,b: Vector2) -> float:
	var d := b-a
	var relative := a-target_ground
	var c := relative.length_squared()-TARGET_RADIUS*TARGET_RADIUS
	if c<=0: return 0.0
	var v := d.length_squared()
	if v<0.0001: return 2.0
	var dot := relative.dot(d)
	var discriminant := dot*dot-v*c
	if discriminant<0: return 2.0
	var t := (-dot-sqrt(discriminant))/v
	return t if t>=0 and t<=1 else 2.0

func step_shots(delta: float) -> void:
	for i in range(shots.size()-1,-1,-1):
		var shot := shots[i]
		var a: Vector2 = shot.at
		var b: Vector2 = a+shot.direction*780.0*delta
		var target_t := segment_target_fraction(a,b)
		var wall_t := 2.0
		for rect in footprints: wall_t = minf(wall_t,segment_rect_fraction(a,b,rect))
		if target_t<=1.0 and target_t<wall_t:
			hits += 1
			hit_flash = 0.12
		elif wall_t<=1.0: blocked_shots += 1
		shot.life -= delta
		if minf(target_t,wall_t)<=1.0 or shot.life<=0:
			shot.node.queue_free()
			shots.remove_at(i)
		else:
			shot.at = b
			shot.node.position = p(b)

func _update_fading(delta: float) -> void:
	for body in bodies:
		var node: Node2D = body.node
		var obscured := false
		if fade_enabled and hero.position.y<node.position.y:
			var head := hero.position-Vector2(0,45)
			for child in node.get_children():
				if child is Polygon2D and Geometry2D.is_point_in_polygon(head-node.position,child.polygon):
					obscured = true
		var alpha := 0.25 if obscured else 1.0
		node.modulate.a = move_toward(node.modulate.a,alpha,delta*5)

func _update_status() -> void:
	status.text = "25° 实景手感样板 · 细节地皮 / 可穿行草 / 直立人物\nWASD 移动 · Shift 快走 · 左键射击 · 滚轮缩放 · 中键复位镜头\nC 跟随 %s · F 遮挡淡出 %s · G 草 · O 阴影 · T 辅助 · R 复位\n命中 %d   障碍拦截 %d   房树为视角几何占位，草沿用机制试验素材" % ["开" if follow_camera else "关","开" if fade_enabled else "关",hits,blocked_shots]

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	match event.physical_keycode:
		KEY_C: follow_camera = not follow_camera
		KEY_F: fade_enabled = not fade_enabled
		KEY_G: field.set_active(not field.active)
		KEY_T: aim_guides = not aim_guides
		KEY_O: shadows = not shadows
		KEY_R:
			ground_position = Vector2(0,190)
			hero.position = p(ground_position)
			_follow_camera(0,true)
		KEY_ESCAPE: get_tree().quit()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index==MOUSE_BUTTON_WHEEL_UP: zoom_value = minf(2.0,zoom_value*1.12)
		if event.button_index==MOUSE_BUTTON_WHEEL_DOWN: zoom_value = maxf(0.65,zoom_value/1.12)
		if event.button_index==MOUSE_BUTTON_MIDDLE:
			zoom_value = 1.0
		camera.zoom = Vector2.ONE*zoom_value
		if event.button_index==MOUSE_BUTTON_MIDDLE: _follow_camera(0,true)

func _capture(path: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	set_process(false)
	zoom_value = 1.0
	camera.zoom = Vector2.ONE
	_follow_camera(0,true)
	camera.force_update_scroll()
	crosshair.hide()
	field.set_process(false)
	await RenderingServer.frame_post_draw
	var result := get_viewport().get_texture().get_image().save_png(path)
	print("VIEW25_CAPTURE ",path," result=",result)
	get_tree().quit(0 if result==OK else 1)
