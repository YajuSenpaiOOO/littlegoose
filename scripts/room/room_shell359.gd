extends "res://scripts/room/room_shell358.gd"
# Rounded sewn cushions and a continuous draped cover; no cloth simulation.
var soft359: Node3D
var old_soft359: Array[Node3D]=[]
var soft_cover359: Node3D
var soft_mode359:=true
func part358(parent: Node3D,at: Vector3,size: Vector3,tile: Vector2i) -> void:
 super.part358(parent,at,size,tile)
 if tile!=Vector2i(0,1):old_soft359.append(parent.get_child(parent.get_child_count()-1))
func build_furniture() -> void:
 super.build_furniture()
 soft359=Node3D.new();soft359.name="RoundedBedding359";bed358.add_child(soft359)
 cushion359(soft359,Vector3(0.,.65,.02),Vector3(2.38,.30,2.8),.13,Vector2i(1,1))
 for x in [-.59,.59]:
  var pillow:=Node3D.new();pillow.position=Vector3(x,.87,-.93);pillow.rotation.y=-.045 if x<0. else .065;soft359.add_child(pillow)
  cushion359(pillow,Vector3.ZERO,Vector3(1.01,.25,.65),.12,Vector2i(1,0))
 soft_cover359=Node3D.new();soft_cover359.name="ContinuousDrapedQuilt";blanket358.add_child(soft_cover359)
 cover359()
 apply359()
func fabric359(tile: Vector2i) -> StandardMaterial3D:
 var m:=StandardMaterial3D.new();m.albedo_texture=source358();m.uv1_scale=Vector3(.496,.496,1.);m.uv1_offset=Vector3(tile.x*.5+.002,tile.y*.5+.002,0.)
 m.albedo_color=Color(.88,.88,.88);m.roughness=1.;m.metallic_specular=0.;m.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
 return m
func cushion359(parent: Node3D,at: Vector3,size: Vector3,radius: float,tile: Vector2i) -> void:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var half:=size*.5;var inner:=half-Vector3.ONE*radius
 for face in [[Vector3.RIGHT,Vector3.BACK,Vector3.UP],[Vector3.LEFT,Vector3.FORWARD,Vector3.UP],[Vector3.UP,Vector3.RIGHT,Vector3.FORWARD],[Vector3.DOWN,Vector3.RIGHT,Vector3.BACK],[Vector3.BACK,Vector3.RIGHT,Vector3.UP],[Vector3.FORWARD,Vector3.LEFT,Vector3.UP]]:
  for y in 12:
   for x in 20:
    for d in [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
     var uv:=Vector2(float(x+d.x)/20.,float(y+d.y)/12.)
     var q: Vector3=(face[0]+face[1]*(uv.x*2.-1.)+face[2]*(1.-uv.y*2.))*half
     var c:=q.clamp(-inner,inner);var n: Vector3=(q-c).normalized()
     st.set_normal(n);st.set_uv(uv);st.add_vertex(c+n*radius)
 shape(parent,st.commit(),at,fabric359(tile))
func cover_point359(u: float,v: float) -> Vector3:
 # Central inflated panel rolls continuously over both sides and the foot.
 var x:=u*1.16;var z: float=lerpf(-.58,1.27,v)
 var drop:=0.
 if absf(u)>1.:
  var a: float=(absf(u)-1.)*PI*.5/.27
  x=signf(u)*(1.16+.16*sin(a));drop+=.40*(1.-cos(a))
 if v>1.:
  var a: float=(v-1.)*PI*.5/.22
  z=1.27+.15*sin(a);drop+=.36*(1.-cos(a))
 var crown:=.10*maxf(0.,1.-pow(minf(absf(u),1.),2.))
 var folds:=.018*sin(u*12.+v*7.)+.012*cos(v*17.-u*3.)
 var turn:=.045*exp(-pow((v-.03)/.075,2.))
 return Vector3(x,.91+crown+folds+turn-drop,z)
func cover_vertex359(st: SurfaceTool,uv: Vector2,lower: bool=false) -> void:
 var u: float=lerpf(-1.27,1.27,uv.x);var v:=uv.y*1.22
 var du:=cover_point359(u+.001,v)-cover_point359(u-.001,v)
 var dv:=cover_point359(u,v+.001)-cover_point359(u,v-.001)
 var n:=dv.cross(du).normalized()
 st.set_normal(-n if lower else n);st.set_uv(uv)
 st.add_vertex(cover_point359(u,v)-Vector3.UP*(.05 if lower else 0.))
func cover359() -> void:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for lower in [false,true]:
  for y in 48:
   for x in 64:
    var indices: Array=[Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]
    if lower:indices.reverse()
    for d in indices:cover_vertex359(st,Vector2(float(x+d.x)/64.,float(y+d.y)/48.),lower)
 # Sewn thickness closes the entire perimeter, including the visible hanging hem.
 for side in 4:
  for i in 64:
   var t:=float(i)/64.;var t2:=float(i+1)/64.
   var a:=Vector2(t,0.);var b:=Vector2(t2,0.)
   match side:
    1:a=Vector2(t,1.);b=Vector2(t2,1.)
    2:a=Vector2(0.,t);b=Vector2(0.,t2)
    3:a=Vector2(1.,t);b=Vector2(1.,t2)
   var pa:=cover_point359(lerpf(-1.27,1.27,a.x),a.y*1.22)
   var pb:=cover_point359(lerpf(-1.27,1.27,b.x),b.y*1.22)
   var n: Vector3=(pb-pa).cross(Vector3.DOWN).normalized()
   for k in [0,1,2,2,1,3]:
    st.set_normal(n);st.set_uv(a if k<2 else b)
    st.add_vertex((pa if k<2 else pb)-Vector3.UP*(.05 if k%2==1 else 0.))
 var mat:=fabric359(Vector2i(0,0));mat.cull_mode=BaseMaterial3D.CULL_DISABLED
 shape(soft_cover359,st.commit(),Vector3.ZERO,mat)
func apply359() -> void:
 for n in old_soft359:n.visible=not soft_mode359
 soft359.visible=soft_mode359;soft_cover359.visible=soft_mode359
func toggle_soft359() -> void:
 soft_mode359=not soft_mode359;apply359()
