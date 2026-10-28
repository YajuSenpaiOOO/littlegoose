extends "res://scripts/combat/goose29.gd"
var formation110 := Vector3.ZERO
var updating110 := false
func update_follow(delta: float,target: Vector3,snap := false) -> void:
 updating110=true
 super.update_follow(delta,target,snap)
 updating110=false;position+=formation110
 position.y=battle.floor_height(Vector2(position.x,position.z))+.43
 if not snap: step_contact()
func step_contact() -> void:
 if updating110: return
 battle.contact_emitter110=self
 super.step_contact()
 battle.contact_emitter110=null
