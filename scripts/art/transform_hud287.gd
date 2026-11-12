extends Control
var fx: Node3D
var box := StyleBoxFlat.new()
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE;set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 box.bg_color=Color(.09,.07,.12,.88);box.set_border_width_all(2);box.set_corner_radius_all(7)
func _process(_delta: float) -> void:queue_redraw()
func _draw() -> void:
 if not is_instance_valid(fx) or not fx.playing or fx.age<fx.INTRO:return
 var at=Vector2(get_viewport_rect().size.x*.5-145.,get_viewport_rect().size.y-95.)
 var red=fx.is_red();var color=Color(1.,.24,.31) if red else Color(1.,.81,.40)
 draw_style_box(panel287(color,red),Rect2(at,Vector2(290,62)))
 var text=("余光 · %.1f 秒" if red else "光能 · %.1f 秒")%fx.remaining() if fx.remaining()>0. else "光芒散去"
 draw_string(ThemeDB.fallback_font,at+Vector2(16,25),text,HORIZONTAL_ALIGNMENT_LEFT,-1,18,color)
 draw_rect(Rect2(at+Vector2(16,39),Vector2(258,7)),Color(.13,.12,.16,.85))
 draw_rect(Rect2(at+Vector2(16,39),Vector2(258.*fx.remaining()/8.,7)),color)
func panel287(color: Color,red: bool) -> StyleBoxFlat:
 box.border_color=Color(color,.4+.4*fx.pulse() if red else .5);return box
