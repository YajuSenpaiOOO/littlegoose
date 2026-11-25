extends "res://scripts/world/room_world379.gd"
var motion380:=true
var blend380:=1.0
var shadow380: MeshInstance3D
var ink380: ShaderMaterial
var clock380:=0.0
func _ready() -> void:
 await super._ready()
 for child in rig379.get_children():
  if child is MeshInstance3D and child.get("visual")!=null:child.enabled=false;child.visible=false
 shadow380=MeshInstance3D.new();shadow380.name="UnionFlightShadow380";shadow380.mesh=PlaneMesh.new();shadow380.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(shadow380)
 ink380=ShaderMaterial.new();ink380.shader=preload("res://scripts/art/flight_shadow380.gdshader");shadow380.material_override=ink380
 DisplayServer.window_set_title("小白鹅 · 380 · 自然悬浮与合并地影")
 help367="380 · 自然悬浮与合并地影\nO 悬浮呼吸开关 · P 全部暂停 · U 慢放\nV 暂停逐帧 · I 原C/动画 · Y 悬浮/同基线\nK 重排 · N 近看 · F2 昼夜 · L 补光\n双翼/身体共用运动根与一份轮廓地影"
 refresh367();update_shadow380()
func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(rig379):return
 if playing379:
  clock380+=delta*(.25 if slow379 else 1.)
  blend380=move_toward(blend380,1. if motion380 else 0.,delta*4.)
 var strength:=blend380 if lift377 and not reference379 else 0.
 # Slow hovering plus a restrained wing-beat lift; one root keeps attachment exact.
 var drift:=sin(clock380*TAU*.65)*.045+sin(age379*TAU/.56-1.0)*.009
 rig379.position.y+=drift*strength
 rig379.position.x+=sin(clock380*TAU*.33)*.012*strength
 rig379.rotation.z=sin(clock380*TAU*.43)*.012*strength
 var breath:=sin(clock380*TAU*.8)*.005
 var spring:=sin(age379*TAU/.56-.5)*.008
 rig379.scale=Vector3(1.-(breath+spring)*strength,1.+(breath+spring)*strength,1.)
 update_shadow380()
func bind_shadow380(prefix: String, visual: Sprite3D) -> void:
 var tex: AtlasTexture=visual.texture
 ink380.set_shader_parameter(prefix+"_tex",tex.atlas)
 var size:=tex.atlas.get_size()
 ink380.set_shader_parameter(prefix+"_region",Vector4(tex.region.position.x/size.x,tex.region.position.y/size.y,tex.region.size.x/size.x,tex.region.size.y/size.y))
 ink380.set_shader_parameter(prefix+"_inverse",visual.global_transform.affine_inverse())
 ink380.set_shader_parameter(prefix+"_layout",Vector4(tex.region.size.x,tex.region.size.y,visual.offset.x,visual.offset.y))
 ink380.set_shader_parameter(prefix+"_density",visual.pixel_size)
func update_shadow380() -> void:
 if not is_instance_valid(shadow380):return
 shadow380.visible=rig379.visible and contact_enabled
 var ray: Vector3=-sun.global_basis.z.normalized()
 ink380.set_shader_parameter("light_ray",ray)
 bind_shadow380("body",body379);bind_shadow380("wing",wing379)
 var low:=Vector2(INF,INF);var high:=Vector2(-INF,-INF)
 var floor_y: float=floor_height(Vector2(rig379.position.x,rig379.position.z))+.022
 for visual in [body379,wing379]:
  var size: Vector2=visual.texture.get_size()
  for uv in [Vector2.ZERO,Vector2(1,0),Vector2.ONE,Vector2(0,1)]:
   var p: Vector3=visual.to_global(Vector3(((uv.x-.5)*size.x+visual.offset.x)*visual.pixel_size,((.5-uv.y)*size.y+visual.offset.y)*visual.pixel_size,0))
   p+=ray*((floor_y-p.y)/ray.y)
   low=low.min(Vector2(p.x,p.z));high=high.max(Vector2(p.x,p.z))
 var center: Vector2=(low+high)*.5
 shadow380.position=Vector3(center.x,floor_y,center.y);shadow380.mesh.size=high-low+Vector2(.04,.04)
func _input(event: InputEvent) -> void:
 if is_instance_valid(rig379) and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_O:
  motion380=not motion380;get_viewport().set_input_as_handled();return
 super._input(event)
