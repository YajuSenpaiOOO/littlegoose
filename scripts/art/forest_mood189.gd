extends Node
const PLAN=preload("res://scripts/world/forest_plan188.gd")
var world: Node3D
var art: Node3D
var enabled := true
var amount := 0.
var focus: ShaderMaterial
var approach189 := PackedVector4Array()
var enable_mix189 := 1.
func route_weight189(at: Vector2) -> float:
 var result := 0.
 for i in range(1,approach189.size()):
  var a: Vector4=approach189[i-1];var b: Vector4=approach189[i]
  var start := Vector2(a.x,a.y);var end := Vector2(b.x,b.y)
  var q := Geometry2D.get_closest_point_to_segment(at,start,end)
  var t := q.distance_to(start)/maxf(start.distance_to(end),.001)
  result=maxf(result,lerpf(a.z,b.z,t)*(1.-smoothstep(4.,11.,at.distance_to(q))))
 return result*smoothstep(4.5,10.,at.distance_to(Vector2(-4.7,-2.6)))
static func weight188(at: Vector2) -> float:
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
 code=code.replace("void vertex()",FileAccess.get_file_as_string("res://scripts/art/forest_mood189_uniforms.gdshaderinc")+"\nvoid vertex()")
 var end := code.rfind("}")
 code=code.substr(0,end)+FileAccess.get_file_as_string("res://scripts/art/forest_mood189_fragment.gdshaderinc")+"\n}"
 var shader := Shader.new();shader.code=code;focus.shader=shader
 for id in saved: focus.set_shader_parameter(id,saved[id])
 var points: PackedVector2Array=world.connection188.duplicate()
 if points.is_empty(): points=PackedVector2Array([Vector2(-6.,0.),PLAN.CENTER+PLAN.ENTRY])
 var total := 0.
 for i in range(1,points.size()): total+=points[i].distance_to(points[i-1])
 var passed := 0.
 for i in mini(points.size(),64):
  if i>0: passed+=points[i].distance_to(points[i-1])
  approach189.append(Vector4(points[i].x,points[i].y,smoothstep(.08,1.,passed/maxf(total,.01))*.82,0.))
 focus.set_shader_parameter("approach_count189",approach189.size())
 var upload := approach189.duplicate();upload.resize(64);focus.set_shader_parameter("approach189",upload)
 amount=weight188(Vector2(world.hero.position.x,world.hero.position.z));update188(0.)
func _process(delta: float) -> void: update188(delta)
func update188(delta: float) -> void:
 var at := Vector2(world.hero.position.x,world.hero.position.z)
 var target := maxf(weight188(at),route_weight189(at)) if enabled else 0.
 amount=lerpf(amount,target,1.-exp(-delta*3.)) if delta>0. else target
 enable_mix189=lerpf(enable_mix189,1. if enabled else 0.,1.-exp(-delta*3.)) if delta>0. else (1. if enabled else 0.)
 focus.set_shader_parameter("forest_strength186",enable_mix189)
 focus.set_shader_parameter("traveller189",amount)
 var pools := PackedVector4Array()
 for light in art.lights181+art.hanging_lights184:
  if pools.size()>=12: break
  var lamp_at: Vector3=light.global_position
  pools.append(Vector4(lamp_at.x,lamp_at.z,2.6,lamp_at.y-1.7))
 focus.set_shader_parameter("forest_pool_count186",pools.size());pools.resize(12)
 focus.set_shader_parameter("forest_pools186",pools)
