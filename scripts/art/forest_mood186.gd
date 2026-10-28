extends Node
const PLAN=preload("res://scripts/world/forest_plan183.gd")
var world: Node3D
var art: Node3D
var enabled := true
var amount := 0.
var focus: ShaderMaterial
static func weight186(at: Vector2) -> float:
 var p := at-PLAN.CENTER
 var core := 1.-smoothstep(.85,1.15,((p-Vector2(-1,0))/Vector2(17,15)).length())
 var nook := 1.-smoothstep(.75,1.2,((p-Vector2(-11,-10))/Vector2(7,6)).length())
 var path := PLAN.path_sample(p)
 var approach := (1.-smoothstep(2.4,4.2,path.x))*smoothstep(0.,1.,clampf((33.-p.x)/23.,0.,1.))
 return maxf(maxf(core,nook),approach)
func _ready() -> void:
 focus=world.atmosphere41.focus_material
 var code: String=focus.shader.code
 var saved: Dictionary={}
 for uniform in focus.shader.get_shader_uniform_list():
  var value=focus.get_shader_parameter(uniform.name)
  if value!=null: saved[uniform.name]=value
 code=code.replace("void vertex()",FileAccess.get_file_as_string("res://scripts/art/forest_mood186_uniforms.gdshaderinc")+"\nvoid vertex()")
 var end := code.rfind("}")
 code=code.substr(0,end)+FileAccess.get_file_as_string("res://scripts/art/forest_mood186_fragment.gdshaderinc")+"\n}"
 var shader := Shader.new();shader.code=code;focus.shader=shader
 for id in saved: focus.set_shader_parameter(id,saved[id])
 amount=weight186(Vector2(world.hero.position.x,world.hero.position.z));update186(0.)
func _process(delta: float) -> void: update186(delta)
func update186(delta: float) -> void:
 var target := weight186(Vector2(world.hero.position.x,world.hero.position.z)) if enabled else 0.
 amount=lerpf(amount,target,1.-exp(-delta*3.)) if delta>0. else target
 focus.set_shader_parameter("forest_strength186",amount)
 var pools := PackedVector4Array()
 for light in art.lights181+art.hanging_lights184:
  if pools.size()>=12: break
  var at: Vector3=light.global_position
  pools.append(Vector4(at.x,at.z,2.8,at.y-1.7))
 focus.set_shader_parameter("forest_pool_count186",pools.size());pools.resize(12)
 focus.set_shader_parameter("forest_pools186",pools)
