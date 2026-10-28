extends "res://scripts/combat/spider202.gd"
var hit_age203 := 10.
var hit_side203 := 1.
var fluff_gate203 := 0.
var nudge_gate203 := 0.
func _pose(key: String,lift: float) -> void:
 super._pose(key,lift)
 visual.scale=Vector3.ONE
func receive_hit(damage: float,direction: Vector3) -> void:
 if dead: return
 if hit_age203>=.075:
  hit_age203=0.
  hit_side203=signf(direction.dot(battle.camera.global_basis.x))
 super.receive_hit(damage,direction)
 # The inherited feedback budget can skip the contact callback. Visual recoil
 # still applies to every accepted hit; it never changes the action clock.
 _render_legacy(lift170)
func _render_legacy(lift: float) -> void:
 super._render_legacy(lift)
 if not is_instance_valid(visual) or dead: return
 var t := hit_age203
 var amount := .13*(1.-t/.08) if t<.08 else -.045*sin(clampf((t-.08)/.20,0.,1.)*PI)
 if t<.28:
  visual.scale*=Vector3(1.+amount,1.-amount,1.)
  visual.rotation.z+=-hit_side203*.055*exp(-t*15.)
 # Keep the original palette rather than flashing white under warm lamps.
 if flash>0.:
  var shade: Color=battle.combat_tint111.color
  shade.b=minf(shade.b,maxf(shade.r,shade.g)*1.25)
  visual.modulate=shade*Color(1.12,1.07,1.04)
func _physics_process(delta: float) -> void:
 if not battle.combat_paused:
  hit_age203+=delta;fluff_gate203=maxf(0.,fluff_gate203-delta);nudge_gate203=maxf(0.,nudge_gate203-delta)
 super._physics_process(delta)
 if dead or not active_ai or battle.combat_paused or not battle.active114 or nudge_gate203>0.: return
 var difference := Vector2(battle.hero.position.x-position.x,battle.hero.position.z-position.z)
 if difference.length()<.82 and absf(position.y-battle.hero.position.y)<.6:
  if difference.length()<.01: difference=Vector2.RIGHT
  battle.hero.combat_impulse=(battle.hero.combat_impulse+difference.normalized()*.7).limit_length(.9)
  nudge_gate203=.3
