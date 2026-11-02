extends Control
var battle: Node3D
var pulse263 := 0.
var box263 := StyleBoxFlat.new()
func _ready() -> void:
 box263.set_corner_radius_all(9)
 mouse_filter=Control.MOUSE_FILTER_IGNORE;tooltip_text="红灯：决心低于1/3，手电伤害为常态2倍"
func _process(_delta: float) -> void:
 visible=battle.active114 and battle.flashlight_red229()
 if not visible:return
 pulse263=battle.red_pulse263();size=get_viewport_rect().size;queue_redraw()
func _draw() -> void:
 var centre=Vector2(size.x*.5,56.)
 # Compact warning around health, never a whole-screen white/red flash.
 box263.bg_color=Color(.55,.03,.09,.08+.12*pulse263)
 draw_style_box(box263,Rect2(centre-Vector2(235,28),Vector2(470,54)))
 var color=Color(1.,.2,.28,.4+.5*pulse263)
 draw_line(centre+Vector2(-225,29),centre+Vector2(225,29),color,2.)
 for side in [-1.,1.]:
  var x=centre.x+side*246.
  draw_circle(Vector2(x,56.),10.,Color(.35,.05,.10,.95));draw_circle(Vector2(x,56.),6.+pulse263,color)
  draw_circle(Vector2(x-1.5,54.5),1.5,Color(1.,.86,.80,.8))
 var font=ThemeDB.fallback_font
 draw_string(font,centre+Vector2(-56,102),"红灯 · 光线×2",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color(1.,.6,.6,.65+.3*pulse263))
