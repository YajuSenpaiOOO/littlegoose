extends RefCounted
const BASE=preload("res://scripts/room/bed_mesh364.gd")
const HEAD_UP368=Vector3(0.,.65,-.759934)
const QUILT=preload("res://scripts/room/quilt_mesh366.gd")
static func pressed368(source: ArrayMesh) -> ArrayMesh:
 var arrays:=source.surface_get_arrays(0)
 var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
 var normals: PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
 for i in vertices.size():
  var v:=vertices[i];var n:=normals[i]
  var weight:=exp(-pow(v.x/.26,2.)-pow((v.y-.08)/.22,2.))
  var scale:=1.-.32*weight
  var dx:=.64*v.x/(.26*.26)*weight
  var dy:=.64*(v.y-.08)/(.22*.22)*weight
  normals[i]=Vector3(n.x-v.z*dx/scale*n.z,n.y-v.z*dy/scale*n.z,n.z/scale).normalized()
  vertices[i].z*=scale
 arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_NORMAL]=normals
 var mesh:=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays);return mesh
static func head_surface368() -> Vector3:
 var uv:=Vector2(.5,(.08/.325+1.)*.5)
 var p:=BASE.pillow_point364(uv,false);p.z*=.68;p.z+=.004;return p
static func body_lift368(x: float,z: float) -> float:
 return .12*exp(-pow((x+.56)/.29,2.)-pow((z-.15)/.75,2.))
static func occupied_cover368(source: ArrayMesh) -> ArrayMesh:
 var arrays:=source.surface_get_arrays(0)
 var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
 var normals: PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
 for i in vertices.size():
  var v:=vertices[i];var n:=normals[i];var lift:=body_lift368(v.x,v.z)
  var dx: float=-2.*(v.x+.56)/(.29*.29)*lift
  var dz: float=-2.*(v.z-.15)/(.75*.75)*lift
  vertices[i].y+=lift;normals[i]=Vector3(n.x-dx*n.y,n.y,n.z-dz*n.y).normalized()
 arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_NORMAL]=normals
 var mesh:=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays);return mesh
static func pose_point368(uv: Vector2,head: Vector3,shoulder: Vector3,up: Vector3) -> Vector3:
 var row:=uv.y*1536.
 var center:=head+Vector3.UP*.22+up*(360.-row)*(1.10/1024.)
 if row>620. and row<=800.:
  center=(head+Vector3.UP*.22-up*260.*(1.10/1024.)).lerp(shoulder,smoothstep(0.,1.,(row-620.)/180.))
 elif row>800.:
  var z:=lerpf(-.50,.95,(row-800.)/522.)
  center=Vector3(-.56,QUILT.sheet_height366(-.56,z)+.025,z)
 center.x+=(uv.x*1024.-512.)*(1.10/1024.)
 return center
static func pressed_point368(uv: Vector2) -> Vector3:
 var p:=BASE.pillow_point364(uv,false)
 p.z*=1.-.32*exp(-pow(p.x/.26,2.)-pow((p.y-.08)/.22,2.))
 return p
static func pillow_height368(x: float,z: float,pose: Transform3D) -> float:
 var uv:=Vector2((x-pose.origin.x)/.96+.5,(pose.origin.z-z)/.65+.5)
 for tick in 6:
  if uv.x<0. or uv.x>1. or uv.y<0. or uv.y>1.:return -100.
  var p: Vector3=pose*pressed_point368(uv)
  var error:=Vector2(p.x-x,p.z-z)
  if error.length()<.0003:return p.y
  var a: Vector3=(pose*pressed_point368(uv+Vector2(.0002,0.))-pose*pressed_point368(uv-Vector2(.0002,0.)))/.0004
  var b: Vector3=(pose*pressed_point368(uv+Vector2(0.,.0002))-pose*pressed_point368(uv-Vector2(0.,.0002)))/.0004
  var determinant:=a.x*b.z-b.x*a.z
  if absf(determinant)<.000001:return -100.
  uv-=Vector2((error.x*b.z-error.y*b.x)/determinant,(a.x*error.y-a.z*error.x)/determinant)
 return -100.
static func pose_mesh368(head: Vector3,shoulder: Vector3,up: Vector3,pillow_pose: Transform3D) -> ArrayMesh:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for y in 96:
  for x in 32:
   for d in [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
    var uv:=Vector2(float(x+d.x)/32.,float(y+d.y)/96.)
    var p:=pose_point368(uv,head,shoulder,up)
    # Hair/neck fabric follows the real load-bearing pillow surface wherever the two overlap.
    var floor_y:=pillow_height368(p.x,p.z,pillow_pose)
    if uv.y*1536.>620. and floor_y> -10.:p.y=maxf(p.y,floor_y+.008)
    st.set_normal(Vector3.UP);st.set_uv(uv);st.add_vertex(p)
 return st.commit()
