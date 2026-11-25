extends RefCounted
# Geometry is built along reference-camera rays so the newly drawn pose keeps its aspect.
# It stays fixed in bed space; following the camera never rotates the sleeping figure.
const WIDTH=1.48
const HEIGHT=WIDTH*1312./1199.
const UP=Vector3(0.,.9063078,-.4226183)
const BACK=Vector3(0.,.4226183,.9063078)
static func point369(uv: Vector2) -> Vector3:
 var eye:=Vector3(0.,1.02,-.20)+BACK*6.8
 var flat:=Vector3(-.56,1.00,-.55)+Vector3.RIGHT*(uv.x-.5)*WIDTH+UP*(.5-uv.y)*HEIGHT
 var t:=smoothstep(0.,1.,uv.y)
 var z:=lerpf(-1.27,.55,t)
 # A modest face crown, shallow hair edges; no depth-writing shader or stretched body strips.
 z+=.065*exp(-pow((uv.x-.51)/.21,2.)-pow((uv.y-.37)/.19,2.))
 return eye+(flat-eye)*((z-eye.z)/(flat.z-eye.z))
static func mesh369(first: float,last: float) -> ArrayMesh:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for y in 48:
  for x in 40:
   for d in [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
    var uv:=Vector2(float(x+d.x)/40.,lerpf(first,last,float(y+d.y)/48.))
    st.set_uv(uv);st.add_vertex(point369(uv))
 st.generate_normals();return st.commit()
static func cover_point369(p: Vector3) -> Vector3:
 var lift:=.040*exp(-pow((p.x+.56)/.37,2.)-pow((p.z+.43)/.36,2.))
 var draw: float=.10*exp(-pow((p.x+.56)/.50,2.))*(1.-smoothstep(-.65,-.15,p.z))
 return p+Vector3(0.,lift,-draw)
static func cover369(source: ArrayMesh) -> ArrayMesh:
 var arrays:=source.surface_get_arrays(0)
 var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
 var normals: PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
 for i in vertices.size():
  var p:=vertices[i]
  var dx: Vector3=(cover_point369(p+Vector3(.001,0.,0.))-cover_point369(p-Vector3(.001,0.,0.)))/.002
  var dz: Vector3=(cover_point369(p+Vector3(0.,0.,.001))-cover_point369(p-Vector3(0.,0.,.001)))/.002
  normals[i]=(Basis(dx,Vector3.UP,dz).inverse().transposed()*normals[i]).normalized()
  vertices[i]=cover_point369(p)
 arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_NORMAL]=normals
 var result:=ArrayMesh.new();result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays);return result
