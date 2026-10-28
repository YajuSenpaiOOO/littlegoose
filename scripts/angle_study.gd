extends Node2D
## Fixed-view 2D projection study. Shapes explicitly share one camera equation.
## This is a visual blockout, not a replacement for production physics/combat.
const Actor = preload("res://scripts/study_actor.gd")
const Contact = preload("res://scripts/art/actor_foot_contact.gd")
var angles := [25.0,35.0,45.0]
var angle_index := 1
var origin := Vector2(800,620)
var sorted: Node2D
var hero: CharacterBody2D
var enemy: CharacterBody2D
var ground_position := Vector2(0,190)
var grid := true
var shadows := true
var status: Label
var bodies: Array[Dictionary] = []
var footprints := [Rect2(-175,-350,350,220),Rect2(-470,0,54,56),Rect2(425,-60,54,56),Rect2(200,280,110,80)]

func p(point: Vector2,height := 0.0) -> Vector2:
	var theta := deg_to_rad(angles[angle_index])
	return origin+Vector2(point.x,point.y*sin(theta)-height*cos(theta))

func poly(points: Array,heights: Array,color: Color,parent: Node2D) -> void:
	var shape := Polygon2D.new()
	var vertices := PackedVector2Array()
	for index in points.size(): vertices.append(p(points[index],heights[index])-parent.position)
	shape.polygon = vertices
	shape.color = color
	parent.add_child(shape)

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("a2b598"))
	sorted = Node2D.new()
	sorted.y_sort_enabled = true
	add_child(sorted)
	hero = Actor.new()
	hero.frozen = true
	hero.collision_layer = 0
	hero.collision_mask = 0
	sorted.add_child(hero)
	enemy = Actor.new()
	enemy.enemy = true
	enemy.target_height = 82
	enemy.collision_layer = 0
	enemy.collision_mask = 0
	sorted.add_child(enemy)
	Contact.ensure(hero,hero.visual)
	Contact.ensure(enemy,enemy.visual)
	var ui := CanvasLayer.new()
	add_child(ui)
	var panel := ColorRect.new()
	panel.position = Vector2(25,22)
	panel.size = Vector2(605,130)
	panel.color = Color(0.09,0.14,0.13,0.9)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(panel)
	status = Label.new()
	status.position = Vector2(42,34)
	status.add_theme_font_size_override("font_size",19)
	ui.add_child(status)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--angle="): angle_index = angles.find(float(arg.trim_prefix("--angle=")))
	angle_index = maxi(0,angle_index)
	_rebuild()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): _capture(arg.trim_prefix("--capture="))

func _rebuild() -> void:
	for body in bodies: body.node.free()
	bodies.clear()
	_house()
	_tree(Vector2(-443,28),270,Color("597b69"))
	_tree(Vector2(452,-32),245,Color("728c70"))
	_rock()
	hero.position = p(ground_position)
	enemy.position = p(Vector2(145,120))
	status.text = "A · 纯 2D 视角校准    当前俯角 %d°\n1：25°  更低    2：35°  折中    3：45°  更俯视\nWASD 移动   Shift 快走   G 网格   O 投影   R 复位\n几何占位验证：不是最终画风，角色保持立牌画法" % angles[angle_index]
	queue_redraw()

func _anchor(at: Vector2) -> Node2D:
	var node := Node2D.new()
	node.position = p(at)
	sorted.add_child(node)
	bodies.append({"node":node,"at":at})
	return node

func _house() -> void:
	var node := _anchor(Vector2(0,-130))
	poly([Vector2(-175,-350),Vector2(175,-350),Vector2(175,-130),Vector2(-175,-130)],[0,0,0,0],Color("8d9d82"),node)
	# One front wall plane, with its vertical extent projected by the same theta.
	poly([Vector2(-175,-130),Vector2(175,-130),Vector2(175,-130),Vector2(-175,-130)],[0,0,190,190],Color("ead8b4"),node)
	poly([Vector2(-175,-350),Vector2(-175,-130),Vector2(0,-130),Vector2(0,-350)],[190,190,295,295],Color("c78c6b"),node)
	poly([Vector2(0,-350),Vector2(0,-130),Vector2(175,-130),Vector2(175,-350)],[295,295,190,190],Color("a76d57"),node)
	poly([Vector2(-175,-130),Vector2(175,-130),Vector2(0,-130)],[190,190,295],Color("e6cba4"),node)
	poly([Vector2(-35,-130),Vector2(35,-130),Vector2(35,-130),Vector2(-35,-130)],[0,0,114,114],Color("6c6552"),node)
	for x in [-110,110]:
		poly([Vector2(x-24,-130),Vector2(x+24,-130),Vector2(x+24,-130),Vector2(x-24,-130)],[73,73,125,125],Color("879d9b"),node)
		poly([Vector2(x-2,-130),Vector2(x+2,-130),Vector2(x+2,-130),Vector2(x-2,-130)],[73,73,125,125],Color("837b63"),node)
	poly([Vector2(-185,-120),Vector2(185,-120),Vector2(185,-148),Vector2(-185,-148)],[0,0,0,0],Color("c0b99c"),node)

func _tree(at: Vector2,height: float,color: Color) -> void:
	var node := _anchor(at)
	poly([at+Vector2(-16,0),at+Vector2(16,0),at+Vector2(9,0),at+Vector2(-10,0)],[0,0,height*0.72,height*0.72],Color("82745c"),node)
	# Foliage uses a geometric volume, deliberately avoiding generated sprite angles.
	for crown in [{"offset":Vector2(-45,-8),"z":height*0.72,"r":73.0},{"offset":Vector2(48,2),"z":height*0.78,"r":78.0},{"offset":Vector2(-5,-5),"z":height,"r":82.0}]:
		var circle := Polygon2D.new()
		var points := PackedVector2Array()
		var center := p(at+crown.offset,crown.z)-node.position
		for step in 24:
			var a := TAU*step/24.0
			points.append(center+Vector2(cos(a),sin(a))*crown.r)
		circle.polygon = points
		circle.color = color.lightened(0.04 if crown.z==height else 0)
		node.add_child(circle)

func _rock() -> void:
	var node := _anchor(Vector2(255,360))
	poly([Vector2(200,360),Vector2(310,360),Vector2(310,280),Vector2(200,280)],[0,0,50,50],Color("8a9690"),node)
	poly([Vector2(200,280),Vector2(310,280),Vector2(300,305),Vector2(212,305)],[50,50,80,80],Color("b1bab0"),node)
	poly([Vector2(212,305),Vector2(300,305),Vector2(310,360),Vector2(200,360)],[80,80,0,0],Color("9eaaa1"),node)

func _draw_terrain() -> void:
	# A plane with constant scale, never a perspective photograph of ground.
	var land := PackedVector2Array([p(Vector2(-1600,-1800)),p(Vector2(1600,-1800)),p(Vector2(1600,1800)),p(Vector2(-1600,1800))])
	draw_colored_polygon(land,Color("a2b598"))
	var path := PackedVector2Array([p(Vector2(-72,-130)),p(Vector2(72,-130)),p(Vector2(125,600)),p(Vector2(300,1100)),p(Vector2(60,1100)),p(Vector2(-100,600))])
	draw_colored_polygon(path,Color("d8c6a4"))

func _draw() -> void:
	_draw_terrain()
	if grid:
		for x in range(-1600,1601,100): draw_line(p(Vector2(x,-1800)),p(Vector2(x,1800)),Color(0.25,0.38,0.32,0.14),1,true)
		for y in range(-1800,1801,100): draw_line(p(Vector2(-1600,y)),p(Vector2(1600,y)),Color(0.25,0.38,0.32,0.14),1,true)
	# A ground circle becomes an ellipse; its compression is not guessed per asset.
	if grid:
		var ring := PackedVector2Array()
		for i in 65: ring.append(p(Vector2(430,320)+Vector2(cos(TAU*i/64.0),sin(TAU*i/64.0))*95))
		draw_polyline(ring,Color("789280"),3,true)
	if shadows:
		_shadow_box(Rect2(-175,-350,350,220),190)
		_shadow_tree(Vector2(-443,28),270)
		_shadow_tree(Vector2(452,-32),245)
		_shadow_box(Rect2(200,280,110,80),55)
		var start := p(ground_position)
		var shift := p(ground_position+Vector2(57,30))-start
		var shadow := PackedVector2Array([start+Vector2(-15,0),start+Vector2(15,0),start+shift+Vector2(9,0),start+shift-Vector2(9,0)])
		draw_colored_polygon(shadow,Color(0.18,0.25,0.23,0.16))

func _shadow_box(rect: Rect2,height: float) -> void:
	var points := PackedVector2Array()
	for at in [rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)]:
		points.append(p(at))
		points.append(p(at+Vector2(0.6,0.32)*height))
	draw_colored_polygon(Geometry2D.convex_hull(points),Color(0.18,0.25,0.23,0.16))

func _shadow_tree(at: Vector2,height: float) -> void:
	var shift := Vector2(0.6,0.32)*height
	draw_line(p(at),p(at+shift),Color(0.18,0.25,0.23,0.16),13,true)
	var points := PackedVector2Array()
	for i in 32:
		var a := TAU*i/32.0
		points.append(p(at+shift+Vector2(cos(a),sin(a))*85))
	draw_colored_polygon(points,Color(0.18,0.25,0.23,0.16))

func _process(delta: float) -> void:
	var direction := Vector2(float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A)),float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W)))
	var move := direction.normalized()*delta*(350 if Input.is_physical_key_pressed(KEY_SHIFT) else 230)
	for axis in 2:
		var next := ground_position
		next[axis] += move[axis]
		var blocked := false
		for rect in footprints:
			if rect.grow(16).has_point(next): blocked = true
		if not blocked: ground_position = next.clamp(Vector2(-740,-650),Vector2(740,580))
	hero.moving = direction.length_squared()>0
	if hero.moving:
		if absf(direction.x)>absf(direction.y): hero.facing = "right" if direction.x>0 else "left"
		else: hero.facing = "down" if direction.y>0 else "up"
		hero.phase += delta*1.05
	hero._render_pose()
	hero.position = p(ground_position)
	queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	match event.physical_keycode:
		KEY_1: angle_index = 0
		KEY_2: angle_index = 1
		KEY_3: angle_index = 2
		KEY_G: grid = not grid
		KEY_O: shadows = not shadows
		KEY_R: ground_position = Vector2(0,190)
		KEY_ESCAPE: get_tree().quit()
	_rebuild()

func _capture(path: String) -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var result := get_viewport().get_texture().get_image().save_png(path)
	print("ANGLE_CAPTURE ",path," result=",result)
	get_tree().quit(0 if result==OK else 1)
