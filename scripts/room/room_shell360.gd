extends "res://scripts/room/room_shell359.gd"
# 360: reference-led solid bed; no image-card silhouette used as a volume.
var bed360: Node3D
var cover360: Node3D
var use360:=true
var atlas360: Texture2D
var surfaces360: Array[MeshInstance3D]=[]
func build_furniture() -> void:
 super.build_furniture()
 var row:=item356("bed")
 bed360=Node3D.new();bed360.name="FeatherCottageBed360";row.root.add_child(bed360)
 # Rounded rails and posts remain separate from the soft drape.
 cushion359(bed360,Vector3(0.,.32,0.),Vector3(2.48,.24,2.88),.10,Vector2i(0,0))
 for z in [-1.40,1.40]:
  panel360(z,z<0.)
  for x in [-1.18,1.18]:
   var top:=1.68 if z<0. else .63
   wood_cylinder360(Vector3(x,top*.5,z),.10,top)
   var ball:=SphereMesh.new();ball.radius=.145;ball.height=.29
   shape(bed360,ball,Vector3(x,top+.11,z),fabric359(Vector2i(0,0)))
 cushion359(bed360,Vector3(0.,.65,0.),Vector3(2.30,.32,2.72),.145,Vector2i(0,1))
 for x in [-.56,.56]:
  var pillow:=Node3D.new();pillow.name="LeaningPillow";pillow.position=Vector3(x,1.04,-.97);pillow.rotation=Vector3(deg_to_rad(-66.),0.,-.035 if x<0. else .03);bed360.add_child(pillow)
  # Low scalloped flange around an inset plump sewn cushion.
  cushion359(pillow,Vector3.ZERO,Vector3(1.04,.16,.81),.075,Vector2i(1,0))
  pillow360(pillow)
  for side in [-1.,1.]:
   for i in 7:
    var lobe:=SphereMesh.new();lobe.radius=.075;lobe.height=.15
    var n:=shape(pillow,lobe,Vector3(side*.48,0.,-.32+i*.106),fabric359(Vector2i(1,0)));n.scale=Vector3(1.,.45,1.)
 cover360=Node3D.new();cover360.name="CreamQuiltAndSageThrow";bed360.add_child(cover360)
 drape360(cover360,0,Vector2i(0,1))
 drape360(cover360,1,Vector2i(1,1))
 skirt360()
 # Keep mechanics stable in both comparison modes, with a small visual clearance margin.
 for child in row.root.get_children():
  if child is StaticBody3D:
   if child.position.y<.5:child.get_child(0).shape.size=Vector3(2.78,.80,3.14)
   else:child.position.y=1.15;child.get_child(0).shape.size=Vector3(2.55,1.35,.24)
 row.size=Vector2(2.78,3.14)
 row.title="羽毛双人床（360）"
 apply360()
func fabric359(tile: Vector2i) -> StandardMaterial3D:
 if not is_instance_valid(bed360):return super.fabric359(tile)
 if atlas360==null:atlas360=source356("res://assets/room360/bed_atlas.png")
 var m:=StandardMaterial3D.new();m.albedo_texture=atlas360;m.uv1_scale=Vector3(.49,.49,1.);m.uv1_offset=Vector3(tile.x*.5+.005,tile.y*.5+.005,0.)
 m.albedo_color=Color(.69,.66,.59) if tile==Vector2i(0,0) else Color(.88,.88,.88);m.roughness=1.;m.metallic_specular=0.;m.cull_mode=BaseMaterial3D.CULL_DISABLED;m.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
 return m
func pillow_point360(uv: Vector2,lower: bool) -> Vector3:
 var a:=uv*2.-Vector2.ONE
 var q:=Vector2(a.x*.46,a.y*.34);var c:=q.clamp(Vector2(-.38,-.26),Vector2(.38,.26))
 var edge:=q-c
 if edge.length()>.08:q=c+edge.normalized()*.08
 var dome:=pow(maxf(0.,(1.-a.x*a.x)*(1.-a.y*a.y)),.65)
 return Vector3(q.x,(-.045-.055*dome) if lower else (.075+.16*dome),q.y)
func pillow360(parent: Node3D) -> void:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for lower in [false,true]:
  for y in 24:
   for x in 32:
    for d in [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
     var uv:=Vector2(float(x+d.x)/32.,float(y+d.y)/24.)
     var du:=pillow_point360(uv+Vector2(.001,0.),lower)-pillow_point360(uv-Vector2(.001,0.),lower)
     var dv:=pillow_point360(uv+Vector2(0.,.001),lower)-pillow_point360(uv-Vector2(0.,.001),lower)
     st.set_normal((dv.cross(du).normalized())*(-1. if lower else 1.));st.set_uv(uv);st.add_vertex(pillow_point360(uv,lower))
 # Flange encloses the seam between both faces.
 shape(parent,st.commit(),Vector3.ZERO,fabric359(Vector2i(1,0)))
func wood_cylinder360(at: Vector3,radius: float,height: float) -> void:
 var mesh:=CylinderMesh.new();mesh.top_radius=radius;mesh.bottom_radius=radius;mesh.height=height;mesh.radial_segments=20
 shape(bed360,mesh,at,fabric359(Vector2i(0,0)))
func arch_height360(x: float,head: bool) -> float:
 return (1.47+.53*pow(maxf(0.,1.-x*x),1.6)) if head else (.53+.15*maxf(0.,1.-x*x))
func panel360(z: float,head: bool) -> void:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var bottom:=.45 if head else .20
 for back in [false,true]:
  for i in 48:
   for d in [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
    var u:=float(i+d.x)/48.;var x:=u*2.-1.;var y:=lerpf(bottom,arch_height360(x,head),float(d.y))
    st.set_normal(Vector3.FORWARD if back else Vector3.BACK);st.set_uv(Vector2(u,1.-(y-bottom)/(1.60 if head else .55)));st.add_vertex(Vector3(x*1.17,y,z+(-.09 if back else .09)))
 # Seal the curved top and form a thick rounded trim along it.
 for i in 48:
  var x:=float(i)/48.*2.-1.;var x2:=float(i+1)/48.*2.-1.
  var a:=Vector3(x*1.17,arch_height360(x,head),z);var b:=Vector3(x2*1.17,arch_height360(x2,head),z)
  for k in [0,1,2,2,1,3]:
   st.set_normal(Vector3.UP);st.set_uv(Vector2(float(i)/48.,.1));st.add_vertex((a if k<2 else b)+Vector3(0.,0.,-.09 if k%2==0 else .09))
  var trim:=CylinderMesh.new();trim.top_radius=.065;trim.bottom_radius=.065;trim.height=a.distance_to(b)+.015;trim.radial_segments=10
  var n:=shape(bed360,trim,(a+b)*.5,fabric359(Vector2i(0,0)));n.quaternion=Quaternion(Vector3.UP,(b-a).normalized())
 shape(bed360,st.commit(),Vector3.ZERO,fabric359(Vector2i(0,0)))
func drape_point360(u: float,v: float,layer: int) -> Vector3:
 # One rectangular sheet with smooth rolled edges; max(drop) prevents doubled corner sinking.
 var start: float=-.71 if layer==0 else .17
 var finish:=1.27
 var x:=u*1.12;var z:=lerpf(start,finish,v)
 var sx:=maxf(0.,absf(u)-1.)/.26
 var sz:=maxf(0.,v-1.)/.24
 var dx:=.0;var dz:=.0
 if sx>0.:
  x=signf(u)*(1.12+.19*sin(sx*PI*.5));dx=.43*(1.-cos(sx*PI*.5))
 if sz>0.:
  z=finish+.19*sin(sz*PI*.5);dz=.43*(1.-cos(sz*PI*.5))
 var crown:=.075*maxf(0.,1.-minf(absf(u),1.)**2)
 var fold:=.008*sin(u*13.+v*5.)+.006*cos(v*13.-u*4.)
 # Throw follows the underlying cream quilt at the SAME world z, with a positive gap.
 var cv:=clampf((z+.71)/1.98,0.,1.24)
 if layer==1:fold=.008*sin(u*13.+cv*5.)+.006*cos(cv*13.-u*4.)
 return Vector3(x,.94+crown+fold-maxf(dx,dz)+(.075 if layer==1 else 0.),z)
func drape_vertex360(st: SurfaceTool,uv: Vector2,layer: int,lower: bool) -> void:
 var u:=lerpf(-1.26,1.26,uv.x);var v:=uv.y*1.24
 var du:=drape_point360(u+.0005,v,layer)-drape_point360(u-.0005,v,layer)
 var dv:=drape_point360(u,v+.0005,layer)-drape_point360(u,v-.0005,layer)
 var normal:=dv.cross(du).normalized();st.set_normal(-normal if lower else normal);st.set_uv(uv)
 st.add_vertex(drape_point360(u,v,layer)-Vector3.UP*(.035 if lower else 0.))
func drape360(parent: Node3D,layer: int,tile: Vector2i) -> void:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for lower in [false,true]:
  for y in 48:
   for x in 56:
    var ids: Array=[Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]
    if lower:ids.reverse()
    for d in ids:drape_vertex360(st,Vector2(float(x+d.x)/56.,float(y+d.y)/48.),layer,lower)
 for side in 4:
  for i in 56:
   var a:=Vector2(float(i)/56.,0.);var b:=Vector2(float(i+1)/56.,0.)
   match side:
    1:a.y=1.;b.y=1.
    2:a=Vector2(0.,a.x);b=Vector2(0.,b.x)
    3:a=Vector2(1.,a.x);b=Vector2(1.,b.x)
   var pa:=drape_point360(lerpf(-1.26,1.26,a.x),a.y*1.24,layer);var pb:=drape_point360(lerpf(-1.26,1.26,b.x),b.y*1.24,layer)
   for k in [0,1,2,2,1,3]:
    st.set_normal((pb-pa).cross(Vector3.DOWN).normalized());st.set_uv(a if k<2 else b);st.add_vertex((pa if k<2 else pb)-Vector3.UP*(.035 if k%2 else 0.))
 var n:=shape(parent,st.commit(),Vector3.ZERO,fabric359(tile));surfaces360.append(n)
func skirt360() -> void:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 # Three-sided pleated skirt sits below the duvet, behind the decorative foot rail.
 for side in 3:
  for i in 96:
   for d in [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
    var t:=float(i+d.x)/96.;var h:=float(d.y);var r:=.025*sin(t*TAU*12.)
    var pos:=Vector3(lerpf(-1.20,1.20,t),lerpf(.16+.025*cos(t*TAU*12.),.65,h),1.34+r)
    if side!=0:pos=Vector3((-1. if side==1 else 1.)*(1.20+r),pos.y,lerpf(-1.25,1.34,t))
    st.set_uv(Vector2(t,h*.6));st.add_vertex(pos)
 st.generate_normals();shape(bed360,st.commit(),Vector3.ZERO,fabric359(Vector2i(1,0)))
func apply360() -> void:
 if not is_instance_valid(bed360):return
 bed360.visible=art356 and bed_solid358 and use360
 bed358.visible=art356 and bed_solid358 and not use360
func set_art356(value: bool) -> void:
 super.set_art356(value);apply360()
func toggle_soft359() -> void:
 use360=not use360;apply360()
