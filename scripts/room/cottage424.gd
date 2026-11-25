extends "res://scripts/room/cottage423.gd"

var full_roof:=false
var joinery: Node3D
var plaster_inside: ShaderMaterial
var timber_inside: ShaderMaterial
const HALL_EDGE := 3.03
const WING_EDGE := 1.83

func _ready() -> void:
 super._ready()
 joinery=Node3D.new()
 joinery.name="ConnectedInteriorRoof424"
 add_child(joinery)
 plaster_inside=interior_ink(plaster)
 timber_inside=interior_ink(wood)
 var half_open:=3.06
 build_lining(joinery,3.57,3.26,6.85,-3.83,HALL_EDGE,Vector3.ZERO,0.,plaster_inside)
 # Bring the plaster return up to the sampled roof profile at the rear.
 var rear:=SurfaceTool.new()
 rear.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 40:
  var a:=lerpf(-3.17,3.17,i/40.)
  var b:=lerpf(-3.17,3.17,(i+1)/40.)
  var ya:=roof_height(a,3.57,3.26,6.85)-.22
  var yb:=roof_height(b,3.57,3.26,6.85)-.22
  cap_quad(rear,Vector3(a,3.29,-3.76),Vector3(b,3.29,-3.76),Vector3(b,yb,-3.76),Vector3(a,ya,-3.76))
 rear.generate_normals()
 mesh_at(joinery,rear.commit(),Vector3.ZERO,plaster_inside).cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var trim:=preload("res://scripts/room/timber_frame399.gd").new()
 joinery.add_child(trim)
 for side in [-1.,1.]:
  var rafter: Array[Vector2]=[]
  for i in 18:
   var x: float=side*3.31*i/17.
   rafter.append(Vector2(x,roof_height(x,3.57,3.26,6.85)-.32))
  var beam_mesh:=trim.beam399(rafter,.19,.24,HALL_EDGE-.04,"FrontInteriorRafter424")
  beam_mesh.material_override=timber_inside
  beam_mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 for side in [-1.,1.]:
  # Finish the hall liner against its wall plate, including the rear returns.
  var x: float=side*half_open
  var hall_y:=roof_height(x,3.57,3.26,6.85)-.25
  block(joinery,Vector3(x,(hall_y+3.26)*.5,-1.60),Vector3(.25,hall_y-3.26+.10,4.48),plaster_inside)
  block(joinery,Vector3(x,hall_y-.07,-1.58),Vector3(.25,.19,4.55),timber_inside)
  # Wing undersides follow the original east-west roofs all the way to
  # their actual outer wall. The cut only trims the near end of the lining.
  add_wing(side)
 joinery.hide()

func interior_ink(source: StandardMaterial3D) -> ShaderMaterial:
 var ink:=ShaderMaterial.new()
 ink.shader=preload("res://scripts/room/interior_roof423.gdshader")
 ink.set_shader_parameter("paint",source.albedo_texture)
 ink.set_shader_parameter("cutoff",3.85)
 return ink

func add_wing(side: float) -> void:
 var z0:=-2.62
 var x0: float=side*3.31
 var x1: float=side*6.21
 var inside_x: float=side*3.31
 var edge_y:=wing_height(WING_EDGE)
 var st:=SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 35:
  var za:=lerpf(z0,WING_EDGE,i/35.)
  var zb:=lerpf(z0,WING_EDGE,(i+1)/35.)
  cap_quad(st,Vector3(x0,wing_height(za),za),Vector3(x1,wing_height(za),za),Vector3(x1,wing_height(zb),zb),Vector3(x0,wing_height(zb),zb))
  # Rise from the top of the exterior end wall and the partition top
  # to the same sampled liner height, so no sky is visible in the joint.
  for x in [x1,inside_x]:
   cap_quad(st,Vector3(x,2.79,za),Vector3(x,wing_height(za)+.015,za),Vector3(x,wing_height(zb)+.015,zb),Vector3(x,2.79,zb))
 cap_quad(st,Vector3(x0,2.78,z0),Vector3(x1,2.78,z0),Vector3(x1,wing_height(z0)+.015,z0),Vector3(x0,wing_height(z0)+.015,z0))
 st.generate_normals()
 var joined:=mesh_at(joinery,st.commit(),Vector3.ZERO,plaster_inside)
 joined.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 block(joinery,Vector3(side*4.76,edge_y-.075,WING_EDGE),Vector3(2.92,.20,.24),timber_inside)
 for x in [side*3.36,side*5.98]:
  beam(joinery,Vector3(x,2.78,WING_EDGE-.38),Vector3(x,edge_y,WING_EDGE),.18,.22,timber_inside)

func wing_height(z: float) -> float:
 return roof_height(z+.225,2.69,2.85,4.15)-.25

func cap_quad(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3,d: Vector3) -> void:
 for v in [a,b,c,a,c,d]:
  st.set_uv(Vector2(v.x+v.z,v.y+v.z)*.34)
  st.add_vertex(v)

func set_cut(value: float) -> void:
 super.set_cut(value)
 if not is_instance_valid(joinery):return
 inner_eaves.hide()
 var amount:=smoothstep(.31,.88,value)
 joinery.visible=amount>.001 and not full_roof
 for ink in [plaster_inside,timber_inside]:
  ink.set_shader_parameter("reveal",amount)
 if full_roof:
  for entry in roof_cut:
   entry.node.visible=true
   entry.node.material_override=entry.original
