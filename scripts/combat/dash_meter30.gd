extends Control
var battle: Node3D
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	position=Vector2(252,17)
func _process(_delta: float) -> void: queue_redraw()
func _draw() -> void:
	if not is_instance_valid(battle.hero): return
	var ready := 1.-clampf(battle.hero.dash_cd/.55,0.,1.)
	var points := PackedVector2Array([Vector2(0,7),Vector2(7,0),Vector2(14,7),Vector2(7,14)])
	draw_colored_polygon(points,Color(.93,.84,.65,.18+.7*ready))
	draw_polyline(PackedVector2Array([points[0],points[1],points[2],points[3],points[0]]),Color(.98,.91,.73,.75),1.,true)
	draw_string(ThemeDB.fallback_font,Vector2(22,12),"Shift",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color(.96,.91,.78,.8))
