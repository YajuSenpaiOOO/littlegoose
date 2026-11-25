extends Node3D
# Small folded leaf meshes tied to the rear beams; no billboard, collider or huge shadow proxy.
var leaf_count400:=0
func _init() -> void:
 name="BeamVines400"
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var paths: Array=[]
 for side in [-1.,1.]:
  var path: Array[Vector3]=[]
  var count: int=22 if side<0 else 17
  for i in count:
   var t: float=float(i)/float(count-1)
   path.append(Vector3(side*(5.85-.63*t+.11*sin(t*7.)),3.62-(1.28 if side<0 else .93)*t,-3.99+.025*sin(t*9.)))
  paths.append(path)
 # A shorter trailing sprig beside the right window post, not across the glass.
 var small: Array[Vector3]=[]
 for i in 12:
  var t: float=float(i)/11.;small.append(Vector3(1.45+.17*sin(t*4.),3.96-.68*t,-4.03))
 paths.append(small)
 var helper:=preload("res://scripts/room/furniture_model396.gd").new();add_child(helper)
 var stem:=helper.plain396("647349")
 for path in paths:
  var points: Array[Vector3]=[]
  for p in path:points.append(p)
  var twig:=helper.tube396(points,.009,stem,"VineStem")
  twig.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  for i in range(1,path.size()-1,2):
   for side in [-1.,1.]:
    var root: Vector3=path[i].lerp(path[i+1],.45 if side>0. else 0.)
    var direction:=Vector3(side*.85,-.32+.16*sin(float(i)),.08).normalized()
    var cross_axis:=Vector3(-direction.y,direction.x,0).normalized()
    var length: float=.20+.055*sin(float(i)*2.7+side)
    var mid: Vector3=root+direction*length*.46+Vector3(0,0,.018)
    var color:=Color("81945e") if i%3==0 else Color("647c4a")
    var outline: Array[Vector2]=[Vector2(0,0),Vector2(.18,.24),Vector2(.43,.36),Vector2(.73,.27),Vector2(1,0),Vector2(.73,-.27),Vector2(.43,-.36),Vector2(.18,-.24)]
    for k in 8:
     var a: Vector2=outline[k];var b: Vector2=outline[(k+1)%8]
     for p in [root+direction*length*a.x+cross_axis*length*a.y,root+direction*length*b.x+cross_axis*length*b.y,mid]:
      st.set_normal(Vector3(0,.25,1).normalized());st.set_color(color);st.add_vertex(p)
    leaf_count400+=1
 var mat:=StandardMaterial3D.new();mat.vertex_color_use_as_albedo=true;mat.cull_mode=BaseMaterial3D.CULL_DISABLED;mat.roughness=1.;mat.specular_mode=BaseMaterial3D.SPECULAR_DISABLED
 var leaves:=MeshInstance3D.new();leaves.name="FoldedLeaves";leaves.mesh=st.commit();leaves.material_override=mat;leaves.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(leaves)
