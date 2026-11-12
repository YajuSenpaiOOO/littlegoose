extends "res://scripts/combat/paper_card304.gd"
var tracking305 := false
func launch_speed304() -> float:
 var player=Vector2(battle.hero.position.x,battle.hero.position.z)
 ring_limit304=7.
 return clampf(player.distance_to(Vector2(position.x,position.z))*7.5,23.,42.)
func _physics_process(delta: float) -> void:
 tracking305=false
 if ready303 and not dead and not battle.combat_paused and battle.active114:
  if kind301=="knight" and state301=="warn" and clock301<1.15 and uses_legacy_aim305():
   var target=Vector2(battle.hero.position.x,battle.hero.position.z)+Vector2(battle.hero.velocity.x,battle.hero.velocity.z).limit_length(4.)*.16
   var desired=(target-Vector2(position.x,position.z)).normalized()
   if desired.length()>.01:direction301=direction301.rotated(clampf(direction301.angle_to(desired),-delta*4.,delta*4.)).normalized()
   lane_start303=attack_at301();lane_end303=lane_start303+direction301*minf(7.,target.distance_to(lane_start303)+.5)
   tracking305=true
 super._physics_process(delta)
func uses_legacy_aim305() -> bool:return true
func move301(motion: Vector2,delta: float) -> void:
 if ready303 and not dead:
  var player=Vector2(battle.hero.position.x,battle.hero.position.z);var at=Vector2(position.x,position.z)
  if kind301=="monster" and state301 in ["warn","attack"]:
   if tracks_monster305():
    var lead=Vector2(battle.hero.velocity.x,battle.hero.velocity.z).limit_length(4.)*.16
    motion=(battle.paper_clamp301(player+lead)-at).limit_length(1.)*4.
    locked301=battle.paper_clamp301(player+lead);tracking305=true
   else:motion=Vector2.ZERO
  if kind301=="dinosaur" and state301 in ["warn","attack"]:
   motion=dinosaur_motion305(player,at)
   tracking305=true
 super.move301(motion,delta)


func tracks_monster305() -> bool:
 return not (height303 < .55 and vertical303 < -1.6)

func dinosaur_motion305(player: Vector2, at: Vector2) -> Vector2:
 # Translate the upright fire sheet instead of pitching it toward camera.
 var side := 1. if direction301.x >= 0. else -1.
 var desired := player - Vector2(side * 2.8, 0.)
 return (Vector2(battle.paper_clamp301(desired)) - at).limit_length(1.) * 2.8
