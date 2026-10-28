extends Node2D
## Selected perfect-dodge art. Cosmetic lifetime uses real time during slow-mo.
const LIFE := 0.9
const MAX_LIVE := 6
static var frames: Array[Texture2D] = []
var started := 0
var age_override := -1.0
var variant := 1
var use_motion := true
var body: Sprite2D
var pieces: Array[Sprite2D] = []
var star: Sprite2D

static func spawn(parent: Node, at: Vector2, direction: Vector2):
	var live := parent.get_tree().get_nodes_in_group("perfect_dodge_art").filter(func(n: Node) -> bool: return not n.is_queued_for_deletion())
	if live.size() >= MAX_LIVE:
		live[0].queue_free()
	var effect := new()
	parent.add_child(effect)
	effect.global_position = at
	effect.rotation = direction.angle() if not direction.is_zero_approx() else 0.0
	effect.reset_physics_interpolation()
	return effect

func _ready() -> void:
	if frames.is_empty():
		var sheet: Texture2D = preload("res://assets/perfect_dodge_v1/animated/b_butterfly_parts_v1.png")
		var size := sheet.get_size()/Vector2(3,2)
		for i in 6:
			var atlas := AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = Rect2(Vector2(i%3,floori(i/3.0))*size,size)
			atlas.filter_clip = true
			frames.append(atlas)
	started = Time.get_ticks_msec()
	z_index = 34
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	add_to_group("perfect_dodge_art")
	body = _piece(3)
	star = _piece(4)
	star.position = Vector2(12,-8)
	for i in 3:
		pieces.append(_piece(0))
	_update(0)

func _piece(index: int) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = frames[index]
	add_child(s)
	return s

func elapsed() -> float:
	return age_override if age_override >= 0 else float(Time.get_ticks_msec()-started)/1000.0

func _process(_delta: float) -> void:
	var age := elapsed()
	if age >= LIFE:
		queue_free()
	else:
		_update(age)

func _envelope(age: float, delay := 0.0) -> float:
	return smoothstep(delay,delay+0.035,age)*(1.0-smoothstep(0.5,LIFE,age))

func _update(age: float) -> void:
	var k := clampf(age/LIFE,0,1)
	# The ribbon sits behind and below the body, leaving the face readable.
	body.position = Vector2(-18-3*k,7)
	body.scale = Vector2(1,0.65)*58/body.texture.get_width()*lerpf(0.84,1.0,smoothstep(0,0.07,age))
	body.modulate.a = smoothstep(0,0.035,age)*(1.0-smoothstep(0.09,0.26,age))*0.35
	# A brief success punctuation; the butterflies provide the trailing finish.
	star.modulate.a = smoothstep(0.015,0.04,age)*(1.0-smoothstep(0.09,0.21,age))
	star.scale = Vector2.ONE*(9.0+3.0*sin(clampf(age/0.14,0,1)*PI))/star.texture.get_width()
	var anchors := [Vector2(310,350),Vector2(290,345),Vector2(267,352)]
	for i in pieces.size():
		var s := pieces[i]
		var flap: int = [0,1,2,1][int(age/0.06+i)%4]
		s.texture = frames[flap]
		s.offset = s.texture.get_size()*0.5-anchors[flap]
		s.position = Vector2(-18-i*7,-4-i*5)+Vector2(-16*k,-12*k+sin(k*TAU+i)*1.5)
		s.rotation = -0.12+0.1*sin(k*TAU+i)
		s.scale = Vector2.ONE*(17-i*2)/s.texture.get_width()
		s.modulate.a = _envelope(age,i*0.018)
