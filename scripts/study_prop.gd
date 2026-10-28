extends StaticBody2D
var visual: Sprite2D
var footprint := Rect2(-25,-15,50,25)
var label := ""
var guides := false

func configure(path: String,foot: Vector2,visible_height: float,display_height: float,area: Rect2) -> void:
	footprint = area
	visual = Sprite2D.new()
	visual.texture = load(path)
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	visual.scale = Vector2.ONE*(display_height/visible_height)
	visual.offset = visual.texture.get_size()*0.5-foot
	add_child(visual)
	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = area.size
	collision.shape = rectangle
	collision.position = area.get_center()
	add_child(collision)

func _draw() -> void:
	if not guides: return
	draw_rect(footprint,Color(0.9,0.7,0.2,0.8),false,2)
	draw_circle(Vector2.ZERO,4,Color.CYAN)
