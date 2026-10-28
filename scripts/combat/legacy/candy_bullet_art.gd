extends Node2D
## Authored ordinary-shot skins and bounded contact/emission flashes.
static var default_variant := 0 # 0 pearl A, 1 comet B, 2 original (preview comparison).
static var particle_trail_enabled := true
static var art: Dictionary = {}
const MAX_FLASHES := 32
const MAX_TRAIL_PARTICLES := 128
var flashes: Array = []
var trail_particles: Array[Dictionary] = []
var _visual_rng := RandomNumberGenerator.new()
var local_coordinates := false # 3D adapter: root already projects the world anchor.

static func _load_art() -> void:
	if not art.is_empty():
		return
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/candy_bullets_v1/regions.json"))
	for key in ["pearl", "pearl_core", "comet", "impact", "muzzle"]:
		var entry: Dictionary = data[key]
		var source: Texture2D = load("res://assets/candy_bullets_v1/" + str(entry.file))
		var frames: Array[Texture2D] = []
		for bounds: Array in entry.regions:
			var texture := AtlasTexture.new()
			texture.atlas = source
			texture.region = Rect2(bounds[0], bounds[1], bounds[2], bounds[3])
			texture.filter_clip = true
			frames.append(texture)
		art[key] = entry.duplicate()
		art[key]["textures"] = frames

static func draw_projectile(item: Node2D, variant: int, facing: Vector2, age: float, gain: float) -> void:
	_load_art()
	var entry: Dictionary = art.pearl if variant == 0 else art.comet
	if variant == 0 and particle_trail_enabled:
		entry = art.pearl_core
	var texture: Texture2D = entry.textures[0]
	var scale := float(entry.core_world) / float(entry.core_pixels) * gain
	var pulse := 1.0 + 0.035 * sin(age * 15.0)
	var anchor: Array = entry.anchor
	item.draw_set_transform(Vector2.ZERO, facing.angle())
	var top_left := -Vector2(anchor[0], anchor[1]) * scale * pulse
	item.draw_texture_rect(texture, Rect2(top_left, texture.get_size() * scale * pulse), false)
	item.draw_set_transform(Vector2.ZERO, 0.0)

static func _renderer(parent: Node):
	var renderer = parent.get_node_or_null("CandyBulletArt")
	if renderer == null:
		renderer = new()
		renderer.name = "CandyBulletArt"
		parent.add_child(renderer)
	return renderer

static func trail(parent: Node, at: Vector2, facing: Vector2, gain: float) -> void:
	if not particle_trail_enabled:
		return
	var renderer = _renderer(parent)
	if renderer.trail_particles.size() >= MAX_TRAIL_PARTICLES:
		return # Drop decorative emissions; never affect projectile simulation.
	var rng: RandomNumberGenerator = renderer._visual_rng
	renderer.trail_particles.append({
		"position": at - facing * 2.2 * gain,
		"velocity": -facing * rng.randf_range(5.0, 12.0) + facing.orthogonal() * rng.randf_range(-12.0, 12.0),
		"age": 0.0, "life": rng.randf_range(0.18, 0.27),
		"size": rng.randf_range(4.4, 6.4) * gain,
		"angle": rng.randf_range(-0.6, 0.6), "spin": rng.randf_range(-4.0, 4.0)
	})
	renderer.set_process(true)
	renderer.queue_redraw()

static func emit(parent: Node, at: Vector2, direction: Vector2, kind: String, variant: int, gain := 1.0) -> void:
	if variant < 0 or variant > 1:
		return
	var renderer = _renderer(parent)
	for flash in renderer.flashes:
		if flash.kind == kind and flash.age < 0.045 and flash.position.distance_to(at) < 8.0:
			return # Merge only visuals; each projectile still deals its own damage.
	if renderer.flashes.size() >= MAX_FLASHES:
		renderer.flashes.pop_front()
	renderer.flashes.append({"position": at, "direction": direction, "kind": kind,
		"variant": variant, "gain": gain, "age": 0.0})
	renderer.set_process(true)
	renderer.queue_redraw()

func _ready() -> void:
	_load_art()
	_visual_rng.randomize() # Separate cosmetic randomness from gameplay RNG.
	z_index = 24
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF

func _process(delta: float) -> void:
	for i in range(trail_particles.size() - 1, -1, -1):
		var particle := trail_particles[i]
		particle.age += delta
		if not particle_trail_enabled or particle.age >= particle.life:
			trail_particles.remove_at(i)
			continue
		particle.position += particle.velocity * delta
		particle.velocity *= exp(-5.0 * delta)
		particle.angle += particle.spin * delta
	for flash in flashes:
		flash.age += delta
	flashes = flashes.filter(func(flash: Dictionary) -> bool:
		return flash.age < (0.09 if flash.kind == "muzzle" else 0.18))
	queue_redraw()
	if flashes.is_empty() and trail_particles.is_empty():
		set_process(false)

func _draw() -> void:
	# Shared authored star texture; particles detach in world space.
	for particle in trail_particles:
		var progress: float = particle.age / particle.life
		var size: float = particle.size * (1.0 - 0.65 * progress)
		var alpha := (1.0 - progress) * 0.85
		draw_set_transform(particle.position if local_coordinates else to_local(particle.position), particle.angle)
		draw_texture_rect(art.muzzle.textures[0], Rect2(-size * 0.5, -size * 0.5, size, size), false, Color(1, 1, 1, alpha))
	for flash in flashes:
		var muzzle: bool = flash.kind == "muzzle"
		var life := 0.09 if muzzle else 0.18
		var index := mini(int(flash.age / (life / 3.0)), 2)
		var entry: Dictionary = art.muzzle if muzzle else art.impact
		var size: float = (8.0 if muzzle else 12.0) * flash.gain
		var alpha := clampf((life - flash.age) / (life * 0.35), 0.0, 1.0)
		draw_set_transform(flash.position if local_coordinates else to_local(flash.position), flash.direction.angle())
		draw_texture_rect(entry.textures[index], Rect2(-size * 0.5, -size * 0.5, size, size), false, Color(1, 1, 1, alpha))
	draw_set_transform(Vector2.ZERO, 0.0)
