extends "res://scripts/combat/cotton_stream220.gd"
func contact219() -> String:
 if not world.active114 or world.combat_paused:return "inactive"
 if world.hero.dodge_invulnerability>0.:dodge_count+=1;return "dodge"
 if world.hero.can_parry():world.parry_success(world.hero.position+Vector3.UP*.5,Vector3.UP);parry_count+=1;return "parry"
 var hp: float=world.player_hp
 world.hurt_player(1.,Vector2(pig.global_position.x,pig.global_position.z))
 if world.player_hp<hp:hit_count+=1
 return "hit"
