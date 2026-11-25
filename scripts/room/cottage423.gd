extends "res://scripts/room/cottage422.gd"

const THRESHOLD := 3.305
const HINGE_ANGLE := 105.
var swing_side:=0
var next_swing: Tween
var inner_eaves: Node3D
var cover_material: ShaderMaterial
var wing_cover_material: ShaderMaterial

func _ready() -> void:
 super._ready()
 # The leaf is queried separately from walls. Its arc must not trap an actor.
 pivot.collision_layer=1<<22
 inner_eaves=Node3D.new()
 inner_eaves.name="InteriorRoofLining423"
 add_child(inner_eaves)
 cover_material=ShaderMaterial.new()
 cover_material.shader=preload("res://scripts/room/interior_roof423.gdshader")
 cover_material.set_shader_parameter("paint",plaster.albedo_texture)
 cover_material.set_shader_parameter("cutoff",-1.13)
 wing_cover_material=cover_material.duplicate() as ShaderMaterial
 wing_cover_material.set_shader_parameter("cutoff",.37)
 build_lining(inner_eaves,3.57,3.26,6.85,-3.80,-1.13,Vector3.ZERO,0.,cover_material)
 for side in [-1.,1.]:
  var z:=-.225
  var length:=1.58
  build_lining(inner_eaves,2.69,2.85,4.15,-length,length,Vector3(side*4.60,0,z),PI*.5,wing_cover_material)
 inner_eaves.hide()

func build_lining(parent: Node3D,half: float,eave: float,ridge: float,back: float,front: float,at: Vector3,yaw: float,ink: ShaderMaterial) -> void:
 var st:=SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var span:=half-.25
 for i in 44:
  var xa:=lerpf(-span,span,i/44.)
  var xb:=lerpf(-span,span,(i+1)/44.)
  var ya:=roof_height(xa,half,eave,ridge)-.25
  var yb:=roof_height(xb,half,eave,ridge)-.25
  for v in [Vector3(xa,ya,back),Vector3(xb,yb,back),Vector3(xb,yb,front),Vector3(xa,ya,back),Vector3(xb,yb,front),Vector3(xa,ya,front)]:
   st.set_uv(Vector2(v.x,v.z)*.32)
   st.add_vertex(v)
 st.generate_normals()
 var lining:=mesh_at(parent,st.commit(),at,ink)
 lining.rotation.y=yaw
 lining.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func set_cut(value: float) -> void:
 super.set_cut(value)
 if not is_instance_valid(inner_eaves):return
 inner_eaves.visible=value>.29
 var reveal:=smoothstep(.29,.84,value)
 cover_material.set_shader_parameter("reveal",reveal)
 wing_cover_material.set_shader_parameter("reveal",reveal)
 # The exterior tile assembly is still used outside. Indoors the close
 # camera sees the lining on the underside and timber on the cut edge.
 var lining_amount:=smoothstep(.40,.90,value)
 for entry in roof_cut:
  var original: StandardMaterial3D=entry.original
  if original!=slate and not original.vertex_color_use_as_albedo:continue
  if lining_amount>=.998:
   entry.node.hide()
  elif entry.node.material_override==entry.ink:
   entry.ink.set_shader_parameter("coverage423",1.-lining_amount)

func register_cut(node: GeometryInstance3D,entries: Array[Dictionary]) -> void:
 var count:=entries.size()
 super.register_cut(node,entries)
 if entries.size()==count:return
 var entry: Dictionary=entries.back()
 var shared_shader: Shader=preload("res://scripts/room/cutaway423.gdshader")
 entry.ink.shader=shared_shader
 entry.ink.set_shader_parameter("paint",entry.original.albedo_texture)
 entry.ink.set_shader_parameter("tint",entry.original.albedo_color)
 entry.ink.set_shader_parameter("use_vertex_color",entry.original.vertex_color_use_as_albedo)
 if entry.original.emission_enabled:
  var glow: Color=entry.original.emission
  entry.ink.set_shader_parameter("glow",Vector3(glow.r,glow.g,glow.b)*entry.original.emission_energy_multiplier)

func set_door(value: bool) -> void:
 swing(1 if value else 0)

func swing(side: int) -> void:
 if side==swing_side and (is_instance_valid(next_swing) and next_swing.is_running() or is_equal_approx(pivot.rotation_degrees.y,HINGE_ANGLE*side)):return
 swing_side=side
 if is_instance_valid(next_swing):next_swing.kill()
 var opening:=side!=0
 next_swing=create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
 next_swing.tween_property(pivot,"rotation:y",deg_to_rad(HINGE_ANGLE*side),.21 if opening else .38)
