extends "res://scripts/room/room_shell367.gd"
const SLEEP368=preload("res://scripts/room/sleep_mesh368.gd")
var right_pillow368: Node3D
var left_body368: MeshInstance3D
var empty_pillow_mesh368: ArrayMesh
var pressed_pillow_mesh368: ArrayMesh
var empty_pillow_transform368:=Transform3D.IDENTITY
var empty_duvet368: ArrayMesh
var empty_throw368: ArrayMesh
var occupied_duvet368: ArrayMesh
var occupied_throw368: ArrayMesh
var head_anchor368: Node3D
var shoulder_anchor368: Node3D
var sleep_actor368: MeshInstance3D
var sleep_material368: ShaderMaterial
var head_contact368: MeshInstance3D
var occupied368:=false
var breath_time368:=0.
func build_furniture() -> void:
 super.build_furniture()
 right_pillow368=pillow364.duplicate();right_pillow368.name="RightPillowReserved368";craft364.add_child(right_pillow368)
 right_pillow368.position=Vector3(.56,1.03,-.94);right_pillow368.rotation_degrees=Vector3(-29.,0.,2.)
 # The new right pillow participates in optional material comparisons without sharing pose deformation.
 var old_pairs: Array=pairs367.duplicate()
 for n in right_pillow368.find_children("*","MeshInstance3D",true,false):
  for row in old_pairs:
   if n.material_override==row.original:pairs367.append({"node":n,"original":row.original,"pixel":row.pixel});break
 empty_pillow_transform368=pillow364.transform
 left_body368=pillow364.get_child(1);empty_pillow_mesh368=left_body368.mesh;pressed_pillow_mesh368=SLEEP368.pressed368(empty_pillow_mesh368)
 empty_duvet368=duvet_mesh366.mesh;empty_throw368=throw_mesh366.mesh
 occupied_duvet368=SLEEP368.occupied_cover368(empty_duvet368);occupied_throw368=SLEEP368.occupied_cover368(empty_throw368)
 head_anchor368=Node3D.new();head_anchor368.name="HeadContactAnchor368";pillow364.add_child(head_anchor368);head_anchor368.position=SLEEP368.head_surface368()
 shoulder_anchor368=Node3D.new();shoulder_anchor368.name="NeckShoulderAnchor368";shoulder_anchor368.position=Vector3(-.56,QUILT366.sheet_height366(-.56,-.50)+.025,-.50);craft364.add_child(shoulder_anchor368)
 # Build the reclining pose against the actual occupied pillow transform, not a standing sprite turned sideways.
 pillow364.position=Vector3(-.56,.89,-.99);pillow364.rotation_degrees=Vector3(-78.,0.,-2.)
 var head: Vector3=pillow364.transform*head_anchor368.position
 var mesh:=SLEEP368.pose_mesh368(head,shoulder_anchor368.position,SLEEP368.HEAD_UP368,pillow364.transform)
 sleep_material368=ShaderMaterial.new();sleep_material368.shader=preload("res://scripts/room/sleep_pose368.gdshader");sleep_material368.set_shader_parameter("pose",source356("res://assets/room362/hero_sleep.png"))
 sleep_actor368=shape(craft364,mesh,Vector3.ZERO,sleep_material368);sleep_actor368.name="RecliningHero368";sleep_actor368.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var quad:=QuadMesh.new();quad.size=Vector2(.43,.30)
 var shadow:=ShaderMaterial.new();shadow.shader=preload("res://scripts/art/foot_contact16.gdshader")
 head_contact368=shape(pillow364,quad,head_anchor368.position-Vector3(0.,0.,.002),shadow);head_contact368.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var right_contact:=PlaneMesh.new();right_contact.size=Vector2(1.08,.70)
 var right_shadow:=shape(craft364,right_contact,Vector3(.56,.804,-.94),shadow);right_shadow.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 set_occupied368(false)
func set_occupied368(value: bool) -> void:
 occupied368=value
 if not is_instance_valid(sleep_actor368):return
 if value:
  pillow364.position=Vector3(-.56,.89,-.99);pillow364.rotation_degrees=Vector3(-78.,0.,-2.);left_body368.mesh=pressed_pillow_mesh368
 else:pillow364.transform=empty_pillow_transform368;left_body368.mesh=empty_pillow_mesh368
 sleep_actor368.visible=value;head_contact368.visible=value
 duvet_mesh366.mesh=occupied_duvet368 if value else empty_duvet368
 throw_mesh366.mesh=occupied_throw368 if value else empty_throw368
 contact_pillow364.position.z=-.99 if value else -.91
func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(sleep_material368):return
 breath_time368+=delta;sleep_material368.set_shader_parameter("breathe",.0015*sin(breath_time368*1.7) if occupied368 else 0.)
 var phase:=clampf(inverse_lerp(.42,.70,world.environment.ambient_light_energy),0.,1.)
 sleep_material368.set_shader_parameter("room_tint",Vector3(.50,.51,.59).lerp(Vector3(.9,.89,.89),phase))
