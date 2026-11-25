extends RefCounted
const BASE=preload("res://scripts/room/bed_mesh364.gd")
var path365: Array[Vector2]=[]
func _init() -> void:
 var raw: Array[Vector2]=[]
 for side in 4:
  for i in 128:
   var t:=float(i)/128.;var uv:=Vector2(1.,1.-t)
   match side:
    1:uv=Vector2(1.-t,0.)
    2:uv=Vector2(0.,t)
    3:uv=Vector2(t,1.)
   var point:=BASE.pillow_point364(uv,false)
   raw.append(Vector2(point.x*2.36/.96,-point.y*2.78/.65))
 var distances: Array[float]=[0.]
 for i in raw.size():distances.append(distances[-1]+raw[i].distance_to(raw[(i+1)%raw.size()]))
 var cursor:=0
 for i in 512:
  var target: float=distances[-1]*float(i)/512.
  while cursor<raw.size()-1 and distances[cursor+1]<target:cursor+=1
  var f:=inverse_lerp(distances[cursor],distances[cursor+1],target)
  path365.append(raw[cursor].lerp(raw[(cursor+1)%raw.size()],f))
func outline365(u: float) -> Vector2:
 var f:=fposmod(u,1.)*path365.size();var i:=int(f)
 return path365[i].lerp(path365[(i+1)%path365.size()],f-float(i))
func point365(u: float,v: float) -> Vector3:
 var p:=outline365(u)
 var tangent: Vector2=(outline365(u+.001)-outline365(u-.001)).normalized()
 var out:=Vector2(tangent.y,-tangent.x)
 var phase:=u*TAU*32.+.15*sin(u*TAU*2.)*v
 var pleat: float=(.006+.028*v)*cos(phase)
 p+=out*(.005+.060*v+pleat)
 var hem:=v*v*(.015*sin(phase)+.004*sin(u*TAU*3.))
 return Vector3(p.x,.65-.53*v+hem,p.y)
func vertex365(st: SurfaceTool,u: float,v: float,inner: bool) -> void:
 var du:=point365(u+.0004,v)-point365(u-.0004,v)
 var dv:=point365(u,v+.0004)-point365(u,v-.0004)
 var normal:=du.cross(dv).normalized()
 var shade:=.91+.09*cos(u*TAU*32.+.15*sin(u*TAU*2.)*v)
 st.set_color(Color(shade,shade,shade));st.set_normal(-normal if inner else normal);st.set_uv(Vector2(u*6.,v))
 st.add_vertex(point365(u,v)-normal*(.012 if inner else 0.))
func mesh365() -> ArrayMesh:
 var baked: ArrayMesh=preload("res://scripts/room/mesh_cache403.gd").get403("skirt")
 return baked if baked!=null else build_mesh365()
func build_mesh365() -> ArrayMesh:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for inner in [false,true]:
  for y in 24:
   for x in 512:
    for d in [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
     vertex365(st,float(x+d.x)/512.,float(y+d.y)/24.,inner)
 # Closed narrow top and bottom ribbons supply actual cloth thickness.
 for edge in [0.,1.]:
  for x in 512:
   for k in [0,1,2,2,1,3]:
    var u:=float(x+(0 if k<2 else 1))/512.
    vertex365(st,u,edge,k%2==1)
 return st.commit()
static func foot365() -> ArrayMesh:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var profile: Array[Vector2]=[Vector2(.066,0.),Vector2(.087,.025),Vector2(.086,.07),Vector2(.062,.13),Vector2(.062,.34)]
 for i in profile.size()-1:
  for j in 24:
   for d in [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
    var q: Vector2=profile[i+d.x];var a:=float(j+d.y)/24.*TAU
    st.set_normal(Vector3(cos(a),0.,sin(a)));st.set_uv(Vector2(.2+float(j+d.y)/24.*.12,.65+q.y/.34*.24));st.add_vertex(Vector3(q.x*cos(a),q.y,q.x*sin(a)))
 for upper in [false,true]:
  var q: Vector2=profile[-1] if upper else profile[0]
  for j in 24:
   for k in [0,1,2]:
    var a:=float(j+(1 if k==2 else 0))/24.*TAU
    st.set_normal(Vector3.UP if upper else Vector3.DOWN);st.set_uv(Vector2(.26,.77));st.add_vertex(Vector3.ZERO+Vector3(0.,q.y,0.) if k==0 else Vector3(q.x*cos(a),q.y,q.x*sin(a)))
 return st.commit()
