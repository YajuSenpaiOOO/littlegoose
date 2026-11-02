extends "res://scripts/combat/cotton_stream219.gd"
func contact219() -> String:
 if not world.active114 or world.combat_paused:return "inactive"
 if world.hero.dodge_invulnerability>0.:dodge_count+=1;return "dodge"
 if world.hero.can_parry():
  world.parry_success(world.hero.position+Vector3.UP*.5,Vector3.UP);parry_count+=1;return "parry"
 var before: float=world.player_hp
 var guarded: bool=world.hero.guarding109
 world.hurt_player_from(12.,Vector2(pig.position.x,pig.position.z),"cotton")
 if world.player_hp<before:
  hit_count+=1
  if guarded:guard_count+=1
 return "guard" if guarded else "hit"
func _physics_process(delta: float) -> void:
 if world.active114 and not world.combat_paused and is_instance_valid(pig):super._physics_process(delta)
