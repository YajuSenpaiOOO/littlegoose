extends "res://scripts/combat/balloon_contact158.gd"
const SPIDER203=preload("res://scripts/combat/spider203.gd")
func pop158(at: Vector3,direction: Vector3,key: int,gain := 1.) -> bool:
 var actor: Object=instance_from_id(key) if is_instance_id_valid(key) else null
 if not actor is SPIDER203: return super.pop158(at,direction,key,gain)
 if age158<float(gates158.get(key,-1.)): return false
 gates158[key]=age158+.11
 if is_instance_valid(battle.fluff203) and actor.fluff_gate203<=0.:
  battle.fluff203.burst(at,direction,actor.dead);actor.fluff_gate203=.11
 if not voices158.is_empty():
  var voice: AudioStreamPlayer3D=voices158[voice158%voices158.size()];voice158+=1;voice.position=at;voice.play()
 return true
