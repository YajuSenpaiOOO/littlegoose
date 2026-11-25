extends Control

const BODY_SIZE := Vector2(302,80)
const INK := Color("694d3c")
const PAPER := Color("fff0d5")
var reveal:=0.
var phase:=0.
var body_size:=BODY_SIZE
var minimum_body_height:=0.
var left_of_anchor:=false
var label: Label
var last_anchor:=Vector2.ZERO

func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 minimum_body_height=body_size.y
 size=body_size
 pivot_offset=Vector2(body_size.x*.5,body_size.y)
 label=Label.new()
 label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 label.add_theme_font_size_override("font_size",20)
 label.add_theme_color_override("font_color",INK)
 label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 label.mouse_filter=Control.MOUSE_FILTER_IGNORE
 add_child(label)
 label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 label.offset_left=18.
 label.offset_right=-18.
 label.offset_top=10.
 label.offset_bottom=-10.
 hide()

func present(delta: float,copy: String,anchor: Vector2) -> void:
 var active:=not copy.is_empty()
 if active:
  if label.text!=copy:
   label.text=copy
   var lines:=label.get_line_count()
   var text_height:=maxi(0,lines-1)*label.get_theme_constant("line_spacing")
   for i in lines:text_height+=label.get_line_height(i)
   body_size.y=maxf(minimum_body_height,text_height+24.)
   size=body_size
   pivot_offset.y=body_size.y
   queue_redraw()
  last_anchor=anchor
 reveal=move_toward(reveal,float(active),delta*(2.8 if active else 5.))
 visible=reveal>0.
 if not visible:
  phase=0.
  return
 phase=fmod(phase+delta*2.35,TAU)
 var t:=smoothstep(0.,1.,reveal)
 modulate.a=t
 scale=Vector2.ONE*lerpf(.93,1.,t)
 if left_of_anchor:
  var bounds:=get_parent_area_size()
  position=Vector2(
   clampf(last_anchor.x-body_size.x-24.-(1.-t)*8.,8.,maxf(8.,bounds.x-body_size.x-24.)),
   clampf(last_anchor.y-body_size.y*.5+sin(phase)*2.6*t,8.,maxf(8.,bounds.y-body_size.y-8.))
  )
  return
 var viewport_size:=get_viewport_rect().size
 position=Vector2(
  clampf(last_anchor.x-body_size.x*.5,10.,maxf(10.,viewport_size.x-body_size.x-10.)),
  clampf(last_anchor.y-body_size.y-24.+(1.-t)*12.+sin(phase)*3.5*t,10.,maxf(10.,viewport_size.y-body_size.y-27.))
 )

func _draw() -> void:
 var outline:=PackedVector2Array()
 var shadow:=PackedVector2Array()
 for i in 132:
  var angle:=TAU*float(i)/132.
  var petal:=.5+.5*cos(angle*12.+.25)
  var direction:=Vector2(cos(angle),sin(angle))
  var p:=body_size*.5+Vector2(
   signf(direction.x)*pow(absf(direction.x),.59)*(body_size.x*.5-6.+5.*petal),
   signf(direction.y)*pow(absf(direction.y),.59)*(body_size.y*.5-6.+4.*petal)
  )
  outline.append(p)
  shadow.append(p+Vector2(0,4))
 draw_colored_polygon(shadow,Color(.20,.10,.07,.24))
 draw_colored_polygon(outline,PAPER)
 outline.append(outline[0])
 draw_polyline(outline,INK,2.,true)
 var dots:=[Vector3(143,87,5.5),Vector3(152,98,3.1)]
 if left_of_anchor:
  dots=[Vector3(body_size.x+7.,body_size.y*.5-3.,5.5),Vector3(body_size.x+19.,body_size.y*.5+2.,3.1)]
 for dot in dots:
  var center:=Vector2(dot.x,dot.y)
  if not left_of_anchor:
   center+=Vector2((body_size.x-BODY_SIZE.x)*.5,body_size.y-BODY_SIZE.y)
  draw_circle(center,dot.z+1.,INK,true,-1.,true)
  draw_circle(center,dot.z-1.,PAPER,true,-1.,true)
