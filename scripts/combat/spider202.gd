extends "res://scripts/combat/spider173.gd"
func _render_legacy(lift: float) -> void:
 super._render_legacy(lift)
 # Pose resets modulate each frame, retaining the hit flash before this tint.
 # Spider sprites currently use environmental grading, not native tree shadows.
 if is_instance_valid(visual) and is_instance_valid(battle) and is_instance_valid(battle.combat_tint111):
  var shade: Color=battle.combat_tint111.color
  shade.b=minf(shade.b,maxf(shade.r,shade.g)*1.25)
  visual.modulate*=shade
