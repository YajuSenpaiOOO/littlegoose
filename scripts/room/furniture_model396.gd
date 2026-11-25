extends Node3D
# Real geometry controls silhouette, perspective, depth, lighting AND the shadow.
# Atlas contains flat material surfaces, never a projected complete desk image.
var pieces396: Array[MeshInstance3D]=[]
var legs396: Array[MeshInstance3D]=[]
var lamp_anchor396:=Vector3(.88,1.60,-.20)
var wood396: ShaderMaterial
var detail396: StandardMaterial3D
var brass396: StandardMaterial3D
var paper396: StandardMaterial3D
func _init() -> void:
 name="SolidPaintedFurniture396"
 wood396=ShaderMaterial.new();wood396.shader=preload("res://scripts/room/wood395.gdshader")
 wood396.set_shader_parameter("paint",load("res://assets/room395/wood-atlas.png"))
 detail396=paint396("details-atlas.png",Color(.74,.77,.80))
 brass396=plain396("8e6d35");paper396=plain396("c9bda4")
 # Build explicitly after choosing furniture kind.
func plain396(color: String) -> StandardMaterial3D:
 var m:=StandardMaterial3D.new();m.albedo_color=Color(color);m.roughness=.95;m.specular_mode=BaseMaterial3D.SPECULAR_DISABLED;return m
func paint396(file: String,tint: Color) -> StandardMaterial3D:
 var m:=plain396("ffffff");m.albedo_texture=load("res://assets/room395/"+file);m.albedo_color=tint
 m.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS;return m
func uv396(uv: Vector2,tile: Vector2i) -> Vector2:return Vector2(tile)*.5+Vector2(.004,.004)+uv*.492
func piece396(mesh: Mesh,at: Vector3,mat: Material,label: String) -> MeshInstance3D:
 var n:=MeshInstance3D.new();n.mesh=mesh;n.position=at;n.material_override=mat;n.name=label
 n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON;add_child(n);pieces396.append(n);return n
func vertex396(st: SurfaceTool,p: Vector3,normal: Vector3,uv: Vector2,tile: Vector2i) -> void:
 st.set_normal(normal);st.set_uv(uv396(uv,tile));st.add_vertex(p)
func rounded_box396(size: Vector3,bevel: float,tile: Vector2i=Vector2i.ZERO,front_tile: Vector2i=Vector2i(-1,-1)) -> ArrayMesh:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var half:=size*.5;var inner:=half-Vector3.ONE*bevel
 # Subdivided rounded cuboid with per-face UVs, including actual top/side/bevel faces.
 for face in [[Vector3.RIGHT,Vector3.FORWARD,Vector3.UP],[Vector3.LEFT,Vector3.BACK,Vector3.UP],[Vector3.UP,Vector3.RIGHT,Vector3.FORWARD],[Vector3.DOWN,Vector3.RIGHT,Vector3.BACK],[Vector3.BACK,Vector3.RIGHT,Vector3.UP],[Vector3.FORWARD,Vector3.LEFT,Vector3.UP]]:
  var normal: Vector3=face[0];var u: Vector3=face[1];var v: Vector3=face[2]
  var uh: float=(u*half).length();var vh: float=(v*half).length()
  var us: Array[float]=[-uh,-uh+bevel,uh-bevel,uh];var vs: Array[float]=[-vh,-vh+bevel,vh-bevel,vh]
  var sample_tile: Vector2i=front_tile if normal==Vector3.BACK and front_tile.x>=0 else tile
  for j in 3:
   for i in 3:
    for index in [0,2,1,0,3,2]:
     var ij: Vector2i=[Vector2i(i,j),Vector2i(i+1,j),Vector2i(i+1,j+1),Vector2i(i,j+1)][index]
     var p: Vector3=(normal*half)+u*us[ij.x]+v*vs[ij.y]
     var q:=p.clamp(-inner,inner);var n: Vector3=(p-q).normalized()
     vertex396(st,q+n*bevel,n,Vector2((us[ij.x]/uh+1.)*.5,(1.-vs[ij.y]/vh)*.5),sample_tile)
 return st.commit()
func lathe396(profile: Array[Vector2],tile: Vector2i,caps: bool=true) -> ArrayMesh:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var bottom: float=profile[0].y;var top: float=profile[-1].y
 for j in range(profile.size()-1):
  var a: Vector2=profile[j];var b: Vector2=profile[j+1]
  var slope: Vector2=(b-a).normalized()
  for i in 24:
   for ij in [Vector2i(i,j),Vector2i(i+1,j),Vector2i(i+1,j+1),Vector2i(i,j),Vector2i(i+1,j+1),Vector2i(i,j+1)]:
    var angle: float=TAU*float(ij.x)/24.;var p: Vector2=profile[ij.y]
    var n:=Vector3(cos(angle)*slope.y,-slope.x,sin(angle)*slope.y).normalized()
    vertex396(st,Vector3(cos(angle)*p.x,p.y,sin(angle)*p.x),n,Vector2(float(ij.x)/24.,1.-(p.y-bottom)/maxf(top-bottom,.001)),tile)
 if caps:
  for end in [0,profile.size()-1]:
   var p: Vector2=profile[end];var normal:=Vector3.DOWN if end==0 else Vector3.UP
   for i in 24:
    var angles: Array[float]=[TAU*float(i)/24.,TAU*float(i+1)/24.]
    if end!=0:angles.reverse()
    vertex396(st,Vector3(cos(angles[0])*p.x,p.y,sin(angles[0])*p.x),normal,Vector2(.5+.5*cos(angles[0]),.5+.5*sin(angles[0])),tile)
    vertex396(st,Vector3(0,p.y,0),normal,Vector2(.5,.5),tile)
    vertex396(st,Vector3(cos(angles[1])*p.x,p.y,sin(angles[1])*p.x),normal,Vector2(.5+.5*cos(angles[1]),.5+.5*sin(angles[1])),tile)
 return st.commit()
var kind396:=""
var surface396: StandardMaterial3D
var ornament396: ShaderMaterial
func build396(kind: String) -> void:
 kind396=kind;name="Solid396_"+kind
 surface396=StandardMaterial3D.new();surface396.albedo_texture=load("res://assets/room396/surfaces.png")
 surface396.albedo_color=Color(.65,.68,.71);surface396.roughness=1.;surface396.specular_mode=BaseMaterial3D.SPECULAR_DISABLED
 ornament396=ShaderMaterial.new();ornament396.shader=preload("res://scripts/room/wood395.gdshader")
 ornament396.set_shader_parameter("paint",load("res://assets/room396/surfaces.png"))
 if kind=="tea":tea396()
 elif kind=="goose_stool":stool396()
 else:chair396(kind=="tea_chair")
func leg396(at: Vector3,height: float,radius: float) -> void:
 var profile: Array[Vector2]=[]
 for p in [Vector2(.8,0),Vector2(1.,.05),Vector2(.95,.14),Vector2(.60,.5),Vector2(.7,.62),Vector2(1.2,.70),Vector2(1.05,.80),Vector2(.8,.90),Vector2(1.,1.)]:profile.append(Vector2(p.x*radius,.008+(height-.008)*p.y))
 legs396.append(piece396(lathe396(profile,Vector2i(0,1)),at,wood396,"TurnedLeg"))
func tube396(points: Array[Vector3],radius: float,mat: Material,label: String,tile: Vector2i=Vector2i.ZERO) -> MeshInstance3D:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var rights: Array[Vector3]=[];var backs: Array[Vector3]=[]
 for j in points.size():
  var axis: Vector3=(points[mini(j+1,points.size()-1)]-points[maxi(j-1,0)]).normalized()
  var reference:=Vector3.UP if absf(axis.dot(Vector3.UP))<.9 else Vector3.RIGHT
  var right:=axis.cross(reference).normalized();rights.append(right);backs.append(right.cross(axis).normalized())
 for j in range(points.size()-1):
  for i in 10:
   for ij in [Vector2i(i,j),Vector2i(i+1,j),Vector2i(i+1,j+1),Vector2i(i,j),Vector2i(i+1,j+1),Vector2i(i,j+1)]:
    var angle: float=TAU*float(ij.x)/10.;var n: Vector3=rights[ij.y]*cos(angle)+backs[ij.y]*sin(angle)
    vertex396(st,points[ij.y]+n*radius,n,Vector2(float(ij.x)/10.,float(ij.y)/float(points.size()-1)),tile)
 return piece396(st.commit(),Vector3.ZERO,mat,label)
func soft_disc396(rx: float,rz: float,cy: float,thickness: float,tile: Vector2i) -> ArrayMesh:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var radii: Array[float]=[0.,.20,.40,.60,.80,.92,1.]
 for side in [-1.,1.]:
  for j in 6:
   for i in 40:
    var triangles: Array[Vector2i]=[Vector2i(i,j),Vector2i(i+1,j),Vector2i(i+1,j+1),Vector2i(i,j),Vector2i(i+1,j+1),Vector2i(i,j+1)]
    if side>0.:triangles.reverse()
    for ij in triangles:
     var r: float=radii[ij.y];var angle: float=TAU*float(ij.x)/40.
     var x: float=rx*r*cos(angle);var z: float=rz*r*sin(angle);var y: float=side*thickness*sqrt(maxf(0.,1.-r*r))
     vertex396(st,Vector3(x,cy+y,z),Vector3(x/(rx*rx),y/(thickness*thickness),z/(rz*rz)).normalized(),Vector2(.5+.5*r*cos(angle),.5+.5*r*sin(angle)),tile)
 return st.commit()
func ribbon396(points: Array[Vector3],width: float) -> void:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for j in range(points.size()-1):
  for ij in [Vector2i(0,j),Vector2i(1,j),Vector2i(1,j+1),Vector2i(0,j),Vector2i(1,j+1),Vector2i(0,j+1)]:
   var p: Vector3=points[ij.y]+Vector3(0,(float(ij.x)-.5)*width,0)
   vertex396(st,p,Vector3.FORWARD,Vector2(float(ij.y)/float(points.size()-1),float(ij.x)*.5),Vector2i.ZERO)
 var m:=detail396.duplicate() as StandardMaterial3D;m.cull_mode=BaseMaterial3D.CULL_DISABLED
 var n:=piece396(st.commit(),Vector3.ZERO,m,"CreamRibbon");n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
func bow396(at: Vector3) -> void:
 for side in [-1.,1.]:
  var loop: Array[Vector3]=[]
  for i in 17:
   var t: float=float(i)/16.*PI
   loop.append(at+Vector3(side*.13*sin(t),.045*sin(2.*t),-.028*sin(t)))
  ribbon396(loop,.045)
  var tail: Array[Vector3]=[at,at+Vector3(side*.035,-.07,-.02),at+Vector3(side*.06,-.16,-.01)]
  # Vertical tail is a small folded strip, width along X rather than Y.
  var n:=piece396(rounded_box396(Vector3(.045,.14,.012),.004),at+Vector3(side*.05,-.09,-.01),paper396,"RibbonTail")
  n.rotation_degrees.z=side*12.;n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 piece396(soft_disc396(.035,.026,0,.025,Vector2i.ZERO),at,paper396,"BowKnot").rotation_degrees.x=90.
func chair396(soft: bool) -> void:
 for x in [-.23,.23]:
  for z in [-.21,.21]:leg396(Vector3(x,0,z),.57,.038)
 piece396(lathe396([Vector2(.27,.54),Vector2(.31,.56),Vector2(.31,.60),Vector2(.28,.615)],Vector2i.ZERO),Vector3.ZERO,wood396,"RoundSeatFrame")
 piece396(soft_disc396(.29,.27,.65,.055,Vector2i(1,1)),Vector3.ZERO,detail396,"GinghamSeat")
 for x in [-.22,.22]:tube396([Vector3(x,.58,-.22),Vector3(x,.85,-.27),Vector3(x,1.13,-.29)],.026,wood396,"BackPost",Vector2i(0,1))
 var board:=piece396(soft_disc396(.29,.31,0,.045,Vector2i(1,1)),Vector3(0,1.03,-.26),ornament396,"FeatherBackboard")
 board.rotation_degrees.x=90.
 if soft:
  var panel:=piece396(soft_disc396(.235,.255,0,.027,Vector2i(1,1)),Vector3(0,1.03,-.205),detail396,"GinghamBackPad")
  panel.rotation_degrees.x=90.
 for z in [-.19,.19]:tube396([Vector3(-.23,.22,z),Vector3(.23,.22,z)],.018,wood396,"ChairStretcher")
 bow396(Vector3(0,.76,-.32))
 rotation_degrees.y=90. if soft else 180.
func stool396() -> void:
 for angle in [0.,TAU/3.,TAU*2./3.]:leg396(Vector3(cos(angle)*.17,0,sin(angle)*.17),.32,.030)
 piece396(lathe396([Vector2(.21,.29),Vector2(.245,.31),Vector2(.245,.345)],Vector2i.ZERO),Vector3.ZERO,wood396,"StoolWoodRim")
 piece396(soft_disc396(.25,.25,.385,.065,Vector2i(0,1)),Vector3.ZERO,surface396,"PlumGooseCushion")
 var hem:=piece396(lathe396([Vector2(.248,.345),Vector2(.255,.36)],Vector2i.ZERO,false),Vector3.ZERO,detail396,"CreamCushionHem")
func cloth396() -> ArrayMesh:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for j in 10:
  for i in 80:
   for ij in [Vector2i(i,j),Vector2i(i+1,j+1),Vector2i(i+1,j),Vector2i(i,j),Vector2i(i,j+1),Vector2i(i+1,j+1)]:
    var angle: float=TAU*float(ij.x)/80.;var r: float=.70*float(ij.y)/10.
    r+=.009*cos(angle*20.)*pow(float(ij.y)/10.,8.)
    var y: float=1.009+.002*sin(angle*4.)*pow(float(ij.y)/10.,4.)
    vertex396(st,Vector3(cos(angle)*r,y,sin(angle)*r),Vector3.UP,Vector2(.5+cos(angle)*r/1.43,.5+sin(angle)*r/1.43),Vector2i.ZERO)
 return st.commit()
func tea396() -> void:
 piece396(lathe396([Vector2(.74,.90),Vector2(.79,.925),Vector2(.79,.98),Vector2(.76,1.)],Vector2i.ZERO),Vector3.ZERO,wood396,"BevelledRoundTop")
 for x in [-.48,.48]:
  for z in [-.40,.40]:leg396(Vector3(x,0,z),.92,.049)
 for side in [-1.,1.]:tube396([Vector3(-.48,.23,side*.4),Vector3(.48,.23,-side*.4)],.025,wood396,"CrossStretcher")
 var cloth:=piece396(cloth396(),Vector3.ZERO,surface396,"ScallopedEmbroideredCloth")
 cloth.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 pot396(Vector3(-.21,1.012,-.16))
 cup396(Vector3(-.24,1.012,.26),1.,false)
 cup396(Vector3(.27,1.012,.25),.72,true)
 flowers396(Vector3(.29,1.012,-.19))
func pot396(at: Vector3) -> void:
 piece396(lathe396([Vector2(.10,0),Vector2(.12,.025),Vector2(.175,.10),Vector2(.18,.15),Vector2(.15,.24),Vector2(.10,.27)],Vector2i(1,0)),at,surface396,"GooseTeapotBody")
 piece396(lathe396([Vector2(.115,.27),Vector2(.12,.285),Vector2(.08,.31),Vector2(.02,.32)],Vector2i(1,0)),at,surface396,"TeapotLid")
 piece396(lathe396([Vector2(.025,0),Vector2(.03,.025),Vector2(.015,.04)],Vector2i.ZERO),at+Vector3(0,.32,0),brass396,"LidKnob")
 tube396([at+Vector3(-.13,.12,0),at+Vector3(-.23,.19,0),at+Vector3(-.32,.30,0)],.035,surface396,"TeapotSpout",Vector2i(1,0))
 var handle: Array[Vector3]=[]
 for i in 17:
  var angle: float=-PI*.5+PI*float(i)/16.;handle.append(at+Vector3(.14+.12*cos(angle),.15+.12*sin(angle),0))
 tube396(handle,.022,surface396,"TeapotHandle",Vector2i(1,0))
func cup396(at: Vector3,scale_cup: float,plum: bool) -> void:
 var mat: Material=surface396
 var tile:=Vector2i(1,0)
 if plum:tile=Vector2i(0,1)
 var start: int=pieces396.size()
 piece396(lathe396([Vector2(.09,0),Vector2(.13,.012),Vector2(.13,.022),Vector2(.10,.03)],Vector2i(1,0)),Vector3.ZERO,surface396,"TeaSaucer")
 # Closed wall section gives cup a visible rim and actual hollow interior.
 piece396(lathe396([Vector2(.055,.03),Vector2(.085,.06),Vector2(.095,.15),Vector2(.087,.15),Vector2(.077,.065)],tile,false),Vector3.ZERO,mat,"TeaCupWall")
 piece396(lathe396([Vector2(.079,.117),Vector2(.079,.12)],Vector2i.ZERO),Vector3.ZERO,plain396("7d4926"),"TeaSurface")
 var handle: Array[Vector3]=[]
 for i in 13:
  var angle: float=-PI*.5+PI*float(i)/12.;handle.append(Vector3(.08+.055*cos(angle),.095+.045*sin(angle),0))
 tube396(handle,.012,mat,"CupHandle",tile)
 for i in range(start,pieces396.size()):pieces396[i].scale=Vector3.ONE*scale_cup;pieces396[i].position=at
func flowers396(at: Vector3) -> void:
 var glass:=plain396("abc1ae");glass.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;glass.albedo_color=Color(.65,.78,.72,.22);glass.cull_mode=BaseMaterial3D.CULL_DISABLED
 var vase:=piece396(lathe396([Vector2(.07,0),Vector2(.09,.05),Vector2(.08,.16),Vector2(.045,.21),Vector2(.05,.24)],Vector2i.ZERO,false),at,glass,"SmallGlassVase")
 vase.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var green:=plain396("65764a");var cream:=plain396("e5dbc1");cream.cull_mode=BaseMaterial3D.CULL_DISABLED
 var petals:=SurfaceTool.new();petals.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 3:
  var end:=at+Vector3((float(i)-1.)*.075,.38+float(i%2)*.075,-.015*float(i))
  tube396([at+Vector3(0,.03,0),end],.004,green,"DaisyStem")
  for k in 7:
   var angle: float=TAU*float(k)/7.;var axis:=Vector3(cos(angle),sin(angle),.10).normalized();var right:=Vector3(-sin(angle),cos(angle),0)
   var center: Vector3=end+axis*.023
   for j in 10:
    for a in [TAU*float(j)/10.,TAU*float(j+1)/10.,-100.]:
     var p: Vector3=center if a==-100. else center+axis*cos(a)*.024+right*sin(a)*.011
     petals.set_normal(Vector3.BACK);petals.set_uv(Vector2.ZERO);petals.add_vertex(p)
  var sphere:=SphereMesh.new();sphere.radius=.014;sphere.height=.028
  piece396(sphere,end,plain396("b99a45"),"DaisyCenter")
 var petal_mesh:=piece396(petals.commit(),Vector3.ZERO,cream,"DaisyPetals")
 petal_mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
