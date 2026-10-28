extends Node3D
## Default home for 3D projectile visuals. Sprites/standard materials enroll on birth;
## custom shaders consume world_effect_grade159.gdshaderinc without per-shot updates.
var battle: Node3D
var sprites159: Array[Dictionary]=[]
var materials159: Array[Dictionary]=[]
var enrolled159 := {}
var tint159 := Color.WHITE
func _ready() -> void:
 name="CombatWorldEffects159";process_priority=110
 get_tree().node_added.connect(_added159)
func _added159(node: Node) -> void:
 if is_ancestor_of(node) and node is GeometryInstance3D: _register159.call_deferred(weakref(node))
func _register159(reference: WeakRef) -> void:
 var node: Variant=reference.get_ref()
 if not is_instance_valid(node) or enrolled159.has(node.get_instance_id()) or node.get_meta("environment_grade159",true)==false: return
 var id: int=node.get_instance_id();enrolled159[id]=reference
 if node is Sprite3D:
  var color: Color=node.modulate
  var entry := {"node":reference,"base":Color(color,1.),"last":Color(color,1.)}
  sprites159.append(entry);node.modulate=apply159(entry,color)
 elif node is MeshInstance3D:
  var material: Material=node.material_override
  if material is ShaderMaterial: return
  if material==null and node.mesh!=null and node.mesh.get_surface_count()>0: material=node.mesh.surface_get_material(0)
  if material is ShaderMaterial: return
  if material==null: material=StandardMaterial3D.new()
  if material is BaseMaterial3D:
   var owned: BaseMaterial3D=material.duplicate();node.material_override=owned
   var color: Color=owned.albedo_color
   var entry := {"node":reference,"material":owned,"base":Color(color,1.),"last":Color(color,1.)}
   materials159.append(entry);owned.albedo_color=apply159(entry,color)
func changed159(a: Color,b: Color) -> bool:
 return absf(a.r-b.r)+absf(a.g-b.g)+absf(a.b-b.b)>.0001
func apply159(entry: Dictionary,color: Color) -> Color:
 if changed159(color,entry.last): entry.base=Color(color,1.)
 var base: Color=entry.base
 var result := Color(base.r*tint159.r,base.g*tint159.g,base.b*tint159.b,color.a)
 entry.last=Color(result,1.);return result
func _process(_delta: float) -> void:
 if is_instance_valid(battle.combat_tint111): tint159=battle.combat_tint111.color
 RenderingServer.global_shader_parameter_set("combat_world_tint159",tint159)
 for i in range(sprites159.size()-1,-1,-1):
  var entry: Dictionary=sprites159[i];var node: Variant=entry.node.get_ref()
  if not is_instance_valid(node): sprites159.remove_at(i);continue
  node.modulate=apply159(entry,node.modulate)
 for i in range(materials159.size()-1,-1,-1):
  var entry: Dictionary=materials159[i];var node: Variant=entry.node.get_ref()
  if not is_instance_valid(node): materials159.remove_at(i);continue
  entry.material.albedo_color=apply159(entry,entry.material.albedo_color)
 for id in enrolled159.keys():
  if not is_instance_valid(enrolled159[id].get_ref()): enrolled159.erase(id)
