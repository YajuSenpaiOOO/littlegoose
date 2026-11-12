extends "res://scripts/combat/paper134.gd"
var entry347:=.9
var dead347:=0.
func paper_contact131(at: Vector2) -> void:battle.hurt_player(1.,at)
func _render_legacy(lift: float) -> void:
 super._render_legacy(lift)
 visual.rotation.x=0.
func _physics_process(delta: float) -> void:
 if battle.combat_paused:return
 if dead:
  dead347+=delta
  super._physics_process(delta)
  if dead347>.9:queue_free()
  return
 if entry347>0.:
  entry347=maxf(0.,entry347-delta)
  hit_area.collision_layer=0;active_ai=false
  _render_legacy(.6+entry347*2.)
  if entry347==0.:play119()
  return
 super._physics_process(delta)
