extends "res://scripts/combat/tuantuan_minion266.gd"
var flank_goal267 := Vector2.ZERO
var flank_left267 := 0.
var flank_cooldown267 := 0.
var flank_role267 := ""
var flank_forward267 := Vector2.ZERO
var intercept_left267 := 0.
func flanking267() -> bool:
 return flank_left267>0. and not dead and state260=="ground" and attack_phase=="approach" and play_state123=="" and parry_stun<=0.
func stop_flank267(reason: String) -> void:
 if flank_left267<=0.:return
 flank_left267=0.;flank_cooldown267=2.4;path_clock=0.
 if reason=="intercept":intercept_left267=.75
 battle.flank_event267("flank_end",{"actor":role110,"role":flank_role267,"reason":reason})
func assign_flank267(goal: Vector2,role: String) -> void:
 flank_goal267=goal;flank_left267=1.8;flank_role267=role;path_clock=0.
 flank_forward267=battle.heading267
func _pursue110(player: Vector2) -> Vector2:
 return flank_goal267 if flanking267() else super._pursue110(player)
func receive_hit(damage: float,direction: Vector3) -> void:
 if damage>0.:stop_flank267("hit")
 if damage>0.:intercept_left267=0.
 super.receive_hit(damage,direction)
func _physics_process(delta: float) -> void:
 if not battle.combat_paused and battle.active114:
  flank_cooldown267=maxf(0.,flank_cooldown267-delta)
  intercept_left267=maxf(0.,intercept_left267-delta)
  if flank_left267>0.:
   var relative=Vector2(position.x-battle.hero.position.x,position.z-battle.hero.position.z)
   if battle.mode264!="ordinary" or dead or state260!="ground" or parry_stun>0. or play_state123!="":stop_flank267("interrupted")
   elif relative.length()<3.4 and relative.dot(flank_forward267)>.15:stop_flank267("intercept")
   elif Vector2(position.x,position.z).distance_to(flank_goal267)<.85:stop_flank267("arrived")
   elif flank_left267<=delta:stop_flank267("timeout")
   else:flank_left267-=delta
 super._physics_process(delta)
