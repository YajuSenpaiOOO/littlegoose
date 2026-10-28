extends Node2D
## Visual-only ribbon follows live projectile positions; damage remains on GooseBullet.
const TILE_LENGTH := 24.0
const MAX_CONTACTS := 24
const CONTACT_LIFE := 0.16
var lanes: Dictionary = {}
var muzzles: Dictionary = {}
var contacts: Array = []
var chains: Array = []
var clock := 0.0
var ribbon: Node2D
var flow_material: ShaderMaterial
static var art: Dictionary = {}

static func ensure(parent: Node) -> Node2D:
	var existing := parent.get_node_or_null("StreamArt")
	if existing != null:
		return existing
	var renderer := new()
	renderer.name = "StreamArt"
	parent.add_child(renderer)
	return renderer

static func register_bullet(bullet: Node2D) -> void:
	var renderer = ensure(bullet.get_parent())
	renderer.set_process(true)
	var lane: String = bullet.stream_lane
	if lane.is_empty():
		lane = str(bullet.get_instance_id()) # Independent split fragments never join other streams.
	if not renderer.lanes.has(lane):
		renderer.lanes[lane] = []
	renderer.lanes[lane].append(weakref(bullet))
	if bullet.stream_emitter != null and bullet.stream_emitter.get_ref() != null:
		var emitter = bullet.stream_emitter.get_ref()
		renderer.muzzles[emitter.get_instance_id()] = {"emitter": bullet.stream_emitter,
			"age": 0.0, "direction": bullet.dir, "heavy": bullet.stream_heavy}

static func contact(parent: Node, at: Vector2, direction: Vector2) -> void:
	var renderer = ensure(parent)
	renderer.set_process(true)
	for spark in renderer.contacts:
		if spark.age < 0.055 and spark.position.distance_to(at) < 10.0:
			return
	if renderer.contacts.size() >= MAX_CONTACTS:
		renderer.contacts.pop_front()
	renderer.contacts.append({"position": at, "direction": direction, "age": 0.0})

static func _load_art() -> void:
	if not art.is_empty():
		return
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/stream_v1/regions.json"))
	for key in ["muzzle", "head", "impact"]:
		var frames: Array[Texture2D] = []
		var source: Texture2D = load("res://assets/stream_v1/" + str(data[key].file))
		for bounds: Array in data[key].regions:
			var texture := AtlasTexture.new()
			texture.atlas = source
			texture.region = Rect2(bounds[0], bounds[1], bounds[2], bounds[3])
			texture.filter_clip = true
			frames.append(texture)
		art[key] = frames
	art["flow"] = load("res://assets/stream_v1/" + str(data.flow.file))
	art["tile_region"] = data.flow.tile_region

static func muzzle_texture(index: int) -> Texture2D:
	_load_art()
	return art.muzzle[index % 3]

func _ready() -> void:
	_load_art()
	z_index = 21
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ribbon = Node2D.new()
	flow_material = ShaderMaterial.new()
	flow_material.shader = preload("res://scripts/combat/stream_flow110.gdshader")
	var region: Array = art.tile_region
	flow_material.set_shader_parameter("tile_region", Vector4(region[0], region[1], region[2], region[3]))
	ribbon.material = flow_material
	ribbon.draw.connect(_draw_ribbons)
	add_child(ribbon)

func _process(delta: float) -> void:
	clock += delta
	flow_material.set_shader_parameter("flow", fmod(clock * 9.0, 1.0))
	for id in muzzles.keys():
		muzzles[id].age += delta
		if muzzles[id].age > 0.12 or muzzles[id].emitter.get_ref() == null:
			muzzles.erase(id)
	for spark in contacts:
		spark.age += delta
	contacts = contacts.filter(func(spark: Dictionary) -> bool: return spark.age < CONTACT_LIFE)
	_build_chains()
	ribbon.queue_redraw()
	queue_redraw()
	if lanes.is_empty() and muzzles.is_empty() and contacts.is_empty():
		set_process(false) # Reuse one idle renderer per world, rather than one node per shot.

func _point(bullet: Node2D) -> Vector2:
	return to_local(bullet.stream_draw_position())

func _build_chains() -> void:
	chains.clear()
	for lane in lanes.keys():
		var live: Array = []
		var refs: Array = []
		for ref: WeakRef in lanes[lane]:
			var bullet = ref.get_ref()
			if is_instance_valid(bullet) and not bullet.is_queued_for_deletion():
				live.append(bullet)
				refs.append(ref)
		if live.is_empty():
			lanes.erase(lane)
			continue
		lanes[lane] = refs
		live.reverse() # Youngest at the muzzle, oldest at the advancing front.
		var points := PackedVector2Array()
		var first = live[0]
		if first.stream_emitter != null:
			var emitter = first.stream_emitter.get_ref()
			if is_instance_valid(emitter) and muzzles.has(emitter.get_instance_id()) \
					and emitter._stream_generation == first.stream_generation:
				var origin: Vector2 = to_local(emitter._stream_visual_origin())
				if origin.distance_to(_point(first)) < 28.0:
					points.append(origin)
		var previous: Node2D = null
		for bullet: Node2D in live:
			var at := _point(bullet)
			if previous != null and (previous.stream_sequence - bullet.stream_sequence != 1 \
					or points[-1].distance_to(at) > 48.0):
				_finish_chain(points, previous)
				points = PackedVector2Array()
			points.append(at)
			previous = bullet
		_finish_chain(points, previous)

func _finish_chain(points: PackedVector2Array, front: Node2D) -> void:
	if points.size() == 1:
		points.insert(0, points[0] - front.dir * 10.0)
	chains.append({"points": points, "heavy": front.stream_heavy, "direction": front.dir})

func _draw_ribbons() -> void:
	for chain in chains:
		var points := _smooth_points(chain.points)
		var normals := PackedVector2Array()
		var distances := PackedFloat32Array([0.0])
		for i in points.size():
			var tangent := points[mini(i + 1, points.size() - 1)] - points[maxi(i - 1, 0)]
			normals.append(tangent.normalized().orthogonal())
			if i > 0:
				distances.append(distances[-1] + points[i].distance_to(points[i - 1]))
		var width := 4.4 if chain.heavy else 3.2
		for i in points.size() - 1:
			var a := normals[i] * width
			var b := normals[i + 1] * width
			var vertices := PackedVector2Array([points[i] - a, points[i + 1] - b,
				points[i + 1] + b, points[i] + a])
			var u0 := distances[i] / TILE_LENGTH
			var u1 := distances[i + 1] / TILE_LENGTH
			var uv := PackedVector2Array([Vector2(u0, 0), Vector2(u1, 0), Vector2(u1, 1), Vector2(u0, 1)])
			# Explicit triangles also handle folded wave paths and coincident samples.
			# Polygon triangulation can reject a quad at a sharp turn.
			for indices in [[0, 1, 2], [0, 2, 3]]:
				var triangle := PackedVector2Array()
				var triangle_uv := PackedVector2Array()
				for index in indices:
					triangle.append(vertices[index])
					triangle_uv.append(uv[index])
				ribbon.draw_primitive(triangle, PackedColorArray([Color.WHITE, Color.WHITE, Color.WHITE]), triangle_uv, art.flow)

func _smooth_points(points: PackedVector2Array) -> PackedVector2Array:
	# Interpolate THROUGH all live hit samples, rather than changing their trajectory.
	# Clamp overshoot so wave/corner smoothing does not create a large false arc.
	var smooth := PackedVector2Array()
	for i in points.size() - 1:
		var a := points[i]
		var b := points[i + 1]
		var before := points[maxi(i - 1, 0)]
		var after := points[mini(i + 2, points.size() - 1)]
		for step in 4:
			var point := a.cubic_interpolate(b, before, after, float(step) / 4.0)
			point.x = clampf(point.x, minf(a.x, b.x) - 1.5, maxf(a.x, b.x) + 1.5)
			point.y = clampf(point.y, minf(a.y, b.y) - 1.5, maxf(a.y, b.y) + 1.5)
			smooth.append(point)
	smooth.append(points[-1])
	return smooth

func _draw() -> void:
	for chain in chains:
		var points: PackedVector2Array = chain.points
		var tangent := (points[-1] - points[-2]).normalized()
		if tangent.is_zero_approx():
			tangent = chain.direction
		draw_set_transform(points[-1], tangent.angle())
		var size := Vector2(14, 8) * (1.2 if chain.heavy else 1.0)
		draw_texture_rect(art.head[0], Rect2(-size * 0.5, size), false)
	for state in muzzles.values():
		var emitter = state.emitter.get_ref()
		if not is_instance_valid(emitter):
			continue
		draw_set_transform(to_local(emitter._stream_visual_origin()), state.direction.angle())
		var index := int(clock / 0.045) % 3
		var size := 12.0 * (1.2 if state.heavy else 1.0)
		var alpha := clampf((0.12 - state.age) / 0.06, 0.0, 1.0)
		draw_texture_rect(art.muzzle[index], Rect2(-size * 0.5, -size * 0.5, size, size), false, Color(1, 1, 1, alpha))
	for spark in contacts:
		draw_set_transform(to_local(spark.position), spark.direction.angle())
		var index := mini(int(spark.age / 0.045), 2)
		var alpha := clampf((CONTACT_LIFE - spark.age) / 0.06, 0.0, 1.0)
		draw_texture_rect(art.impact[index], Rect2(-9, -9, 18, 18), false, Color(1, 1, 1, alpha))
	draw_set_transform(Vector2.ZERO, 0.0)
