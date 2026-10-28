extends "res://scripts/combat/goose110.gd"
var index168 := 0
var follow168=preload("res://scripts/combat/float_follow162.gd").new()
func update_follow(delta: float,target: Vector3,snap := false) -> void:
 if battle.combat_paused and not snap: return
 var wanted: Vector3=battle.skills110.position_for168(index168)
 if snap: follow168.reset()
 var dt := 0. if battle.combat_paused else delta
 position=follow168.advance(wanted,dt,17.)
 position.y=battle.floor_height(Vector2(position.x,position.z))+.43
 age+=dt;spring_velocity*=exp(-dt*9.)
 _remember_direction(target)
 _update_follow_visual(position+last_shot_direction*2.,snap);_update_wing_pose(dt,target)
 if not snap: step_contact()
