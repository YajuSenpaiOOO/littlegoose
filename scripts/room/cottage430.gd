extends "res://scripts/room/cottage429.gd"

var making_entry:=false
var roof_batches: Array[MultiMeshInstance3D]=[]
var jambs: Array[MeshInstance3D]=[]

func lip_height(x: float,half: float,eave: float,ridge: float) -> float:
 var t:=absf(x)/half
 # A steeper shoulder flows into a shallower sweep at the last few tiles.
 var ease:=pow(t,3.)*(1.-t)
 return roof_height(x,half,eave,ridge)-(ridge-eave)*.64*ease

func gabled_roof(parent: Node3D,half: float,eave: float,ridge: float,back: float,front: float,small: bool) -> void:
 var width:=half+(.07 if small else .24)
 var rows:=6 if small else 8
 var cols:=ceili((front-back)/(.55 if small else .60))
 var run:=(front-back)/cols
 var mm:=MultiMesh.new()
 mm.transform_format=MultiMesh.TRANSFORM_3D
 mm.use_colors=true
 mm.mesh=round_tile()
 mm.instance_count=rows*(cols+1)*2
 var tiles:=MultiMeshInstance3D.new()
 tiles.name="RoundedSlate430"
 tiles.multimesh=mm
 tiles.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var ink:=slate.duplicate() as StandardMaterial3D
 ink.vertex_color_use_as_albedo=true
 ink.albedo_color=Color("b7b5bc")
 tiles.material_override=ink
 parent.add_child(tiles)
 roof_batches.append(tiles)
 var index:=0
 for side in [-1.,1.]:
  for row in rows:
   var a: float=side*width*row/rows
   var b: float=side*width*(row+1)/rows
   var ya:=lip_height(a,width,eave,ridge)
   var yb:=lip_height(b,width,eave,ridge)
   var slope:=Vector2(b-a,yb-ya)
   var angle:=atan2(slope.y*side,slope.x*side)
   var skin:=block(parent,Vector3((a+b)*.5,(ya+yb)*.5-.145,(front+back)*.5),Vector3(slope.length()+.025,.16,front-back),slate)
   skin.rotation.z=angle
   # Every other band starts at half width. Trim the end pieces to the rake.
   for col in cols+1:
    var low:=maxf(back,back+(col-.5*(row%2))*run)
    var high:=minf(front,back+(col+1-.5*(row%2))*run)
    if high-low<.05:
     mm.set_instance_transform(index,Transform3D(Basis().scaled(Vector3.ZERO),Vector3.ZERO))
    else:
     var form:=Basis.from_euler(Vector3(0,0,angle+side*.075)).scaled_local(Vector3(slope.length()+.112,.149 if row==rows-1 else .112,high-low-.014))
     mm.set_instance_transform(index,Transform3D(form,Vector3((a+b)*.5,(ya+yb)*.5+.021,(low+high)*.5)))
     var tone:=.955+float((row*11+col*7)%7)*.015
     mm.set_instance_color(index,Color(tone,tone*.988,tone))
    index+=1
  for z in [front+.013,back-.017]:
   var trim:=preload("res://scripts/room/timber_frame399.gd").new()
   parent.add_child(trim)
   var rail: Array[Vector2]=[]
   for i in 30:
    var x: float=side*width*i/29.
    rail.append(Vector2(x,lip_height(x,width,eave,ridge)-.093))
   var strip:=trim.beam399(rail,.29 if not small else .21,.24,z,"SweptRake430")
   strip.material_override=wood
  block(parent,Vector3(side*(width-.058),eave-.186,(front+back)*.5),Vector3(.27,.277,front-back+.015),wood)
 for i in cols:
  var cap:=CylinderMesh.new()
  cap.height=run+.025
  cap.top_radius=.208
  cap.bottom_radius=.208
  cap.radial_segments=12
  var piece:=mesh_at(parent,cap,Vector3(0,ridge+.075,back+(i+.5)*run),slate)
  piece.rotation.x=PI*.5

func round_tile() -> ArrayMesh:
 var st:=SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var edge: Array[Vector2]=[
  Vector2(-.50,-.34),Vector2(-.43,-.46),Vector2(-.32,-.50),Vector2(.32,-.50),
  Vector2(.43,-.46),Vector2(.50,-.34),Vector2(.50,.34),Vector2(.43,.46),
  Vector2(.32,.50),Vector2(-.32,.50),Vector2(-.43,.46),Vector2(-.50,.34)
 ]
 for i in edge.size():
  var a:=edge[i]
  var b:=edge[(i+1)%edge.size()]
  var va:=Vector3(a.x,.01,a.y)
  var vb:=Vector3(b.x,.01,b.y)
  var ta:=Vector3(a.x*.93,.50,a.y*.91)
  var tb:=Vector3(b.x*.93,.50,b.y*.91)
  slate_face(st,Vector3(0,.50,0),ta,tb)
  slate_face(st,ta,va,vb)
  slate_face(st,ta,vb,tb)
  var ba:=Vector3(a.x*.94,-.50,a.y*.93)
  var bb:=Vector3(b.x*.94,-.50,b.y*.93)
  slate_face(st,va,ba,bb)
  slate_face(st,va,bb,vb)
  slate_face(st,Vector3(0,-.50,0),bb,ba)
 st.generate_normals()
 return st.commit()

func slate_face(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3) -> void:
 for v in [a,b,c]:
  st.set_uv(Vector2(v.x+.50,v.z+.50))
  st.add_vertex(v)

func build_entry() -> void:
 making_entry=true
 super.build_entry()
 making_entry=false
 for side in [-1.,1.]:
  for i in 5:
   var inner: float=side*.925
   var outer: float=side*(1.235+.022*sin(i*2.))
   var y:=i*.345+.017
   portal_stone(PackedVector2Array([Vector2(inner,y),Vector2(outer,y+.009),Vector2(outer,y+.326),Vector2(inner,y+.317)]),i+int(side))
 for i in 11:
  var a:=PI*(i+.035)/11.
  var b:=PI*(i+.965)/11.
  var width:=1.251 if i==5 else 1.244+.025*sin(i*2.8)
  var pts:=PackedVector2Array([
   Vector2(cos(a)*.917,1.733+sin(a)*.917),Vector2(cos(b)*.917,1.733+sin(b)*.917),
   Vector2(cos(b)*width,1.733+sin(b)*width),Vector2(cos(a)*width,1.733+sin(a)*width)
  ])
  portal_stone(pts,i+2)

func block(parent: Node3D,at: Vector3,size: Vector3,ink: Material,solid:=false) -> MeshInstance3D:
 var node:=super.block(parent,at,size,ink,solid)
 if making_entry and parent==shell and ink==stone:
  node.set_meta("old_portal430",true)
  node.hide()
 return node

func polygon(parent: Node3D,points: PackedVector2Array,z: float,ink: Material) -> void:
 if making_entry and parent==shell and ink==stone:return
 super.polygon(parent,points,z,ink)

func register_cut(node: GeometryInstance3D,entries: Array[Dictionary]) -> void:
 if node.has_meta("old_portal430"):return
 super.register_cut(node,entries)

func portal_stone(points: PackedVector2Array,index: int) -> void:
 var center:=Vector2.ZERO
 for x in points:center+=x/points.size()
 var pts:=PackedVector2Array()
 # Chamfer each corner before building a separate thick stone solid.
 for i in points.size():
  var prev:=points[posmod(i-1,points.size())]
  var here:=points[i]
  var next:=points[(i+1)%points.size()]
  pts.append(here.lerp(prev,.105))
  pts.append(here.lerp(next,.105))
 if not Geometry2D.is_polygon_clockwise(pts):pts.reverse()
 var st:=SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in pts.size():
  var a:=pts[i]
  var b:=pts[(i+1)%pts.size()]
  var f:=center+(a-center)*.79
  var g:=center+(b-center)*.79
  var fa:=Vector3(f.x,f.y,FRONT+.40)
  var fb:=Vector3(g.x,g.y,FRONT+.40)
  var ea:=Vector3(a.x,a.y,FRONT+.326)
  var eb:=Vector3(b.x,b.y,FRONT+.326)
  var ba:=Vector3(a.x,a.y,FRONT-.105)
  var bb:=Vector3(b.x,b.y,FRONT-.105)
  portal_face(st,[Vector3(center.x,center.y,FRONT+.40),fa,fb],center)
  portal_face(st,[fa,ea,eb,fa,eb,fb],center)
  portal_face(st,[ea,ba,bb,ea,bb,eb],center)
 st.generate_normals()
 var part:=mesh_at(shell,st.commit(),Vector3.ZERO,stone_tint(index))
 part.name="DeepPortalStone430"
 part.set_meta("front421",true)
 jambs.append(part)

func portal_face(st: SurfaceTool,vertices: Array,center: Vector2) -> void:
 for p in vertices:
  st.set_uv((Vector2(p.x,p.y)-center)*2.2+Vector2(.5,.5))
  st.add_vertex(p)
