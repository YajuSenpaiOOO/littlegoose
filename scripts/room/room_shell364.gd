extends "res://scripts/room/room_shell363.gd"
const CRAFT364=preload("res://scripts/room/bed_mesh364.gd")
var craft364: Node3D
var head364: Node3D
var pillow364: Node3D
var use_craft364:=true
var painted364:=true
var craft_mats364: Array[ShaderMaterial]=[]
var support_mat364: StandardMaterial3D
var contact_pillow364: MeshInstance3D
func build_furniture() -> void:
 super.build_furniture()
 var row:=item356("bed")
 craft364=Node3D.new();craft364.name="HandPaintedSamples364";row.root.add_child(craft364)
 # Neutral support is deliberately not the completed bed design.
 var wood:=material("97734d");wood.metallic_specular=0.;wood.roughness=1.
 for x in [-1.13,1.13]:
  box(craft364,Vector3(x,.35,0.),Vector3(.13,.28,2.8),wood.albedo_color.to_html(false))
  for z in [-1.27,1.27]:box(craft364,Vector3(x,.16,z),Vector3(.15,.32,.15),"97734d")
 box(craft364,Vector3(0.,.35,1.28),Vector3(2.3,.27,.14),"97734d")
 support_mat364=material("d1c2aa");support_mat364.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
 var mattress:=shape(craft364,CRAFT364.pillow364(),Vector3(0.,.64,0.),support_mat364);mattress.rotation_degrees.x=-90.;mattress.scale=Vector3(2.36/.96,2.78/.65,.30/.28);mattress.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 head364=Node3D.new();head364.name="UVPaintedHeadboard";head364.position.z=-1.37;craft364.add_child(head364)
 var wood_paint:=paint_material364("headboard_front.png",Color("ae8151"))
 add_piece364(head364,CRAFT364.board364(),Vector3.ZERO,wood_paint)
 add_piece364(head364,CRAFT364.trim364(CRAFT364.outline364()),Vector3.ZERO,wood_paint)
 for x in [-1.19,1.19]:add_piece364(head364,CRAFT364.post364(),Vector3(x,0.,0.),wood_paint)
 pillow364=Node3D.new();pillow364.name="UVPaintedLeftPillow";pillow364.position=Vector3(-.56,1.05,-.91);pillow364.rotation_degrees=Vector3(-25.,0.,-2.);craft364.add_child(pillow364)
 var fabric:=paint_material364("pillow_front.png",Color("eee0c7"))
 add_piece364(pillow364,CRAFT364.flange364(),Vector3.ZERO,fabric)
 add_piece364(pillow364,CRAFT364.pillow364(),Vector3.ZERO,fabric)
 var plane:=PlaneMesh.new();plane.size=Vector2(1.13,.75)
 var contact:=ShaderMaterial.new();contact.shader=preload("res://scripts/art/foot_contact16.gdshader")
 contact_pillow364=shape(craft364,plane,Vector3(-.56,.787,-.91),contact);contact_pillow364.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 for body in row.root.get_children():
  if body is StaticBody3D and body.position.y>.5:
   body.position=Vector3(0.,1.35,-1.37);body.get_child(0).shape.size=Vector3(2.66,1.5,.25)
 apply362()
func paint_material364(file: String,plain: Color) -> ShaderMaterial:
 var m:=ShaderMaterial.new();m.shader=preload("res://scripts/room/painted_part364.gdshader");m.set_shader_parameter("paint",source356("res://assets/room364/"+file));m.set_shader_parameter("plain_color",Vector3(plain.r,plain.g,plain.b));craft_mats364.append(m);return m
func add_piece364(parent: Node3D,mesh: Mesh,at: Vector3,mat: Material) -> MeshInstance3D:
 var n:=shape(parent,mesh,at,mat);n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;return n
func apply362() -> void:
 super.apply362()
 if not is_instance_valid(craft364):return
 craft364.visible=art356 and use_craft364
 layered362.visible=art356 and not use_craft364
 bed360.hide();bed358.hide();contact361.hide()
 for n in foot_contacts363:n.visible=art356 and not use_craft364
 contact362.visible=art356
func set_craft364(value: bool) -> void:
 use_craft364=value;use_layers362=true;apply362()
func toggle_soft359() -> void:set_craft364(not use_craft364)
func set_paint364(value: bool) -> void:
 painted364=value
 for m in craft_mats364:m.set_shader_parameter("show_paint",value)
func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(craft364):return
 var phase:=clampf(inverse_lerp(.42,.70,world.environment.ambient_light_energy),0.,1.)
 support_mat364.albedo_color=Color(.43,.43,.47).lerp(Color("d1c2aa"),phase)
 var tint:=Vector3(.38,.39,.46).lerp(Vector3(.79,.80,.80),phase)
 # Sample the existing bedside lamp as restrained warm fill, never as added emission.
 for lamp in lamps362:
  if not lamp.visible or lamp.light_energy<=0.:continue
  var distance: float=lamp.global_position.distance_to(pillow364.global_position)
  var amount: float=clampf(1.-distance/lamp.omni_range,0.,1.)*lamp.light_energy
  tint+=Vector3(.055,.026,.005)*amount
 for m in craft_mats364:m.set_shader_parameter("room_tint",tint)
