extends RefCounted
## Shared atlas regions. Keep generated source pixels intact; crop at runtime.

static var _regions: Dictionary = {}
static var _textures: Dictionary = {}
static var _styles: Dictionary = {}

static func region_info(id: String) -> Dictionary:
	if _regions.is_empty():
		_regions = JSON.parse_string(FileAccess.get_file_as_string("res://assets/ui37/regions.json"))
	return _regions[id]

static func texture(id: String) -> AtlasTexture:
	if not _textures.has(id):
		var info := region_info(id)
		var r: Array = info.region
		var tex := AtlasTexture.new()
		tex.atlas = load("res://assets/ui37/" + str(info.file))
		tex.region = Rect2(r[0], r[1], r[2], r[3])
		tex.filter_clip = true
		_textures[id] = tex
	return _textures[id]

static func style(id: String) -> StyleBoxTexture:
	if not _styles.has(id):
		var sb := StyleBoxTexture.new()
		sb.texture = texture(id)
		var margins: Array = region_info(id).margins
		for side in 4:
			sb.set_texture_margin(side, float(margins[side]))
		_styles[id] = sb
	return _styles[id]

static func draw_gem(canvas: CanvasItem, rect: Rect2, fill: float, tint := Color.WHITE, vertical := false, state := "gem") -> void:
	canvas.draw_texture_rect(texture("socket"), rect, false)
	if fill <= 0.0:
		return
	var tex := texture(state)
	var src := Rect2(Vector2.ZERO, tex.get_size())
	var dest := rect
	if vertical:
		src.position.y = src.size.y * (1.0 - fill)
		src.size.y *= fill
		dest.position.y += dest.size.y * (1.0 - fill)
		dest.size.y *= fill
	else:
		src.size.x *= fill
		dest.size.x *= fill
	canvas.draw_texture_rect_region(tex, dest, src, tint)
