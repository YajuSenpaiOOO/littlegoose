extends RefCounted
# Closed layered cloth; fitted sheet is sampled as a clearance envelope, not a collision mesh.
static func sheet_height366(x: float,z: float) -> float:
 var a:=clampf(x/1.195,-1.,1.);var b:=clampf(z/1.405,-1.,1.)
 return .64+(.035+.14*pow(maxf(0.,(1.-a*a)*(1.-b*b)),.60))*.316/.28
static func sheet_distance366(x: float,z: float) -> float:
 var q:=Vector2(x/(2.39/.96),z/(2.81/.65))
 var c:=q.clamp(Vector2(-.39,-.235),Vector2(.39,.235))
 return q.distance_to(c)-.09
static func duvet366(u: float,v: float,upper: bool) -> Vector3:
 var x:=u*1.08;var z:=lerpf(-.65,1.15,v)
 var dx:=0.;var dz:=0.
 if absf(u)>1.:
  var a: float=(absf(u)-1.)/.25*PI*.5
  x=signf(u)*(1.08+.22*sin(a));dx=.42*(1.-cos(a))
 if v>1.:
  var a: float=(v-1.)/.25*PI*.5
  z=1.15+.35*sin(a);dz=.40*(1.-cos(a))
 # Smooth corner fall, without adding both edge drops into a deep self-intersecting pocket.
 var fall:=pow(pow(dx,4.)+pow(dz,4.),.25)
 var base:=sheet_height366(clampf(x,-1.08,1.08),clampf(z,-.65,1.15))+.018-fall
 var fold:=.005*sin(u*7.+v*5.)+.004*cos(v*8.-u*3.)
 var y:=base+fold
 var distance:=sheet_distance366(x,z)
 var weight:=1.-smoothstep(0.,.012,distance)
 y+=maxf(0.,sheet_height366(x,z)+.012-y)*weight
 if upper:
  var crown:=.030*maxf(0.,1.-pow(minf(absf(u),1.),2.))
  var turn:=.012*exp(-pow(v/.07,2.))
  y+=.075+crown+turn
 return Vector3(x,y,z)
static func duvet_normal366(u: float,v: float) -> Vector3:
 var du:=duvet366(u+.0005,v,true)-duvet366(u-.0005,v,true)
 var dv:=duvet366(u,v+.0005,true)-duvet366(u,v-.0005,true)
 return dv.cross(du).normalized()
static func point366(uv: Vector2,layer: int,upper: bool) -> Vector3:
 if layer==0:return duvet366(lerpf(-1.25,1.25,uv.x),uv.y*1.25,upper)
 # Same underlying duvet coordinates, not a second independently guessed depth slope.
 var u:=lerpf(-1.22,1.22,uv.x);var v:=lerpf(.43,1.12,uv.y)
 var normal:=duvet_normal366(u,v)
 var loft:=.005
 if upper:
  var cells:=sin(fposmod(uv.x*5.,1.)*PI)*sin(fposmod(uv.y*3.,1.)*PI)
  loft=.032+.007*cells
 return duvet366(u,v,true)+normal*loft
static func normal366(uv: Vector2,layer: int,upper: bool) -> Vector3:
 var du:=point366(uv+Vector2(.0004,0.),layer,upper)-point366(uv-Vector2(.0004,0.),layer,upper)
 var dv:=point366(uv+Vector2(0.,.0004),layer,upper)-point366(uv-Vector2(0.,.0004),layer,upper)
 return dv.cross(du).normalized()*(1. if upper else -1.)
static func mesh366(layer: int) -> ArrayMesh:
 var baked: ArrayMesh=preload("res://scripts/room/mesh_cache403.gd").get403("quilt-"+str(layer))
 return baked if baked!=null else build_mesh366(layer)
static func build_mesh366(layer: int) -> ArrayMesh:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var ny:=64 if layer==0 else 48
 for upper in [false,true]:
  for y in ny:
   for x in 80:
    for d in [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
     var uv:=Vector2(float(x+d.x)/80.,float(y+d.y)/float(ny))
     var shade:=1. if upper else .93
     st.set_color(Color(shade,shade,shade));st.set_normal(normal366(uv,layer,upper));st.set_uv(uv);st.add_vertex(point366(uv,layer,upper))
 # Rounded hem bridges the upper and lower sheets; all layers are real closed thickness.
 for edge in 4:
  for i in 80:
   for j in 8:
    for d in [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
     var t:=float(i+d.x)/80.;var uv:=Vector2(t,0.)
     match edge:
      1:uv=Vector2(1.,t)
      2:uv=Vector2(1.-t,1.)
      3:uv=Vector2(0.,1.-t)
     var top:=point366(uv,layer,true);var bottom:=point366(uv,layer,false);var center: Vector3=(top+bottom)*.5
     var normal:=normal366(uv,layer,true)
     var du:=point366(uv+Vector2(.0005,0.),layer,true)-point366(uv-Vector2(.0005,0.),layer,true)
     var dv:=point366(uv+Vector2(0.,.0005),layer,true)-point366(uv-Vector2(0.,.0005),layer,true)
     var ou:=(-1. if uv.x<.0001 else 0.)+(1. if uv.x>.9999 else 0.)
     var ov:=(-1. if uv.y<.0001 else 0.)+(1. if uv.y>.9999 else 0.)
     var out:=du*ou+dv*ov;out=(out-normal*out.dot(normal)).normalized()
     var angle:=float(j+d.y)/8.*PI
     var bulge: float=.018 if layer==0 else .008
     st.set_color(Color(.98,.98,.98));st.set_normal((normal*cos(angle)+out*sin(angle)).normalized());st.set_uv(uv)
     st.add_vertex(center+(top-bottom)*.5*cos(angle)+out*bulge*sin(angle))
 return st.commit()
