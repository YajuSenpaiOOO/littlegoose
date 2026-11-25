extends "res://scripts/room/cottage420.gd"

var pivot: AnimatableBody3D
var roof_cut: Array[Dictionary]=[]
var front_cut: Array[Dictionary]=[]
var front_lamps: Array[Dictionary]=[]
var finish_cut:=0.0
var door_target:=false
var door_tween: Tween

func _ready() -> void:
 super._ready()
 for node in roof.find_children("*","GeometryInstance3D",true,false):
  register_cut(node,roof_cut)
 for node in shell.get_children():
  if node.has_meta("gable421") or (node is MeshInstance3D and absf(absf(node.position.x)-3.)<.01 and is_equal_approx(node.position.y,3.26)):
   register_cut(node,roof_cut)
   continue
  var front_part: bool=node.has_meta("front421") or node.position.z>1.95
  if not front_part or node==pivot:continue
  if node is MeshInstance3D:
   if node.position.y<=.61 and node.mesh is BoxMesh:continue
   register_cut(node,front_cut)
  else:
   for mesh in node.find_children("*","MeshInstance3D",true,false):register_cut(mesh,front_cut)
   for lamp in node.find_children("*","OmniLight3D",true,false):front_lamps.append({"node":lamp,"energy":lamp.light_energy})
 for lamp in shell.get_children():
  if lamp is OmniLight3D:front_lamps.append({"node":lamp,"energy":lamp.light_energy})
 # Keep the original window sill below the remaining side aperture collision.
 for side in [-1.,1.]:
  block(shell,Vector3(side*4.575,.94,2.1),Vector3(.80,1.7,.22),plaster,true).hide()

func polygon(parent: Node3D,points: PackedVector2Array,z: float,ink: Material) -> void:
 super.polygon(parent,points,z,ink)
 if parent!=shell:return
 var piece:=parent.get_child(parent.get_child_count()-1)
 if z>2.:piece.set_meta("front421",true)
 elif z< -3.7:piece.set_meta("gable421",true)

func build_entry() -> void:
 var start:=shell.get_child_count()
 super.build_entry()
 pivot=AnimatableBody3D.new()
 pivot.name="FrontDoorHinge"
 pivot.position=Vector3(-.91,0,FRONT+.105)
 shell.add_child(pivot)
 var entry_parts:=shell.get_children().slice(start,-1)
 for node in entry_parts:
  if not node is MeshInstance3D:continue
  var at: Vector3=node.position
  var is_leaf: bool=node.mesh is ArrayMesh and node.material_override.albedo_color==Color("896044")
  var is_hardware: bool=absf(at.x)<.74 and at.y>.1 and at.y<1.58 and at.z>FRONT+.11
  if is_leaf or is_hardware:
   node.reparent(pivot)
   register_cut(node,front_cut)
 var shape:=CollisionShape3D.new()
 var leaf:=BoxShape3D.new()
 leaf.size=Vector3(1.80,2.20,.16)
 shape.shape=leaf
 shape.position=Vector3(.91,1.10,0)
 pivot.add_child(shape)
 for stair in terrace.get_children():
  stair.position.y-=.21
  for body in stair.find_children("*","StaticBody3D",true,false):body.collision_layer=0

func register_cut(node: GeometryInstance3D,entries: Array[Dictionary]) -> void:
 var original:=node.material_override as StandardMaterial3D
 if original==null:return
 var ink:=ShaderMaterial.new()
 ink.shader=preload("res://scripts/room/cutaway421.gdshader")
 ink.set_shader_parameter("paint",original.albedo_texture)
 ink.set_shader_parameter("tint",original.albedo_color)
 ink.set_shader_parameter("use_vertex_color",original.vertex_color_use_as_albedo)
 if original.emission_enabled:ink.set_shader_parameter("glow",Vector3(original.emission.r,original.emission.g,original.emission.b)*original.emission_energy_multiplier)
 entries.append({"node":node,"original":original,"ink":ink})

func set_cut(value: float) -> void:
 finish_cut=value
 show_amount(roof_cut,1.-smoothstep(.04,.66,value),2.50,7.36)
 var front_level:=1.-smoothstep(.25,.91,value)
 show_amount(front_cut,front_level,.16,5.25)
 for lamp in front_lamps:lamp.node.light_energy=lamp.energy*front_level

func show_amount(entries: Array[Dictionary],amount: float,base_height: float,top_height: float) -> void:
 for entry in entries:
  entry.node.visible=amount>.002
  if amount>.998:entry.node.material_override=entry.original
  elif amount>.002:
   entry.node.material_override=entry.ink
   entry.ink.set_shader_parameter("cut_height",lerpf(base_height,top_height,amount))

func set_door(value: bool) -> void:
 if value==door_target:return
 door_target=value
 if is_instance_valid(door_tween):door_tween.kill()
 door_tween=create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_trans(Tween.TRANS_SINE)
 door_tween.tween_property(pivot,"rotation:y",deg_to_rad(101.) if value else 0.,.30)
