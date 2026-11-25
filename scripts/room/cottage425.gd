extends "res://scripts/room/cottage424.gd"

# The visible stone and its physics use the same slope and tread samples.
const STONE_PROFILE := [
 Vector2(3.13,0.0),Vector2(3.47,0.0),
 Vector2(3.73,-.105),Vector2(3.94,-.105),
 Vector2(4.23,-.22),Vector2(4.39,-.22)
]
const STEP_HALF_WIDTH := 1.17
var stairs: StaticBody3D
var exterior_closures: Array[MeshInstance3D]=[]

func build_entry() -> void:
 super.build_entry()
 for part in terrace.get_children():
  part.hide()
 var st:=SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var half:=STEP_HALF_WIDTH
 # Continuous beveled treads, with solid side faces down to the ground.
 for i in STONE_PROFILE.size()-1:
  var a: Vector2=STONE_PROFILE[i]
  var b: Vector2=STONE_PROFILE[i+1]
  cap_quad(st,Vector3(-half,a.y,a.x),Vector3(half,a.y,a.x),Vector3(half,b.y,b.x),Vector3(-half,b.y,b.x))
  for side in [-1.,1.]:
   var x: float=half*side
   if a.y>-.22 or b.y>-.22:
    cap_quad(st,Vector3(x,-.23,a.x),Vector3(x,a.y,a.x),Vector3(x,b.y,b.x),Vector3(x,-.23,b.x))
 st.generate_normals()
 var stone_ink:=ShaderMaterial.new()
 stone_ink.shader=preload("res://scripts/room/stone_treads425.gdshader")
 stone_ink.set_shader_parameter("paint",stone.albedo_texture)
 var mesh:=mesh_at(terrace,st.commit(),Vector3.ZERO,stone_ink)
 mesh.name="WalkableStoneTreads425"
 mesh.create_trimesh_collision()
 stairs=mesh.get_child(0)
 stairs.get_child(0).shape.backface_collision=true

func stair_top(z: float) -> float:
 for i in STONE_PROFILE.size()-1:
  var a: Vector2=STONE_PROFILE[i]
  var b: Vector2=STONE_PROFILE[i+1]
  if z<=b.x:return lerpf(a.y,b.y,clampf(inverse_lerp(a.x,b.x,z),0.,1.))
 return -.22

func build_walls() -> void:
 super.build_walls()
 add_gable_return(FRONT-.018,3.70)
 add_gable_return(-3.79,-4.105)

func add_gable_return(wall_z: float,eave_z: float) -> void:
 var st:=SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 44:
  var a:=lerpf(-3.48,3.48,i/44.)
  var b:=lerpf(-3.48,3.48,(i+1)/44.)
  var ya:=roof_height(a,3.57,3.26,6.85)-.10
  var yb:=roof_height(b,3.57,3.26,6.85)-.10
  var lower_a:=minf(ya-.015,lerpf(6.85,3.31,absf(a)/3.)-.10)
  var lower_b:=minf(yb-.015,lerpf(6.85,3.31,absf(b)/3.)-.10)
  cap_quad(st,Vector3(a,lower_a,wall_z),Vector3(b,lower_b,wall_z),Vector3(b,yb,wall_z),Vector3(a,ya,wall_z))
  # Soffit, recessed from the fascia, connects the top of the wall to the eave.
  cap_quad(st,Vector3(a,ya,wall_z),Vector3(b,yb,wall_z),Vector3(b,yb,eave_z),Vector3(a,ya,eave_z))
 st.generate_normals()
 var closure:=mesh_at(roof,st.commit(),Vector3.ZERO,wood)
 closure.name="GableAndSoffit425"
 exterior_closures.append(closure)

func block(parent: Node3D,at: Vector3,size: Vector3,ink: Material,solid:=false) -> MeshInstance3D:
 if is_instance_valid(joinery) and parent==joinery and is_equal_approx(absf(at.x),3.06):
  if is_equal_approx(at.z,-1.60):
   # Stop plaster inside the timber. Previously the two visible sides
   # were at exactly the same X for the entire overlapping length.
   size.x=.182
   size.y-=.10
   at.y-=.05
  elif is_equal_approx(at.z,-1.58):
   size.x=.29
 return super.block(parent,at,size,ink,solid)
