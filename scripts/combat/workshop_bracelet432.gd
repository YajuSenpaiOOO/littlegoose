extends Control

const CORD_ART := preload("res://assets/workshop432/bracelet-cord.png")
const FEATHER_ART := preload("res://assets/workshop432/bracelet-feather.png")
const CORD_REGION := Rect2i(0,338,2172,40)
const FEATHER_REGION := Rect2i(268,32,470,1464)
const DIM := Color("948179")
const CORD_STEPS := 16
const CHARM_SIZE := Vector2(15,32)
const WRAP_DEPTH := 13.
var wrist_start:=Vector2(663,325)
var wrist_end:=Vector2(784,297)
var capacity:=0
var used:=0
var preview:=0
var flash_start:=0
var flash_end:=0
var shimmer:=0.
var swing:=0.
var tone:=Color.WHITE
var closed_pose:=false
var cord_mesh: ArrayMesh
var back_mesh: ArrayMesh
var rear:=Node2D.new()
var cord_texture: ImageTexture
var feather_texture: ImageTexture

func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 RenderingServer.canvas_item_set_custom_rect(get_canvas_item(),true,Rect2(630,278,188,110))
 cord_texture=ImageTexture.create_from_image(CORD_ART.get_image().get_region(CORD_REGION))
 feather_texture=ImageTexture.create_from_image(FEATHER_ART.get_image().get_region(FEATHER_REGION))
 cord_mesh=build_cord()
 back_mesh=build_cord(true)

func attach_behind(hand:TextureRect) -> void:
 rear.show_behind_parent=true
 rear.draw.connect(draw_back)
 hand.add_child(rear)

func put_on(gripping:bool) -> void:
 if closed_pose!=gripping:
  closed_pose=gripping
  wrist_start=Vector2(662,325) if gripping else Vector2(663,325)
  wrist_end=Vector2(777,297) if gripping else Vector2(784,297)
  cord_mesh=build_cord()
  back_mesh=build_cord(true)
 rear.scale=scale
 rear.queue_redraw()
 queue_redraw()

func cord_point(t:float,back:=false) -> Vector2:
 var arch:=sqrt(maxf(0.,1.-pow(2.*t-1.,2.)))
 var depth:=-WRAP_DEPTH*.84 if back else WRAP_DEPTH
 return wrist_start.lerp(wrist_end,t)+Vector2(0,depth*arch)

func build_cord(back:=false) -> ArrayMesh:
 var vertices:=PackedVector2Array()
 var uv:=PackedVector2Array()
 var indices:=PackedInt32Array()
 for i in CORD_STEPS+1:
  var u:=float(i)/CORD_STEPS
  var t:=.5-.5*cos(u*PI)
  var at:=cord_point(t,back)
  var tangent:=cord_point(minf(t+.002,1.),back)-cord_point(maxf(t-.002,0.),back)
  var normal:=tangent.orthogonal().normalized()*2.7
  vertices.append(at-normal)
  vertices.append(at+normal)
  uv.append(Vector2(u,0))
  uv.append(Vector2(u,1))
  if i==CORD_STEPS:break
  var j:=i*2
  indices.append_array(PackedInt32Array([j,j+1,j+2,j+1,j+3,j+2]))
 var arrays: Array=[]
 arrays.resize(Mesh.ARRAY_MAX)
 arrays[Mesh.ARRAY_VERTEX]=vertices
 arrays[Mesh.ARRAY_TEX_UV]=uv
 arrays[Mesh.ARRAY_INDEX]=indices
 var mesh:=ArrayMesh.new()
 mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
 return mesh

func charm_point(index:int,total:int) -> Vector2:
 var spread:=minf(.76,float(total-1)*.25)
 return cord_point(.53+spread*(float(index)/maxi(1,total-1)-.5))

func is_over(at:Vector2) -> bool:
 var width:=wrist_end.x-wrist_start.x
 var t:=(at.x-wrist_start.x)/width
 if t<0. or t>1.:return false
 var offset:=at.y-cord_point(t).y
 return offset>=-5. and offset<=34.

func _draw() -> void:
 if capacity<=0:return
 draw_mesh(cord_mesh,cord_texture,Transform2D.IDENTITY,tone)
 var total:=ceili(capacity/2.)
 var charm_scale:=minf(1.,5./total)
 var pulse:=DIM.lerp(Color.WHITE,.66+.20*sin(shimmer))
 for i in total:
  var at:=charm_point(i,total)
  var tilt:=lerpf(-.16,.12,float(i)/maxi(1,total-1))+swing
  var offset:=2*i
  draw_set_transform(at+Vector2(0,1),tilt,Vector2.ONE*charm_scale)
  for side in 2:
   var slot:=offset+side
   var ink:=DIM
   if slot<used:ink=Color.WHITE
   elif slot<preview:ink=pulse
   elif slot>=capacity:ink=DIM.darkened(.24)
   if slot>=flash_start and slot<flash_end:
    var wave:=.5-.5*cos(shimmer)
    ink=ink.lerp(Color(1.42,1.31,1.02),.25+.61*wave)
   draw_charm_half(side,ink*tone)
 draw_set_transform(Vector2.ZERO)

func draw_back() -> void:
 if capacity<=0:return
 rear.draw_mesh(back_mesh,cord_texture,Transform2D.IDENTITY,tone*Color(.60,.52,.48))

func draw_charm_half(side:int,ink:Color) -> void:
 var source_size:=feather_texture.get_size()
 var split:=floorf(source_size.x*.51)
 var left_width:=CHARM_SIZE.x*.51
 var x:float=0. if side==0 else split
 var width:float=split if side==0 else source_size.x-split
 var draw_x:float=-CHARM_SIZE.x*.5+(0. if side==0 else left_width)
 var draw_width:float=left_width if side==0 else CHARM_SIZE.x-left_width
 draw_texture_rect_region(feather_texture,Rect2(draw_x,0,draw_width,CHARM_SIZE.y),
  Rect2(x,0,width,source_size.y),ink)
