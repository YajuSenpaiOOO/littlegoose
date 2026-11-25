extends Node3D
# Real geometry controls silhouette, perspective, depth, lighting AND the shadow.
# Atlas contains flat material surfaces, never a projected complete desk image.
var pieces395: Array[MeshInstance3D]=[]
var legs395: Array[MeshInstance3D]=[]
var lamp_anchor395:=Vector3(.88,1.60,-.20)
var wood395: ShaderMaterial
var detail395: StandardMaterial3D
var brass395: StandardMaterial3D
var paper395: StandardMaterial3D
func _init() -> void:
 name="SolidPaintedDesk395"
 wood395=ShaderMaterial.new();wood395.shader=preload("res://scripts/room/wood395.gdshader")
 wood395.set_shader_parameter("paint",load("res://assets/room395/wood-atlas.png"))
 detail395=paint395("details-atlas.png",Color(.74,.77,.80))
 brass395=plain395("8e6d35");paper395=plain395("c9bda4")
 build395()
func plain395(color: String) -> StandardMaterial3D:
 var m:=StandardMaterial3D.new();m.albedo_color=Color(color);m.roughness=.95;m.specular_mode=BaseMaterial3D.SPECULAR_DISABLED;return m
func paint395(file: String,tint: Color) -> StandardMaterial3D:
 var m:=plain395("ffffff");m.albedo_texture=load("res://assets/room395/"+file);m.albedo_color=tint
 m.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS;return m
func uv395(uv: Vector2,tile: Vector2i) -> Vector2:return Vector2(tile)*.5+Vector2(.004,.004)+uv*.492
func piece395(mesh: Mesh,at: Vector3,mat: Material,label: String) -> MeshInstance3D:
 var n:=MeshInstance3D.new();n.mesh=mesh;n.position=at;n.material_override=mat;n.name=label
 n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON;add_child(n);pieces395.append(n);return n
func vertex395(st: SurfaceTool,p: Vector3,normal: Vector3,uv: Vector2,tile: Vector2i) -> void:
 st.set_normal(normal);st.set_uv(uv395(uv,tile));st.add_vertex(p)
func rounded_box395(size: Vector3,bevel: float,tile: Vector2i=Vector2i.ZERO,front_tile: Vector2i=Vector2i(-1,-1)) -> ArrayMesh:
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
     vertex395(st,q+n*bevel,n,Vector2((us[ij.x]/uh+1.)*.5,(1.-vs[ij.y]/vh)*.5),sample_tile)
 return st.commit()
func lathe395(profile: Array[Vector2],tile: Vector2i,caps: bool=true) -> ArrayMesh:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var bottom: float=profile[0].y;var top: float=profile[-1].y
 for j in range(profile.size()-1):
  var a: Vector2=profile[j];var b: Vector2=profile[j+1]
  var slope: Vector2=(b-a).normalized()
  for i in 24:
   for ij in [Vector2i(i,j),Vector2i(i+1,j),Vector2i(i+1,j+1),Vector2i(i,j),Vector2i(i+1,j+1),Vector2i(i,j+1)]:
    var angle: float=TAU*float(ij.x)/24.;var p: Vector2=profile[ij.y]
    var n:=Vector3(cos(angle)*slope.y,-slope.x,sin(angle)*slope.y).normalized()
    vertex395(st,Vector3(cos(angle)*p.x,p.y,sin(angle)*p.x),n,Vector2(float(ij.x)/24.,1.-(p.y-bottom)/maxf(top-bottom,.001)),tile)
 if caps:
  for end in [0,profile.size()-1]:
   var p: Vector2=profile[end];var normal:=Vector3.DOWN if end==0 else Vector3.UP
   for i in 24:
    var angles: Array[float]=[TAU*float(i)/24.,TAU*float(i+1)/24.]
    if end!=0:angles.reverse()
    vertex395(st,Vector3(cos(angles[0])*p.x,p.y,sin(angles[0])*p.x),normal,Vector2(.5,.5),tile)
    vertex395(st,Vector3(0,p.y,0),normal,Vector2(.5,.5),tile)
    vertex395(st,Vector3(cos(angles[1])*p.x,p.y,sin(angles[1])*p.x),normal,Vector2(.5,.5),tile)
 return st.commit()
func apron395() -> ArrayMesh:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 24:
  var x0: float=-.51+1.02*float(i)/24.;var x1: float=-.51+1.02*float(i+1)/24.
  var y0: float=.88+.075*cos(x0/.51*PI*.5);var y1: float=.88+.075*cos(x1/.51*PI*.5)
  for face in [0,1]:
   var z: float=.55 if face==0 else .47
   var pts: Array[Vector3]=[Vector3(x0,y0,z),Vector3(x1,y1,z),Vector3(x1,1.08,z),Vector3(x0,1.08,z)]
   for k in ([0,2,1,0,3,2] if face==0 else [0,1,2,0,2,3]):
    var p: Vector3=pts[k]
    vertex395(st,p,Vector3.BACK if face==0 else Vector3.FORWARD,Vector2((p.x+.51)/1.02,.24+(1.08-p.y)/.20*.50),Vector2i(1,1) if face==0 else Vector2i.ZERO)
  for p in [Vector3(x0,y0,.47),Vector3(x1,y1,.55),Vector3(x0,y0,.55),Vector3(x0,y0,.47),Vector3(x1,y1,.47),Vector3(x1,y1,.55)]:vertex395(st,p,Vector3.DOWN,Vector2(.5,.5),Vector2i.ZERO)
 return st.commit()
func build395() -> void:
 piece395(rounded_box395(Vector3(2.60,.15,1.20),.035),Vector3(0,1.115,0),wood395,"BevelledTop")
 var profile: Array[Vector2]=[Vector2(.055,.008),Vector2(.070,.04),Vector2(.072,.09),Vector2(.055,.18),Vector2(.042,.40),Vector2(.052,.46),Vector2(.075,.50),Vector2(.082,.56),Vector2(.060,.64),Vector2(.047,.70),Vector2(.072,.76),Vector2(.084,.81),Vector2(.072,.86),Vector2(.075,1.045)]
 for x in [-1.11,1.11]:
  for z in [-.42,.42]:legs395.append(piece395(lathe395(profile,Vector2i(0,1)),Vector3(x,0,z),wood395,"TurnedLeg"))
 for x in [-.85,.85]:
  piece395(rounded_box395(Vector3(.65,.27,1.02),.018),Vector3(x,.92,-.025),wood395,"DrawerBox")
  piece395(rounded_box395(Vector3(.66,.27,.065),.015,Vector2i.ZERO,Vector2i(1,0)),Vector3(x,.92,.52),wood395,"PaintedDrawerFace")
  var knob:=SphereMesh.new();knob.radius=.5;knob.height=1.
  var n:=piece395(knob,Vector3(x,.925,.575),brass395,"BrassShellPull");n.scale=Vector3(.19,.085,.065)
 piece395(apron395(),Vector3.ZERO,wood395,"CurvedFeatherApron")
 piece395(rounded_box395(Vector3(2.2,.16,.08),.015),Vector3(0,.95,-.48),wood395,"RearApron")
 build_books395();build_lamp395();build_ink395()
func build_books395() -> void:
 for i in 3:
  var center:=Vector3(-.88,1.22+float(i)*.075,-.16)
  piece395(rounded_box395(Vector3(.39,.014,.30),.004,Vector2i(0,1)),center,detail395,"ClosedBookCover")
  piece395(rounded_box395(Vector3(.36,.048,.275),.006),center+Vector3.UP*.027,paper395,"ClosedBookPages")
  piece395(rounded_box395(Vector3(.39,.014,.30),.004,Vector2i(0,1)),center+Vector3.UP*.057,detail395,"ClosedBookCover")
 var cover:=piece395(rounded_box395(Vector3(.69,.015,.44),.005,Vector2i(0,1)),Vector3(0,1.205,.13),detail395,"OpenBookCover")
 cover.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for side in [-1.,1.]:
  for i in 12:
   var triangles: Array[Vector2i]=[Vector2i(i,0),Vector2i(i+1,0),Vector2i(i+1,1),Vector2i(i,0),Vector2i(i+1,1),Vector2i(i,1)]
   if side<0.:triangles.reverse()
   for ij in triangles:
    var t: float=float(ij.x)/12.;var x: float=side*.325*t
    var y: float=1.245+.026*sin(t*PI)
    # Both sides map a flat page texture onto a shallow, truly curved open book.
    st.set_normal(Vector3(-side*.026*PI/.325*cos(t*PI),1,0).normalized());st.set_uv(uv395(Vector2(t,float(ij.y)),Vector2i(1,0)));st.add_vertex(Vector3(x,y,.13+(float(ij.y)-.5)*.40))
 var page_mat:=detail395.duplicate() as StandardMaterial3D
 page_mat.albedo_color=Color(.50,.52,.54)
 var pages:=piece395(st.commit(),Vector3.ZERO,page_mat,"CurvedOpenPages")
 # Thin open book receives real light/shadows, but does not cast subpixel shadows.
 # Keep the nearby cover from biasing into paper and making a speckled surface.
 pages.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
func build_lamp395() -> void:
 var at:=Vector3(.88,1.19,-.20)
 piece395(lathe395([Vector2(.13,.01),Vector2(.16,.025),Vector2(.16,.04),Vector2(.12,.06)],Vector2i.ZERO),at,brass395,"LampBase")
 piece395(lathe395([Vector2(.025,.05),Vector2(.025,.40),Vector2(.045,.43)],Vector2i.ZERO),at,brass395,"LampStem")
 var fabric:=detail395.duplicate() as StandardMaterial3D;fabric.cull_mode=BaseMaterial3D.CULL_DISABLED
 piece395(lathe395([Vector2(.23,.43),Vector2(.225,.45),Vector2(.13,.70),Vector2(.13,.71)],Vector2i.ZERO,false),at,fabric,"WovenLampShade")
 for row in [Vector2(.233,.434),Vector2(.133,.703)]:
  piece395(lathe395([Vector2(row.x,row.y),Vector2(row.x,row.y+.015)],Vector2i.ZERO,false),at,brass395,"ShadeRim")
func build_ink395() -> void:
 var ink:=plain395("3d343b")
 piece395(rounded_box395(Vector3(.16,.17,.14),.025),Vector3(-.42,1.275,-.10),ink,"InkBottle")
 piece395(lathe395([Vector2(.045,0),Vector2(.045,.05)],Vector2i.ZERO),Vector3(-.42,1.36,-.10),brass395,"InkBottleRim")
 # A small folded leaf mesh is the quill; no billboard or camera-dependent depth.
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 16:
  var a: float=float(i)/16.;var b: float=float(i+1)/16.
  for side in [-1.,1.]:
   var p:=Vector3(-.42+.13*a,1.39+.39*a,-.10)
   var q:=Vector3(-.42+.13*b,1.39+.39*b,-.10)
   var edge_p:=p+Vector3(side*.065*sin(a*PI),0,.012)
   var edge_q:=q+Vector3(side*.065*sin(b*PI),0,.012)
   for v in [p,edge_p,edge_q,p,edge_q,q]:vertex395(st,v,Vector3.BACK,Vector2(.5,.5),Vector2i.ZERO)
 var quill:=paper395.duplicate() as StandardMaterial3D;quill.cull_mode=BaseMaterial3D.CULL_DISABLED
 piece395(st.commit(),Vector3.ZERO,quill,"FoldedQuill")
