extends Control
var battle: Node3D
var menu: PanelContainer
var heading: Label
var explanation: Label
var comparison: Label
func text114(words: String,size: int) -> Label:
 var node := Label.new();node.text=words;node.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;node.add_theme_font_size_override("font_size",size);node.add_theme_color_override("font_color",Color("eee9d7"));return node
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE;set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 menu=PanelContainer.new();menu.mouse_filter=Control.MOUSE_FILTER_STOP;add_child(menu)
 var style := StyleBoxFlat.new();style.bg_color=Color(.055,.10,.085,.96);style.border_color=Color("8d9d73");style.set_border_width_all(2);style.set_corner_radius_all(14);style.content_margin_left=30;style.content_margin_right=30;style.content_margin_top=26;style.content_margin_bottom=26;menu.add_theme_stylebox_override("panel",style)
 var box := VBoxContainer.new();box.add_theme_constant_override("separation",14);menu.add_child(box)
 heading=text114("先试一小场",28);box.add_child(heading)
 explanation=text114("45秒 · 同时三只普通团团怪 · 无选卡\n两种模式的射速、血量和进攻规则相同",19);box.add_child(explanation)
 for automatic in [false,true]:
  var button := Button.new();button.text="B  自动瞄准 · 自动射击" if automatic else "A  方向瞄准＋轻辅助 · 左键射击";button.custom_minimum_size=Vector2(520,58);button.add_theme_font_size_override("font_size",21);button.pressed.connect(func(): battle.begin114(automatic));box.add_child(button)
  for state in ["normal","hover","pressed"]:
   var skin := StyleBoxFlat.new();skin.bg_color=Color("1d3930" if state=="normal" else "345744" if state=="hover" else "48674a");skin.border_color=Color("91a77a");skin.set_border_width_all(1);skin.set_corner_radius_all(8);button.add_theme_stylebox_override(state,skin)
 comparison=text114("",17);box.add_child(comparison)
 var controls := text114("WASD 移动 · Shift 闪避 · 右键按住蹲防／按下瞬间弹反\nF2 换模式重开 · F5 当前模式重试 · Esc 提前结束",17);box.add_child(controls)
func show_menu(finished: bool) -> void:
 menu.show();heading.text="这一轮结束了" if finished else "先试一小场"
 var lines: Array[String]=[]
 for mode in ["A","B"]:
  if not battle.results114.has(mode): continue
  var r: Dictionary=battle.results114[mode]
  lines.append("%s 上一轮（%d秒）：击败%d · 弹丸命中%d/%d · 受击%d · 弹反%d"%[mode,roundi(r.seconds),r.kills,r.hits,r.shots,r.hurt,r.parries])
 comparison.text="\n".join(lines);comparison.visible=not lines.is_empty()
func _process(_delta: float) -> void:
 if menu.visible:
  var extent := get_viewport_rect().size
  menu.reset_size();menu.position=(extent-menu.size)*.5
 elif battle.active114 and not battle.combat_paused:
  battle._refresh_aim114(get_viewport().get_mouse_position())
 queue_redraw()
func _draw() -> void:
 if not battle.active114 or battle.combat_paused: return
 var camera: Camera3D=battle.camera;var origin: Vector3=battle.projectile_origin()
 var target: CharacterBody3D=battle.target114
 var color := Color(.65,.9,.85,.85) if battle.auto114 else Color(1.,.84,.42,.9)
 if is_instance_valid(target) and not target.dead:
  var points := PackedVector2Array()
  for i in 33:
   var a := TAU*i/32.;points.append(camera.unproject_position(target.global_position+Vector3(cos(a)*.65,.045,sin(a)*.65)))
  draw_polyline(points,color,2.,true)
  var at := camera.unproject_position(target.hit_area.global_position)
  for side in [-1.,1.]:
   draw_line(at+Vector2(side*18,-9),at+Vector2(side*18,9),color,2.,true)
   draw_line(at+Vector2(side*18,-9),at+Vector2(side*10,-9),color,2.,true)
  draw_line(camera.unproject_position(origin),camera.unproject_position(battle.aim114),Color(color,.28),1.,true)
 if not battle.auto114:
  var cursor := get_viewport().get_mouse_position();draw_arc(cursor,7.,0.,TAU,20,Color(.95,.95,.86,.8),1.5,true)
