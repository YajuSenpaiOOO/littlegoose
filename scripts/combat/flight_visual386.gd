extends "res://scripts/combat/flight_visual383.gd"
const Pose=preload("res://scripts/combat/attack_pose386.gd")
var pose386:=Pose.new()
var poses386: Array[Texture2D]=[]
var emitting386:=false
var beam_age386:=100.0
var beam_mode386:=false
var emissions386:=0
func _ready() -> void:
 super._ready()
 for i in 2:poses386.append(atlas381(preload("res://assets/black_goose_attack386/bodies.png"),Rect2(i*512,0,512,1024)))
func fired386(beam: bool) -> void:
 beam_mode386=beam;emissions386+=1
 if beam:beam_age386=0.
 pose386.advance(0.,true,1./maxf(.001,battle.attack_cooldown()),beam,true,false)
 apply_pose386()
 update_shadow380()
func _process(dt: float) -> void:
 if not initialized381:return
 if not battle.combat_paused:
  beam_age386+=dt
  var beam: bool=battle.beam_left110>0. and beam_age386<.2
  var held: bool=trigger_held386() and battle.wave_state=="fighting" and not battle.result_open
  var rate: float=1./maxf(.001,battle.attack_cooldown())
  # Preparation occupies existing charge/cooldown only. It never gates firing.
  # Leave a visible idle interval before preparing the NEXT slow shot. At short
  # intervals do not sneak the removed recovery-ready frame back into the cycle.
  var prep: bool=held and not beam_mode386 and (battle.charge_active or (pose386.since_shot>=.42 and battle.cooldown>0. and battle.cooldown<=.14))
  pose386.advance(dt,beam if beam_mode386 else held,rate,beam_mode386,false,prep)
 super._process(dt)
 if direction381==3:position.z-=pose386.kick
 apply_pose386();update_shadow380()
func trigger_held386() -> bool:return battle.fire_input_held()
func apply_pose386() -> void:
 if poses386.is_empty() or direction381!=3:return
 var active: bool=pose386.phase!="idle"
 body379.texture=poses386[1 if pose386.phase=="release" else 0] if active else front_body381
 body379.pixel_size=1.44/767. if active else 1.44/860.
 body379.offset=Vector2(0,375) if active else Vector2(-25,423)
 body379.material_override.albedo_texture=body379.texture.atlas
func muzzle383() -> Vector3:
 if direction381!=3:return super.muzzle383()
 # Weapon asks synchronously before emission; use the release palm on that call.
 if emitting386 or pose386.phase=="release":return to_global(Vector3((178.-256.)*1.44/767.,(887.-576.)*1.44/767.,.025))
 return super.muzzle383()
