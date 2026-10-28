extends "res://scripts/art/prop_relations199.gd"
func in_sight_lane199(_point: Vector2) -> bool: return false
func _ready() -> void:
 super._ready();process_priority=200
func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(world.whole67): return
 var art: Node3D=world.forest188
 for entry in world.whole67.entries.values():
  if not entry.get("extra200",false): continue
  var alpha: float=smoothstep(0.,1.,entry.opacity)
  entry.sprite.material_override.set_shader_parameter("fade",sqrt(alpha))
  if entry.sprite==art.stage_tree185:
   art.grounded187[0].material_override.set_shader_parameter("fade",sqrt(alpha))
  for shadow in art.prop_shadows182:
   if is_instance_valid(shadow) and shadow.get("visual")==entry.sprite and shadow.get("ink") is ShaderMaterial:
    shadow.ink.set_shader_parameter("opacity",.20*alpha)
