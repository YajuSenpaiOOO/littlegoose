extends "res://scripts/room/cottage421.gd"

const REAR_CUT := -2.06
var rear_window: Node3D

func set_cut(value: float) -> void:
 super.set_cut(value)
 # Retain the actual rear roof mesh, trimming along a transverse rafter.
 var amount:=smoothstep(.04,.68,value)
 for entry in roof_cut:
  entry.node.visible=true
  if is_zero_approx(amount):
   entry.node.material_override=entry.original
  else:
   entry.node.material_override=entry.ink
   entry.ink.set_shader_parameter("edge_noise",1.0-amount)
   entry.ink.set_shader_parameter("keep_behind",REAR_CUT)
   entry.ink.set_shader_parameter("cut_height",lerpf(7.36,2.20,amount))

func register_cut(node: GeometryInstance3D,entries: Array[Dictionary]) -> void:
 var count:=entries.size()
 super.register_cut(node,entries)
 if entries.size()==count:return
 var entry: Dictionary=entries.back()
 var ink: ShaderMaterial=entry.ink
 ink.shader=preload("res://scripts/room/cutaway422.gdshader")
 ink.set_shader_parameter("paint",entry.original.albedo_texture)
 ink.set_shader_parameter("tint",entry.original.albedo_color)
 ink.set_shader_parameter("use_vertex_color",entry.original.vertex_color_use_as_albedo)
 if entry.original.emission_enabled:
  var glow: Color=entry.original.emission
  ink.set_shader_parameter("glow",Vector3(glow.r,glow.g,glow.b)*entry.original.emission_energy_multiplier)

func window(parent: Node3D,at: Vector3,width: float,height: float,leaf: float) -> void:
 if parent.position.z > -3.7:
  super.window(parent,at,width,height,leaf)
  return
 rear_window=Node3D.new()
 rear_window.name="OpenGardenWindow422"
 rear_window.position=Vector3(0,1.15,-3.8)
 shell.add_child(rear_window)
 const HALF := 1.025
 const SPRING := 1.12
 const RISE := .40
 # Line the rectangular masonry aperture with solid sides and a curved head.
 var curve: Array[Vector2]=[]
 for i in 25:
  var t:=PI*i/24.
  curve.append(Vector2(-cos(t)*HALF,SPRING+sin(t)*RISE))
 for i in 24:
  var a:=curve[i]
  var b:=curve[i+1]
  polygon(rear_window,PackedVector2Array([a,b,Vector2(b.x,1.53),Vector2(a.x,1.53)]),.10,plaster)
  polygon(rear_window,PackedVector2Array([a,b,Vector2(b.x,1.53),Vector2(a.x,1.53)]),-.10,plaster)
 var frame:=preload("res://scripts/room/timber_frame399.gd").new()
 rear_window.add_child(frame)
 frame.beam399(curve,.115,.28,.0,"WindowArch422")
 for x in [-HALF,HALF]:
  block(rear_window,Vector3(x,.56,0),Vector3(.13,1.17,.28),wood)
 block(rear_window,Vector3(0,.015,.025),Vector3(2.24,.13,.44),wood)
 block(rear_window,Vector3(0,.76,0),Vector3(.070,1.48,.09),wood)
 block(rear_window,Vector3(0,.76,0),Vector3(2.00,.067,.09),wood)
 block(rear_window,Vector3(0,1.125,0),Vector3(2.00,.058,.075),wood)
 # Physical sill is taller than the actor step. Keep a clear optical opening.
 block(rear_window,Vector3(0,-.37,.01),Vector3(2.16,.74,.22),plaster,true).hide()
 add_curtains422()

func add_curtains422() -> void:
 var material:=ShaderMaterial.new()
 var woven:=Shader.new()
 woven.code="""
shader_type spatial;
render_mode cull_disabled;
void fragment() {
 vec2 bands = step(vec2(.5), fract(UV * vec2(6., 12.)));
 ALBEDO = mix(vec3(.76,.68,.44),vec3(.29,.35,.16),.37*(bands.x+bands.y));
 ROUGHNESS = 1.;
}
"""
 material.shader=woven
 block(rear_window,Vector3(0,1.64,.24),Vector3(2.54,.066,.07),wood)
 for side in [-1.,1.]:
  var st:=SurfaceTool.new()
  st.begin(Mesh.PRIMITIVE_TRIANGLES)
  for row in 20:
   for fold in 12:
    for corner in [Vector2.ZERO,Vector2.RIGHT,Vector2.ONE,Vector2.ZERO,Vector2.ONE,Vector2.DOWN]:
     var u: float=(fold+corner.x)/12.
     var v: float=(row+corner.y)/20.
     var gathered:=exp(-pow((v-.60)*5.7,2.))
     var x: float=side*(lerpf(.57,1.24,u)+gathered*(1.-u)*.36)
     st.set_uv(Vector2(u,v))
     st.add_vertex(Vector3(x,1.63-v*1.45,.22+.051*cos(u*TAU*4.)+.03*gathered))
  st.generate_normals()
  mesh_at(rear_window,st.commit(),Vector3.ZERO,material)
  block(rear_window,Vector3(side*1.10,.75,.246),Vector3(.30,.053,.075),color("bd9b66"))
