extends Control
var battle: Node3D
var age229 := 0.
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE;custom_minimum_size=Vector2(28,28)
 tooltip_text="红灯：生命低于1/3，手电伤害＋35%"
func _process(delta: float) -> void:
 visible=battle.active114 and battle.flashlight_red229()
 if not visible:age229=0.;return
 if not battle.combat_paused:age229+=delta
 var screen=get_viewport_rect().size;position=Vector2(screen.x*.5-246.,43.)
 queue_redraw()
func _draw() -> void:
 var pulse=.5+.5*sin(age229*TAU*1.25)
 draw_circle(Vector2(14,14),12.,Color(1.,.12,.18,.10+.12*pulse))
 draw_circle(Vector2(14,14),8.,Color("573846"))
 draw_circle(Vector2(14,14),6.,Color(1.,.14,.2,.65+.3*pulse))
 draw_circle(Vector2(12,12),1.8,Color(1.,.85,.8,.8))
