extends RefCounted

var frames: Array[Texture2D] = []
var anchors: Array[Vector2] = []
var frame_heights: Array[float] = []
var body_height: float = 1.0
var idle: Texture2D
var idle_anchor: Vector2
var idle_height: float = 1.0

func _init(folder: String = "hero_v2", config: String = "walk_front.json") -> void:
	var base := "res://assets/%s/" % folder
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(base + config))
	var sheet: Texture2D = load(base + str(data.get("sheet_file", "walk_front_v2.png")))
	body_height = float(data.body_height)
	for f: Dictionary in data.frames:
		var atlas := AtlasTexture.new()
		atlas.atlas = load(base + str(f.sheet_file)) if f.has("sheet_file") else sheet
		atlas.region = Rect2(f.region[0], f.region[1], f.region[2], f.region[3])
		atlas.filter_clip = true
		frames.append(atlas)
		anchors.append(Vector2(f.foot[0], f.foot[1]))
		frame_heights.append(float(f.get("body_height", body_height)))
	if data.idle.has("region"):
		var idle_atlas := AtlasTexture.new()
		idle_atlas.atlas = load(base + str(data.idle.sheet_file))
		var r: Array = data.idle.region
		idle_atlas.region = Rect2(r[0], r[1], r[2], r[3])
		idle_atlas.filter_clip = true
		idle = idle_atlas
	elif data.idle.has("frame"):
		idle = frames[int(data.idle.frame)]
	else:
		idle = load(base + "idle_front_v2.png")
	idle_anchor = Vector2(data.idle.foot[0], data.idle.foot[1])
	idle_height = float(data.idle.body_height)

func draw_pose(canvas: CanvasItem, index: int, floor_at: Vector2, height_px: float) -> void:
	var factor := height_px / frame_heights[index]
	canvas.draw_texture_rect(frames[index], Rect2(floor_at - anchors[index] * factor, frames[index].get_size() * factor), false)

func offset_for(index: int) -> Vector2:
	return frames[index].get_size() * 0.5 - anchors[index]
