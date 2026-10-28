extends "res://scripts/angle_study.gd"
## Art assets are authored for ONE fixed camera. Angle switches remain in whitebox.
var manifest: Dictionary
var art_enabled := true
var follow_enabled := false
var camera: Camera2D

func _ready() -> void:
	manifest = JSON.parse_string(FileAccess.get_file_as_string("res://assets/environment/angle35/manifest.json"))
	footprints[3] = Rect2(165,245,180,115)
	grid = false
	super._ready()
	camera = Camera2D.new()
	camera.position = Vector2(800,500)
	add_child(camera)
	camera.make_current()
	_refresh_status()

func _rebuild() -> void:
	angle_index = 1
	super._rebuild()
	_refresh_status()

func _refresh_status() -> void:
	if status==null: return
	status.text = "A · 35° 摆件样板    %s\nWASD 移动   Shift 快走   B 素材 / 白模\nG 地面网格   O 体积投影   C 镜头跟随   R 复位\n固定视角素材；团团为外观占位" % ("手绘摆件" if art_enabled else "几何体对照")

func _sprite(id: String,at: Vector2,screen_height: float,sort_at: Vector2) -> void:
	var data: Dictionary = manifest[id]
	var node := _anchor(sort_at)
	var sprite := Sprite2D.new()
	sprite.texture = load(data.path)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.scale = Vector2.ONE*screen_height/float(data.visible_height)
	sprite.offset = sprite.texture.get_size()*0.5-Vector2(data.foot[0],data.foot[1])
	sprite.position = p(at)-node.position
	node.add_child(sprite)

func _house() -> void:
	if not art_enabled:
		super._house()
		return
	_sprite("cottage",Vector2(0,-130),350,Vector2(0,-130))

func _tree(at: Vector2,height: float,color: Color) -> void:
	if not art_enabled:
		super._tree(at,height,color)
		return
	_sprite("tree",at,height*cos(deg_to_rad(35.0))+65.0,at)

func _rock() -> void:
	if not art_enabled:
		super._rock()
		return
	_sprite("rock",Vector2(255,360),93,Vector2(255,360))

func _soft_shadow(points: PackedVector2Array) -> void:
	var hull := Geometry2D.convex_hull(points)
	var center := Vector2.ZERO
	for point in hull: center += point
	center /= float(hull.size())
	for expansion in [3.0,1.5,0.0]:
		var edge := PackedVector2Array()
		for point in hull: edge.append(point+(point-center).normalized()*expansion)
		draw_colored_polygon(edge,Color(0.18,0.25,0.23,0.018 if expansion>0 else 0.10))

func _shadow_box(rect: Rect2,height: float) -> void:
	if rect.size.x==110: rect = footprints[3]
	var points := PackedVector2Array()
	for at in [rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)]:
		points.append(p(at))
		points.append(p(at+Vector2(0.6,0.32)*height))
	_soft_shadow(points)

func _shadow_tree(at: Vector2,height: float) -> void:
	var points := PackedVector2Array([p(at+Vector2(-7,0)),p(at+Vector2(7,0))])
	# Connected crown-height volumes, rather than a detached disc and trunk stripe.
	for level in [0.45,0.72,1.0]:
		var center: Vector2 = at+Vector2(0.6,0.32)*height*float(level)
		var radius: float = 56.0 if level<1.0 else 42.0
		for index in 24:
			var a := TAU*index/24.0
			points.append(p(center+Vector2(cos(a),sin(a))*radius))
	_soft_shadow(points)

func _process(delta: float) -> void:
	super._process(delta)
	if camera:
		var target := hero.position+Vector2(0,-160) if follow_enabled else Vector2(800,500)
		camera.position = camera.position.lerp(target,1.0-exp(-delta*5.0))

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	match event.physical_keycode:
		KEY_B:
			art_enabled = not art_enabled
			_rebuild()
		KEY_C:
			follow_enabled = not follow_enabled
			_refresh_status()
		KEY_1, KEY_2, KEY_3:
			return
		_:
			super._unhandled_key_input(event)
			_refresh_status()
