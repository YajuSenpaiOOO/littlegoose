extends CharacterBody2D
## Art-study movement only. Combat and narrative are intentionally not migrated yet.
const Frames = preload("res://scripts/art/hero_frames.gd")
var visual: Sprite2D
var directions: Dictionary = {}
var facing := "down"
var phase := 0.0
var moving := false
var enemy := false
var target_height := 94.0
var frozen := false
var move_speed := 235.0
var fast_speed := 360.0

func _ready() -> void:
	set_meta("sample_character",true)
	visual = Sprite2D.new()
	visual.name = "Visual"
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(visual)
	var hit := CollisionShape2D.new()
	hit.name = "Footprint"
	var shape := CircleShape2D.new()
	shape.radius = 14.0 if not enemy else 19.0
	hit.shape = shape
	hit.position.y = -5
	add_child(hit)
	if enemy:
		var entry: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/tuantuan_v2/motion_v1.json")).idle
		visual.texture = load(entry.texture)
		visual.scale = Vector2.ONE*(target_height/float(entry.visible_height))*float(entry.scale)
		visual.offset = visual.texture.get_size()*0.5-Vector2(entry.foot[0],entry.foot[1])
	else:
		directions.down = Frames.new("hero_pixel","walk_backup.json")
		for key in ["up","left","right"]:
			directions[key] = Frames.new("hero_pixel","walk_%s_v1.json" % ("back" if key=="up" else key))
		_render_pose()

func _physics_process(delta: float) -> void:
	if enemy or frozen: return
	var direction := Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))-float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
	moving = direction.length_squared()>0
	if moving:
		if absf(direction.x)>absf(direction.y): facing = "right" if direction.x>0 else "left"
		else: facing = "down" if direction.y>0 else "up"
	velocity = velocity.move_toward(direction.normalized()*(fast_speed if Input.is_physical_key_pressed(KEY_SHIFT) else move_speed),delta*move_speed*9.4)
	move_and_slide()
	if moving: phase += delta*1.05
	_render_pose()

func _render_pose() -> void:
	var frames: RefCounted = directions[facing]
	if moving:
		var sequence := [0,1,2,1]
		var index: int = sequence[int(phase*4.0)%4]%frames.frames.size()
		visual.texture = frames.frames[index]
		visual.scale = Vector2.ONE*(target_height/frames.frame_heights[index])
		visual.offset = visual.texture.get_size()*0.5-frames.anchors[index]
	else:
		visual.texture = frames.idle
		visual.scale = Vector2.ONE*(target_height/frames.idle_height)
		visual.offset = visual.texture.get_size()*0.5-frames.idle_anchor
	# Drawn feet are the anchor: no added pose bob and no broad oval shadow.
	visual.position = Vector2.ZERO
