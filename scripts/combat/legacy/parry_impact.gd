extends Node2D
## Drawn contact flash and directional sweep. Real-time lifetime stays brief
## during existing hitstop; no additional camera or time-scale effect here.

static var _frames: Dictionary = {}
const LIFE := 0.28
const MAX_LIVE := 10
var _started := 0
var _tier := 1
var _origin := Vector2.ZERO
var _direction := Vector2.RIGHT

static func spawn(parent: Node, origin: Vector2, contact: Vector2, direction: Vector2, tier: int) -> void:
	var live := parent.get_tree().get_nodes_in_group("parry_art").filter(func(effect: Node) -> bool:
		return not effect.is_queued_for_deletion())
	for effect in live:
		if effect.get_parent() == parent and effect.global_position.distance_to(contact) < 9.0 \
				and Time.get_ticks_msec() - effect._started < 45:
			effect._tier = maxi(effect._tier, tier)
			return
	if live.size() >= MAX_LIVE:
		live[0].queue_free()
	var effect := new()
	effect._origin = origin - contact
	effect._direction = direction.normalized() if direction.length_squared() > 0.001 else Vector2.RIGHT
	effect._tier = tier
	parent.add_child(effect)
	effect.global_position = contact
	effect.reset_physics_interpolation()

static func _load_frames() -> void:
	if not _frames.is_empty():
		return
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/parry_v1/frames.json"))
	for kind in ["impact", "sweep"]:
		var frames: Array[Texture2D] = []
		var sheet: Texture2D = load("res://assets/parry_v1/" + str(data[kind].file))
		for region: Array in data[kind].regions:
			var atlas := AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = Rect2(region[0], region[1], region[2], region[3])
			atlas.filter_clip = true
			frames.append(atlas)
		_frames[kind] = frames

static func impact_texture(index: int) -> Texture2D:
	_load_frames()
	return _frames.impact[index]

func _ready() -> void:
	_load_frames()
	_started = Time.get_ticks_msec()
	z_index = 35
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	add_to_group("parry_art")

func _process(_delta: float) -> void:
	if elapsed() >= LIFE:
		queue_free()
	else:
		queue_redraw()

func elapsed() -> float:
	return float(Time.get_ticks_msec() - _started) / 1000.0

func _draw() -> void:
	var age := elapsed()
	var gain := 1.0 + 0.14 * float(_tier - 1)
	var impact_size := 30.0 * gain
	var impact_index := 0 if age < 0.035 else (1 if age < 0.095 else 2)
	var impact_alpha := clampf((0.19 - age) / 0.065, 0.0, 1.0)
	# Sweep originates at the heroine, star stays at the actual collision point.
	if age >= 0.025:
		var sweep_index := 0 if age < 0.06 else (1 if age < 0.14 else 2)
		var sweep_alpha := clampf((LIFE - age) / 0.1, 0.0, 1.0)
		draw_set_transform(_origin, _direction.angle())
		var extent := Vector2(42.0, 36.0) * gain
		draw_texture_rect(_frames.sweep[sweep_index], Rect2(-extent * 0.5, extent), false, Color(1, 1, 1, sweep_alpha))
	draw_set_transform(Vector2.ZERO, _direction.angle())
	draw_texture_rect(_frames.impact[impact_index], Rect2(Vector2.ONE * -impact_size * 0.5,
			Vector2.ONE * impact_size), false, Color(1, 1, 1, impact_alpha))
	draw_set_transform(Vector2.ZERO, 0.0)
