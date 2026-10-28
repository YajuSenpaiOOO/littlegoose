extends RefCounted
## Visuals only: original projectile motion, hit timing and damage remain authoritative.
static var entries: Dictionary = {}

static func _load() -> void:
	if not entries.is_empty():
		return
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/school_buffs_v1/regions.json"))
	for key in data:
		var entry: Dictionary = data[key].duplicate()
		var source: Texture2D = load("res://assets/school_buffs_v1/" + str(entry.file))
		var textures: Array[Texture2D] = []
		for region: Array in entry.regions:
			var texture := AtlasTexture.new()
			texture.atlas = source
			texture.region = Rect2(region[0], region[1], region[2], region[3])
			texture.filter_clip = true
			textures.append(texture)
		entry["textures"] = textures
		entries[key] = entry

static func card_style() -> StyleBoxTexture:
	_load()
	var style := StyleBoxTexture.new()
	style.texture = entries.card.textures[0]
	return style

static func draw_sweat(item: Node2D, velocity: Vector2, _age: float) -> void:
	_load()
	var entry: Dictionary = entries.sweat
	var texture: Texture2D = entry.textures[0]
	var anchor: Array = entry.anchor
	var scale := 6.8 / float(entry.core_pixels)
	# Pointed end trails the round bulb; high-speed drops elongate slightly.
	var stretch := 1.0 + 0.18 * clampf(velocity.length() / 260.0, 0.0, 1.0)
	var angle := velocity.angle() - PI * 0.5 if velocity.length_squared() > 1.0 else 0.0
	item.draw_set_transform(Vector2.ZERO, angle, Vector2(1.0, stretch))
	item.draw_texture_rect(texture, Rect2(-Vector2(anchor[0], anchor[1]) * scale, texture.get_size() * scale), false, Color(1, 1, 1, 0.9))
	item.draw_set_transform(Vector2.ZERO, 0.0)

static func draw_note(item: Node2D, index: int, age: float, gain: float) -> void:
	_load()
	var entry: Dictionary = entries.notes
	var texture: Texture2D = entry.textures[posmod(index, 3)]
	var anchor: Array = entry.anchors[posmod(index, 3)]
	var scale := 6.4 / float(entry.core_pixels[posmod(index, 3)]) * gain
	# Notes stay upright, swaying gently instead of spinning with the trajectory.
	item.draw_set_transform(Vector2.ZERO, 0.08 * sin(age * 9.0 + index))
	item.draw_texture_rect(texture, Rect2(-Vector2(anchor[0], anchor[1]) * scale, texture.get_size() * scale), false)
	item.draw_set_transform(Vector2.ZERO, 0.0)
