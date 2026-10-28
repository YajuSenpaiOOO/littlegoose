extends CharacterBody3D
const Frames = preload("res://scripts/art/hero_frames.gd")
var visual: Sprite3D
var directions: Dictionary = {}
var facing := "down"
var phase := 0.0
var moving := false
var controls_enabled := true
var locomotion := Vector2.ZERO
var combat_impulse := Vector2.ZERO
var combat_enabled := false
var legacy_motion_enabled := false
var motion_pixels_per_m := 19.09756
var knocked_art: Texture2D
var knocked_down := false
var story_knocked := false

func _ready() -> void:
	name = "Hero3D"
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	collision_layer = 4
	collision_mask = 3
	floor_snap_length = 0.4
	floor_max_angle = deg_to_rad(48)
	var collider := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.24
	shape.height = 1.3
	collider.shape = shape
	collider.position.y = 0.65
	add_child(collider)
	visual = Sprite3D.new()
	visual.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	visual.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	visual.alpha_scissor_threshold = 0.5
	visual.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(visual)
	directions.down = Frames.new("hero_pixel","walk_backup.json")
	for key in ["up","left","right"]:
		directions[key] = Frames.new("hero_pixel","walk_%s_v1.json" % ("back" if key=="up" else key))
	render_pose()

func movement_input() -> Vector2:
	if not controls_enabled: return Vector2.ZERO
	return Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))-float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))).normalized()

func movement_speed() -> float:
	return 6.5 if controls_enabled and Input.is_physical_key_pressed(KEY_SHIFT) else 4.1

func _physics_process(delta: float) -> void:
	var direction := movement_input()
	var speed := movement_speed()
	if combat_enabled:
		if legacy_motion_enabled:
			var rate := (900. if direction!=Vector2.ZERO else 260.)/motion_pixels_per_m
			locomotion = locomotion.move_toward(direction*speed,rate*delta)
		else:
			locomotion.x = move_toward(locomotion.x,direction.x*speed,delta*30.)
			locomotion.y = move_toward(locomotion.y,direction.y*speed,delta*30.)
		velocity.x = locomotion.x+combat_impulse.x
		velocity.z = locomotion.y+combat_impulse.y
		if legacy_motion_enabled: combat_impulse *= maxf(0.,1.-6.*delta)
		else: combat_impulse = combat_impulse.move_toward(Vector2.ZERO,delta*18.)
	else:
		velocity.x = move_toward(velocity.x,direction.x*speed,delta*30.)
		velocity.z = move_toward(velocity.z,direction.y*speed,delta*30.)
	if not is_on_floor(): velocity.y -= 20.*delta
	else: velocity.y = -0.3
	move_and_slide()
	moving = Vector2(velocity.x,velocity.z).length()>0.12
	if moving:
		if absf(velocity.x)>absf(velocity.z): facing = "right" if velocity.x>0 else "left"
		else: facing = "down" if velocity.z>0 else "up"
		phase += delta*Vector2(velocity.x,velocity.z).length()/4.1*1.05
	render_pose()

func render_pose() -> void:
	var frames: RefCounted = directions[facing]
	var anchor: Vector2
	var height: float
	if moving:
		var sequence := [0,1,2,1]
		var index: int = sequence[int(phase*4.)%4]%frames.frames.size()
		visual.texture = frames.frames[index]
		anchor = frames.anchors[index]
		height = frames.frame_heights[index]
	else:
		visual.texture = frames.idle
		anchor = frames.idle_anchor
		height = frames.idle_height
	visual.pixel_size = 1.6/height
	# Sprite3D positive offset.y points up, unlike the 2D sprite offset.
	visual.offset = Vector2(visual.texture.get_width()/2.-anchor.x,anchor.y-visual.texture.get_height()/2.)
	# Knockback is movement, not a pose state (dash recovery also has momentum).
	if knocked_down or story_knocked:
		if knocked_art==null: knocked_art = load("res://assets/hero_pixel/ko_knocked_v2.png")
		visual.texture = knocked_art
		visual.pixel_size = 1.6/980.
		visual.offset = Vector2(knocked_art.get_width()*.5-650.5,1112.-knocked_art.get_height()*.5)
