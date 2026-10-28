extends Node
const PLAN=preload("res://scripts/world/forest_plan188.gd")
var world: Node3D
var art: Node3D
var enabled := true
var amount := 0.
var focus: ShaderMaterial
var approach189 := PackedVector4Array()
var enable_mix189 := 1.
var emitter_depths190 := PackedFloat32Array()
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
 code=code.replace("void vertex()",FileAccess.get_file_as_string("res://scripts/art/forest_mood189_uniforms.gdshaderinc")+FileAccess.get_file_as_string("res://scripts/art/emitter_mask190.gdshaderinc")+"\nvoid vertex()")
 code=code.replace("float protection56=max(glass_mask(SCREEN_UV)*.92,warm56*.88*night_mix56);","float protection56=max(glass_mask(SCREEN_UV)*.92,emitter_mask190(SCREEN_UV,distance)*.94);")
 code=code.replace("actor_mask57*actor_stage57*.48","0.")
 code=code.replace("if(cone_strength58>0. &&","if(false && cone_strength58>0. &&")
 var end := code.rfind("}")
 code=code.substr(0,end)+FileAccess.get_file_as_string("res://scripts/art/forest_mood190_fragment.gdshaderinc")+"\n}"
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
 update_emitters190()
func update_emitters190() -> void:
 emitter_depths190.clear()
 var cores := PackedVector4Array()
 for prop in art.props181:
  if prop.texture==preload("res://assets/forest188/post_top_nightlight_pixel.png"):
   core190(cores,prop,Vector2(.56,.23),Vector2(.17,.12))
  elif prop.texture==preload("res://assets/forest184/hanging_lantern.png"):
   core190(cores,prop,Vector2(.5,.78),Vector2(.30,.16))
 # These are authored windows on the house, not any warm-colored scene pixel.
 core190(cores,art.cottage_sprite,Vector2(.53,.25),Vector2(.035,.055))
 core190(cores,art.cottage_sprite,Vector2(.22,.62),Vector2(.035,.055))
 core190(cores,art.cottage_sprite,Vector2(.73,.62),Vector2(.045,.06))
 focus.set_shader_parameter("emitter_count190",cores.size());cores.resize(20)
 focus.set_shader_parameter("emitter_rects190",cores)
 emitter_depths190.resize(20);focus.set_shader_parameter("emitter_depths190",emitter_depths190)
func core190(cores: PackedVector4Array,visual: Sprite3D,uv: Vector2,radius: Vector2) -> void:
 if cores.size()>=20 or not visual.is_visible_in_tree(): return
 var texture: Texture2D=visual.texture;var full: Texture2D=texture.atlas if texture is AtlasTexture else texture
 var bounds: Rect2i=art.opaque_bounds181(full);var pixel := Vector2(bounds.position)+Vector2(bounds.size)*uv
 var size: Vector2=texture.get_size()
 var dx := (pixel.x-full.get_width()*.5+visual.offset.x)*visual.pixel_size
 var up := (size.y*.5-pixel.y+visual.offset.y)*visual.pixel_size
 var position: Vector3=visual.global_position+world.camera.global_basis.x*dx+world.camera.global_basis.y*up
 if world.camera.is_position_behind(position): return
 var viewport: Vector2=world.get_viewport().get_visible_rect().size
 var centre: Vector2=world.camera.unproject_position(position)/viewport
 var right: Vector2=world.camera.unproject_position(position+world.camera.global_basis.x*(bounds.size.x*radius.x*visual.pixel_size))/viewport
 var top: Vector2=world.camera.unproject_position(position+world.camera.global_basis.y*(bounds.size.y*radius.y*visual.pixel_size))/viewport
 cores.append(Vector4(centre.x,centre.y,absf(right.x-centre.x),absf(top.y-centre.y)))
 emitter_depths190.append(-world.camera.to_local(position).z)
