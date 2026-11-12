extends Node2D
# Local units are original hero frame pixels. Host projects upright world axes.
signal revealed
signal finished
const STAND=preload("res://assets/hero_transform284/stand_closed.png")
const RAISE=preload("res://assets/hero_transform284/raise_open.png")
var age := 0.
var playing := false
var released := false
var actor: Sprite2D
var glow: ShaderMaterial
var idle_texture: Texture2D
var idle_offset := Vector2.ZERO
var draw_scale := .595
const INTRO := 3.15
const TOTAL := 7.0
const GOLD := Color(1.,.72,.27)
const CREAM := Color(1.,.95,.73)
func _ready() -> void:
 actor=Sprite2D.new();actor.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;actor.z_index=1;add_child(actor)
 var shader=Shader.new();shader.code="shader_type canvas_item; uniform float cover=0.; void fragment(){vec4 c=texture(TEXTURE,UV);COLOR=vec4(mix(c.rgb,vec3(1.,.98,.87),cover),c.a);}"
 glow=ShaderMaterial.new();glow.shader=shader;actor.material=glow;actor.hide()
func start() -> void:
 age=0.;released=false;playing=true;actor.show();sample(0.)
func ramp(a: float,b: float,t: float) -> float:return smoothstep(a,b,t)
func cape_amount() -> float:
 return ramp(.95,1.8,age)*(1.-ramp(6.25,TOTAL,age)) if playing else 0.
func sample(t: float) -> void:
 age=t
 if not playing:return
 actor.visible=age<INTRO
 if age<1.92:
  actor.texture=STAND if age<.52 else RAISE
  actor.scale=Vector2.ONE*draw_scale
  actor.offset=Vector2(actor.texture.get_width()*.5-587.,actor.texture.get_height()*.5-1230.)
 else:
  actor.texture=idle_texture;actor.scale=Vector2.ONE;actor.offset=idle_offset
 # Silhouette takes the light without changing geometry or the foot point.
 var cover=ramp(1.02,1.7,age)*(1.-ramp(1.94,2.4,age))
 glow.set_shader_parameter("cover",cover)
 queue_redraw()
func advance(delta: float) -> void:
 if not playing:return
 sample(age+delta)
 if age>=INTRO and not released:released=true;revealed.emit()
 if age>=TOTAL:playing=false;actor.hide();queue_redraw();finished.emit()
func strip(points: PackedVector2Array,widths: PackedFloat32Array,color: Color) -> void:
 if points.size()<2:return
 var polygon=PackedVector2Array()
 for i in points.size():
  var tangent=points[mini(i+1,points.size()-1)]-points[maxi(0,i-1)]
  polygon.append(points[i]+tangent.normalized().orthogonal()*widths[i])
 for i in range(points.size()-1,-1,-1):
  var tangent=points[mini(i+1,points.size()-1)]-points[maxi(0,i-1)]
  polygon.append(points[i]-tangent.normalized().orthogonal()*widths[i])
 draw_colored_polygon(polygon,color)
func ribbon(side: float,amount: float) -> void:
 var points=PackedVector2Array();var widths=PackedFloat32Array()
 var travel=ramp(.95,1.85,age)
 var source=Vector2(-126.,-463.)
 for i in 27:
  var u=float(i)/26.
  # The first trace peels from the lamp; it settles at each shoulder as a cape.
  var shoulder=Vector2(side*78.,-277.)
  var p=shoulder+Vector2(side*(300.*sin(u*PI*.5)+60.*u),-170.*sin(u*PI)+u*210.)
  p.x+=side*sin(u*8.-age*4.)*u*16.
  p.y+=sin(u*6.-age*3.)*u*12.
  var traced=source.lerp(p,travel)
  if u>travel:break
  points.append(traced);widths.append((10.+sin(u*PI)*50.)*amount*(1.-u*.65))
 strip(points,widths,Color(GOLD,.25*amount))
 var inner=PackedFloat32Array()
 for w in widths:inner.append(w*.55)
 strip(points,inner,Color(1.,.82,.43,.85*amount))
 var line=PackedFloat32Array()
 for w in widths:line.append(maxf(1.,w*.13))
 strip(points,line,Color(CREAM,.9*amount))
func _draw() -> void:
 if not playing:return
 var cape=cape_amount()
 if cape>0.:ribbon(-1.,cape);ribbon(1.,cape)
 var lamp=Vector2(-126.,-463.)
 var beam=ramp(.68,.77,age)*(1.-ramp(1.65,2.13,age))
 if beam>0.:
  var length=1100.*ramp(.68,.83,age)
  # Narrow white core, warm middle and broad faint exterior, rooted at lens.
  for layer in [[85.,.06],[40.,.16],[16.,.50],[5.,.98]]:
   var w=float(layer[0])*beam
   draw_colored_polygon(PackedVector2Array([lamp+Vector2(-3,0),lamp+Vector2(-w,-length),lamp+Vector2(w,-length),lamp+Vector2(3,0)]),Color(CREAM,float(layer[1])*beam))
  for radius in [48.,25.,10.]:draw_circle(lamp,radius*beam,Color(CREAM,.09*beam))
 # Limited flowing sparks; no per-frame node spawning or random flicker.
 if age>.75 and age<2.6:
  var strength=ramp(.75,1.1,age)*(1.-ramp(1.85,2.6,age))
  for i in 18:
   var u=fmod(float(i)*.618+age*.42,1.)
   var angle=float(i)*2.399+age*.9
   var p=Vector2(cos(angle)*(80.+u*150.),-80.-u*580.)
   draw_line(p,p+Vector2(0,-10.-u*15.),Color(CREAM,strength*.65),2.)
 # A short expanding crest lives at chest height, never a floor ring.
 var burst=ramp(1.65,1.76,age)*(1.-ramp(1.8,2.3,age))
 if burst>0.:
  draw_arc(Vector2(0,-275),45.+(age-1.65)*300.,0,TAU,48,Color(CREAM,burst*.4),3.)
