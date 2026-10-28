extends "res://scripts/combat/hero128.gd"
var stair_visual142 := 0.
func _physics_process(delta: float) -> void:
 if is_instance_valid(visual): visual.position.y-=stair_visual142
 super._physics_process(delta)
 stair_visual142=0.
 if not is_instance_valid(battle) or not is_instance_valid(battle.park99) or not is_on_floor(): return
 var support: float=battle.park99.visual_support142(Vector2(position.x,position.z))
 if is_finite(support): stair_visual142=clampf(support-position.y+.008,0.,.24)
 visual.position.y+=stair_visual142
