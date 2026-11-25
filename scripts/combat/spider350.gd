extends "res://scripts/combat/spider203.gd"
var entry350:=.8
func _pose(key: String,lift: float) -> void:
 super._pose(key,lift)
 visual.rotation.x=0.
func _physics_process(delta: float) -> void:
 if battle.combat_paused:return
 if not dead and entry350>0.:
  entry350=maxf(0.,entry350-delta)
  hit_area.collision_layer=0;active_ai=false
  _render_legacy(0.)
  if entry350==0.:play119()
  return
 super._physics_process(delta)
