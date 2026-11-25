extends Node2D

const FEATHER=preload("res://assets/black_goose_feather387/feather.png")
const FEATHER_REGION:=Rect2(134,415,1044,518)
const LILAC:=Color("d9a6ff")
const LIGHT:=Color("fff1ca")
const LIFE:=.68
var sparks:Array[Dictionary]=[]

func _ready() -> void:
 set_process(false)

func open(at:Vector3,arrival:bool) -> void:
 sparks.append({"point":at,"arrival":arrival,"age":0.})
 set_process(true)
 queue_redraw()

func clear() -> void:
 sparks.clear()
 set_process(false)
 queue_redraw()

func _process(delta:float) -> void:
 for spark in sparks:spark.age+=delta
 sparks=sparks.filter(func(spark:Dictionary):return spark.age<LIFE)
 queue_redraw()
 if sparks.is_empty():set_process(false)

func _draw() -> void:
 var camera:=get_viewport().get_camera_3d()
 if camera==null:return
 for spark in sparks:
  var point:Vector3=spark.point
  if camera.is_position_behind(point):continue
  var foot:=camera.unproject_position(point)
  var heart:=camera.unproject_position(point+Vector3.UP*.62)
  var unit:=clampf(foot.distance_to(heart)/35.,.74,1.65)
  var t:float=spark.age/LIFE
  var fade:=1.-smoothstep(.18,1.,t)
  var pull:=smoothstep(0.,.30,t)
  var opening:bool=spark.arrival
  var radius:=lerpf(14.,56.,ease(t,.50)) if opening else lerpf(43.,9.,pull)+maxf(0.,t-.30)*44.
  var halo:=lerpf(.08,.65,pull) if not opening and t<.30 else .6*fade
  for ring in 2:
   draw_set_transform(foot+Vector2.UP*(3.+ring*4.)*unit,0.,Vector2(unit,unit*.38))
   draw_arc(Vector2.ZERO,radius+ring*5.,0.,TAU,44,Color(LILAC,halo/(ring+1.)),2.5,true)
  draw_set_transform(Vector2.ZERO)
  var flash:=fade*smoothstep(0.,.30,t)*1.6 if not opening else fade*(1.-smoothstep(.05,.40,t))
  for i in range(3,0,-1):
   draw_circle(heart,unit*(9.+i*5.)*maxf(.1,flash),Color(LILAC,.075*flash))
  var flight:=ease(t,.58)
  var feather_alpha:=fade*(smoothstep(0.,.10,t) if opening else smoothstep(.22,.42,t))
  for i in (7 if opening else 4):
   var angle:=TAU*float(i)/(7. if opening else 4.)+.32
   var heading:=Vector2.from_angle(angle)
   var spread:=Vector2(heading.x,heading.y*.65)*(14.+float(i%3)*11.)+heading*30.
   var at:=heart+(spread*flight+Vector2.UP*(19.*flight-14.*flight*flight))*unit
   var size:=Vector2(20.+float(i%3)*5.,10.+float(i%3)*2.5)*unit
   draw_set_transform(at,angle+.70+flight*(1. if i%2==0 else -1.))
   draw_texture_rect_region(FEATHER,Rect2(-size*.5,size),FEATHER_REGION,Color(LILAC,feather_alpha*.90))
  draw_set_transform(Vector2.ZERO)
  for i in 6:
   var angle:=float(i)*TAU/6.+t*1.4
   var at:=heart+Vector2.from_angle(angle)*Vector2(radius*.94,radius*.64)*unit
   var size:float=(4.6-i%3*.7)*unit*fade
   if size<.30:continue
   draw_colored_polygon(PackedVector2Array([at-Vector2(0,size*1.65),at+Vector2(size,0),at+Vector2(0,size*1.65),at-Vector2(size,0)]),Color(LIGHT,fade))
