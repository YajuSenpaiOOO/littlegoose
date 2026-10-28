extends "res://scripts/combat/hero_moment161.gd"
var wind163: Array[RefCounted]=[]
var turns163 := PackedFloat32Array([0.,1.3,2.6])
var unfolded163 := 0.
var visual_active163 := false
func _ready() -> void:
 super._ready()
 name="RecessFantasyPinwheelStage163"
 shader161.shader=preload("res://scripts/combat/pinwheel_stage163.gdshader")
 for i in 3: wind163.append(preload("res://scripts/combat/float_follow162.gd").new())
func reset_float162() -> void:
 super.reset_float162();unfolded163=0.;visual_active163=false
 for wind in wind163: wind.reset()
 turns163=PackedFloat32Array([0.,1.3,2.6])
func entrance_strength161() -> float: return 0.
func cone_strength161() -> float: return 0.
func _process(delta: float) -> void:
 super._process(delta)
 visual_active163=(left161>0. or tail161<.65) and battle.active114
 if not visual_active163: return
 var dt := 0. if battle.combat_paused else delta
 unfolded163=smoothstep(0.,.72,float_age162)
 shader161.set_shader_parameter("unfold",unfolded163)
 var camera: Camera3D=battle.camera
 var offsets := [Vector3(-2.15,1.65,0.),Vector3(2.05,1.45,0.),Vector3(-3.0,2.45,0.)]
 var speed: float=2.2+8.*exp(-float_age162*3.) if left161>0. else 2.2*exp(-tail161*7.)
 for i in wind163.size():
  var offset: Vector3=offsets[i]
  var target := foot162+Vector3.UP*.8+camera.global_basis.x*offset.x+camera.global_basis.y*offset.y
  target+=camera.global_basis.y*sin(float_age162*(1.4+float(i)*.2)+float(i)*2.)*.07
  wind163[i].advance(target,dt,6.5+float(i))
  turns163[i]+=dt*speed*(1.+float(i)*.12)
func paper_piece163(points: PackedVector2Array,color: Color) -> void:
 art161.draw_colored_polygon(points,color)
 var outline := points.duplicate();outline.append(outline[0])
 art161.draw_polyline(outline,Color(.34,.25,.34,color.a*.85),2.,false)
func draw_stage_extras161() -> void:
 if not visual_active163: return
 var camera: Camera3D=battle.camera
 var palette := [Color("f4afb2"),Color("fff0b3"),Color("afced9"),Color("d2bdde")]
 var strength := strength161()
 for i in wind163.size():
  if not wind163[i].initialized or camera.is_position_behind(wind163[i].position): continue
  var at := camera.unproject_position(wind163[i].position)
  var grow := smoothstep(float(i)*.08,.30+float(i)*.08,float_age162)
  var radius: float=[38.,32.,44.][i]*grow
  if radius<1.: continue
  if left161<=0.: at+=Vector2(sin(float(i)+tail161)*tail161*14.,tail161*tail161*35.)
  var lean := sin(float_age162*1.5+float(i))*4.
  art161.draw_line(at+Vector2(lean,radius*.15),at+Vector2(lean-4.,radius*1.5),Color(.39,.29,.30,strength),5.,false)
  art161.draw_line(at+Vector2(lean-1.,radius*.15),at+Vector2(lean-5.,radius*1.5),Color(.88,.70,.43,strength),2.,false)
  # Four folded sheets, each with a triangular shadow, around a paper fastener.
  for blade in 4:
   var a := float(turns163[i])+TAU*float(blade)/4.
   var x := Vector2(cos(a),sin(a));var y := Vector2(-x.y,x.x)
   var end := at+x*radius
   var wing := at+x*(radius*.92)+y*(radius*.82)
   var fold := at+x*(radius*.32)+y*(radius*.25)
   var color: Color=palette[(blade+i)%4];color.a=strength
   paper_piece163(PackedVector2Array([at,end,wing,fold]),color)
   paper_piece163(PackedVector2Array([at,fold,wing]),Color(color.r*.74,color.g*.71,color.b*.78,strength))
   art161.draw_line(at,end,Color(1.,.96,.82,strength*.6),1.,false)
  art161.draw_circle(at,4.5,Color(.35,.25,.35,strength))
  art161.draw_circle(at,2.5,Color(1.,.89,.52,strength))
