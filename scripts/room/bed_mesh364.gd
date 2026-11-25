extends RefCounted
static func top364(x: float) -> float:
 return 1.46+.56*pow(maxf(0.,cos(x*PI*.5)),1.35)
static func board_uv364(p: Vector3) -> Vector2:
 return Vector2((p.x+1.3)/2.6,(2.2116667-p.y)/1.7333333)
static func board364() -> ArrayMesh:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for back in [false,true]:
  for i in 80:
   for d in [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
    var x:=float(i+d.x)/80.*2.-1.;var y:=lerpf(.68,top364(x),float(d.y))
    var v:=Vector3(x*1.13,y,-.095 if back else .015)
    st.set_normal(Vector3.FORWARD if back else Vector3.BACK);st.set_uv(Vector2(.20+(v.x+1.13)/2.26*.12,.65+(v.y-.68)/1.34*.24) if back else board_uv364(v));st.add_vertex(v)
 # Extruded perimeter, including both side walls and lower edge.
 var path:=outline364()
 for i in path.size():
  var a: Vector2=path[i];var b: Vector2=path[(i+1)%path.size()]
  var n:=Vector3(-(b.y-a.y),b.x-a.x,0.).normalized()
  for k in [0,1,2,2,1,3]:
   var q: Vector2=a if k<2 else b
   var v:=Vector3(q.x,q.y,-.095 if k%2 else .015)
   st.set_normal(n);st.set_uv(board_uv364(v));st.add_vertex(v)
 return st.commit()
static func outline364() -> Array[Vector2]:
 var path: Array[Vector2]=[]
 for i in 81:
  var t:=float(i)/80.*2.-1.;path.append(Vector2(t*1.13,top364(t)))
 for i in range(1,17):path.append(Vector2(1.13,lerpf(1.46,.68,float(i)/16.)))
 for i in range(1,65):path.append(Vector2(lerpf(1.13,-1.13,float(i)/64.),.68))
 for i in range(1,16):path.append(Vector2(-1.13,lerpf(.68,1.46,float(i)/16.)))
 return path
static func trim364(path: Array[Vector2],radius: float=.06) -> ArrayMesh:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in path.size():
  for j in 12:
   for d in [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
    var k: int=(i+d.x)%path.size();var q: Vector2=path[k]
    var tangent: Vector2=(path[(k+1)%path.size()]-path[(k+path.size()-1)%path.size()]).normalized()
    var outer:=Vector3(-tangent.y,tangent.x,0.)
    var angle:=float(j+d.y)/12.*TAU
    var n:=outer*cos(angle)+Vector3.BACK*sin(angle)
    var v:=Vector3(q.x,q.y,.015)+n*radius
    st.set_normal(n);st.set_uv(board_uv364(v));st.add_vertex(v)
 return st.commit()
static func post364() -> ArrayMesh:
 var profile: Array[Vector2]=[Vector2(.09,0.),Vector2(.105,.05),Vector2(.105,.12),Vector2(.076,.20),Vector2(.067,1.26),Vector2(.095,1.32),Vector2(.102,1.39),Vector2(.078,1.46)]
 # Integrated spherical finial avoids a faceted sphere glued onto a straight cylinder.
 for i in 17:
  var a:=lerpf(-PI/3.,PI*.5,float(i)/16.);profile.append(Vector2(maxf(.001,.14*cos(a)),1.60+.14*sin(a)))
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in profile.size()-1:
  for j in 40:
   for d in [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
    var k: int=i+d.x;var q: Vector2=profile[k];var angle:=float(j+d.y)/40.*TAU
    var tangent: Vector2=(profile[mini(k+1,profile.size()-1)]-profile[maxi(k-1,0)]).normalized()
    st.set_normal(Vector3(cos(angle)*tangent.y,-tangent.x,sin(angle)*tangent.y));st.set_uv(Vector2(.20+float(j+d.y)/40.*.12,.65+q.y/1.74*.24));st.add_vertex(Vector3(cos(angle)*q.x,q.y,sin(angle)*q.x))
 return st.commit()
static func pillow_point364(uv: Vector2,back: bool) -> Vector3:
 var a:=uv*2.-Vector2.ONE
 var q:=Vector2(a.x*.48,a.y*.325);var core:=q.clamp(Vector2(-.39,-.235),Vector2(.39,.235));var edge:=q-core
 if edge.length()>.09:q=core+edge.normalized()*.09
 var dome:=pow(maxf(0.,(1.-a.x*a.x)*(1.-a.y*a.y)),.60)
 return Vector3(q.x,q.y,(-.035-.07*dome) if back else (.035+.14*dome))
static func pillow364() -> ArrayMesh:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for back in [false,true]:
  for y in 32:
   for x in 48:
    for d in [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
     var uv:=Vector2(float(x+d.x)/48.,float(y+d.y)/32.)
     var du:=pillow_point364(uv+Vector2(.0005,0.),back)-pillow_point364(uv-Vector2(.0005,0.),back)
     var dv:=pillow_point364(uv+Vector2(0.,.0005),back)-pillow_point364(uv-Vector2(0.,.0005),back)
     st.set_normal(du.cross(dv).normalized()*(-1. if back else 1.));st.set_uv(Vector2(uv.x,1.-uv.y));st.add_vertex(pillow_point364(uv,back))
 # Join both bulged faces at the sewn edge.
 for side in 4:
  for i in 48:
   var a:=Vector2(float(i)/48.,0.);var b:=Vector2(float(i+1)/48.,0.)
   match side:
    1:a.y=1.;b.y=1.
    2:a=Vector2(0.,a.x);b=Vector2(0.,b.x)
    3:a=Vector2(1.,a.x);b=Vector2(1.,b.x)
   for k in [0,1,2,2,1,3]:
    var uv: Vector2=a if k<2 else b
    var v:=pillow_point364(uv,k%2==1)
    st.set_normal(Vector3(uv.x*2.-1.,uv.y*2.-1.,0.).normalized());st.set_uv(Vector2(uv.x,1.-uv.y));st.add_vertex(v)
 return st.commit()
static func flange364() -> ArrayMesh:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 160:
  for d in [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
   var a:=float(i+d.x)/160.*TAU;var c:=cos(a);var s:=sin(a)
   var x:=signf(c)*sqrt(absf(c))*.47;var y:=signf(s)*sqrt(absf(s))*.315
   var rim: float=float(d.y)*(.055+.012*cos(a*22.))
   var n:=Vector2(x/.47,y/.315).normalized()
   var v:=Vector3(x+n.x*rim,y+n.y*rim,-.006+.008*cos(a*22.))
   st.set_normal(Vector3.BACK);st.set_uv(Vector2(.02,.02));st.add_vertex(v)
 return st.commit()
