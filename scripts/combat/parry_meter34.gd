extends Control
var battle: Node3D
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	position=Vector2(330,17)
func _process(_delta: float) -> void: queue_redraw()
func _draw() -> void:
	if not is_instance_valid(battle.hero): return
	var hero: CharacterBody3D=battle.hero
	var ready := 1.-clampf(hero.parry_cd,0.,1.)
	draw_rect(Rect2(0,4,12,12),Color(.96,.84,.62,.2+.6*ready),false,1.)
	draw_rect(Rect2(2,6,8*ready,8),Color(1.,.85,.55,.9 if hero.parry_t>0. else .55))
	draw_string(ThemeDB.fallback_font,Vector2(20,14),"右键",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color(.96,.91,.78,.8))
