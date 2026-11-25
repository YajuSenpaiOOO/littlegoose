extends Node3D
var meshes399: Array[MeshInstance3D]=[]
var gable399: MeshInstance3D
var braces399: Array[MeshInstance3D]=[]
var wood399: ShaderMaterial
func _init() -> void:
 name="RearArchTimber399"
 wood399=ShaderMaterial.new();wood399.shader=preload("res://scripts/room/wood395.gdshader")
 wood399.set_shader_parameter("paint",preload("res://assets/room398/cabinet-atlas.png"))
func outer399(x: float) -> float:return 3.65+.95*(1.-pow(x/6.25,2.))
func piece399(mesh: Mesh,mat: Material,label: String) -> MeshInstance3D:
 var n:=MeshInstance3D.new();n.mesh=mesh;n.material_override=mat;n.name=label;add_child(n);meshes399.append(n);return n
func vertex399(st: SurfaceTool,p: Vector3,normal: Vector3,uv: Vector2) -> void:
 st.set_normal(normal);st.set_uv(uv);st.add_vertex(p)
func beam399(points: Array[Vector2],width: float,depth: float,z: float,label: String) -> MeshInstance3D:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var edges: Array=[];var lengths: Array[float]=[0.]
 for i in points.size():
  var tangent: Vector2=(points[mini(i+1,points.size()-1)]-points[maxi(i-1,0)]).normalized()
  var cross_axis:=Vector2(-tangent.y,tangent.x)*width*.5
  var p: Vector2=points[i]
  edges.append([Vector3(p.x+cross_axis.x,p.y+cross_axis.y,z+depth*.5),Vector3(p.x-cross_axis.x,p.y-cross_axis.y,z+depth*.5),Vector3(p.x-cross_axis.x,p.y-cross_axis.y,z-depth*.5),Vector3(p.x+cross_axis.x,p.y+cross_axis.y,z-depth*.5)])
  if i>0:lengths.append(lengths[-1]+points[i].distance_to(points[i-1]))
 for i in range(points.size()-1):
  for face in 4:
   var a: Vector3=edges[i][face];var b: Vector3=edges[i][(face+1)%4]
   var c: Vector3=edges[i+1][(face+1)%4];var d: Vector3=edges[i+1][face]
   var normal: Vector3=(b-a).cross(c-a).normalized()
   for k in [0,2,1,0,3,2]:
    var p: Vector3=[a,b,c,d][k]
    var u: float=.025+(.42 if k in [1,2] else 0.)
    # Quiet vertical wood grain becomes grain along the curved timber length.
    var v: float=.01+fmod(lengths[i+1] if k in [2,3] else lengths[i],2.7)/2.7*.48
    vertex399(st,p,normal,Vector2(u,v))
 for end in [0,points.size()-1]:
  var ring: Array=edges[end]
  var axis: Vector2=(points[1]-points[0]).normalized() if end==0 else (points[-1]-points[-2]).normalized()
  var normal:=Vector3(axis.x,axis.y,0)*(-1. if end==0 else 1.)
  for k in ([0,1,2,0,2,3] if end==0 else [0,2,1,0,3,2]):vertex399(st,ring[k],normal,Vector2(.25,.25))
 return piece399(st.commit(),wood399,label)
func block399(at: Vector3,size: Vector3,label: String) -> MeshInstance3D:
 # Per-face UV, same quiet wood quadrant as the curved beams.
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for face in [[Vector3.RIGHT,Vector3.FORWARD,Vector3.UP],[Vector3.LEFT,Vector3.BACK,Vector3.UP],[Vector3.UP,Vector3.RIGHT,Vector3.FORWARD],[Vector3.DOWN,Vector3.RIGHT,Vector3.BACK],[Vector3.BACK,Vector3.RIGHT,Vector3.UP],[Vector3.FORWARD,Vector3.LEFT,Vector3.UP]]:
  var n: Vector3=face[0];var u: Vector3=face[1];var v: Vector3=face[2]
  for k in [0,2,1,0,3,2]:
   var uv: Vector2=[Vector2(0,1),Vector2(1,1),Vector2(1,0),Vector2(0,0)][k]
   vertex399(st,(n+u*(uv.x*2.-1.)+v*(1.-uv.y*2.))*size*.5,n,Vector2(.006,.006)+uv*.488)
 var node:=piece399(st.commit(),wood399,label);node.position=at;return node
func build399(wall_material: Material) -> void:
 # Thin continuation of existing back wall, shaped to meet the timber arch.
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 64:
  var x0: float=-6.25+12.5*float(i)/64.;var x1: float=-6.25+12.5*float(i+1)/64.
  for side in [-1.,1.]:
   var z: float=-4.5+side*.11
   var pts: Array[Vector3]=[Vector3(x0,3.59,z),Vector3(x1,3.59,z),Vector3(x1,outer399(x1)-.025,z),Vector3(x0,outer399(x0)-.025,z)]
   for k in ([0,2,1,0,3,2] if side>0 else [0,1,2,0,2,3]):vertex399(st,pts[k],Vector3(0,0,side),Vector2.ZERO)
  var a:=Vector3(x0,outer399(x0)-.025,-4.39);var b:=Vector3(x1,outer399(x1)-.025,-4.39)
  var normal:=Vector3(-(outer399(x1)-outer399(x0))/(x1-x0),1,0).normalized()
  for p in [a,b-Vector3(0,0,.22),b,a,a-Vector3(0,0,.22),b-Vector3(0,0,.22)]:vertex399(st,p,normal,Vector2.ZERO)
 gable399=piece399(st.commit(),wall_material,"ArchedRearWallExtension")
 var arch: Array[Vector2]=[]
 for i in 65:
  var x: float=-6.25+12.5*float(i)/64.;arch.append(Vector2(x,outer399(x)-.12))
 beam399(arch,.27,.30,-4.20,"ContinuousRearArch")
 for side in [-1.,1.]:
  # Shallow pilaster embedded in the already blocking rear wall, rather than a new floor obstacle.
  block399(Vector3(side*6.12,1.65,-4.48),Vector3(.25,3.30,.22),"RearCornerPilaster")
  block399(Vector3(side*6.10,3.39,-4.30),Vector3(.38,.22,.42),"PostCapital")
  block399(Vector3(side*6.10,2.79,-4.30),Vector3(.28,.16,.38),"BraceSeat")
  var brace: Array[Vector2]=[]
  var p:=Vector2(side*6.10,2.79);var q:=Vector2(side*6.08,3.58);var r:=Vector2(side*4.70,3.82)
  for i in 25:
   var t: float=float(i)/24.;brace.append(p*(1.-t)*(1.-t)+q*2.*t*(1.-t)+r*t*t)
  braces399.append(beam399(brace,.15,.21,-4.20,"CurvedCornerBrace"))
 # The existing pair of window posts visibly meets the arch, avoiding unsupported cut-off ends.
 for x in [-2.1,1.1]:
  var top: float=outer399(x)-.22
  block399(Vector3(x,(3.56+top)*.5,-4.27),Vector3(.16,top-3.56,.19),"WindowPostExtension")
 # Restrained join collars make the long arch read as assembled timber, not a floating ribbon.
 for x in [-4.3,4.3]:
  var collar:=block399(Vector3(x,outer399(x)-.12,-4.20),Vector3(.075,.30,.33),"ArchJoinCollar")
  collar.rotation.z=atan(-1.90*x/(6.25*6.25))
