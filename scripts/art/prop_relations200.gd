extends "res://scripts/art/prop_relations199.gd"
func in_sight_lane199(_point: Vector2) -> bool: return false
var extras200: Array=[]
var shadow_map200 := {}
var alpha_cache200 := {}
func _ready() -> void:
 super._ready();process_priority=200
func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(world.whole67): return
 var art: Node3D=world.forest188
 # The per-frame relations pass only has to run when something observable
 # changed: extra200 membership is static, so bind it once; fade uploads are
 # gated on the actual alpha value, and sprite->shadow pairs are a map.
 if extras200.is_empty() and not world.whole67.entries.is_empty():
  for entry in world.whole67.entries.values():
   if entry.get("extra200",false): extras200.append(entry)
  for shadow in art.prop_shadows182:
   var visual: Node=shadow.get("visual")
   if visual==null: continue
   var visual_id: int=visual.get_instance_id()
   if not shadow_map200.has(visual_id): shadow_map200[visual_id]=[]
   shadow_map200[visual_id].append(shadow)
 for entry in extras200:
  var alpha: float=smoothstep(0.,1.,entry.opacity)
  var key: int=entry.sprite.get_instance_id()
  if absf(alpha-float(alpha_cache200.get(key,-1.)))<.0005: continue
  alpha_cache200[key]=alpha
  entry.sprite.material_override.set_shader_parameter("fade",sqrt(alpha))
  if entry.sprite==art.stage_tree185:
   art.grounded187[0].material_override.set_shader_parameter("fade",sqrt(alpha))
  for shadow in shadow_map200.get(key,[]):
   if is_instance_valid(shadow) and shadow.get("ink") is ShaderMaterial:
    shadow.ink.set_shader_parameter("opacity",.20*alpha)
