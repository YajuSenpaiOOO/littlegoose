extends "res://scripts/combat/tuantuan_minion266.gd"
var flower268 := false
var bloom268: Sprite3D
var predicted268 := Vector2.ZERO
func _ready() -> void:
 flower268=battle.flower_next268 and battle.mode264=="ordinary"
 if flower268:compose_flower270("elite")
 super._ready()
func compose_flower270(kind: String) -> void:
 var combined=preload("res://scripts/art/flower_composite270.gd").build(poses,textures,kind)
 poses=combined.poses;textures=combined.textures
func prediction268(target: Vector2) -> Vector2:
 var motion=Vector2(battle.hero.velocity.x,battle.hero.velocity.z)
 return battle.safe_goal247(Vector2(position.x,position.z),target+(motion*.6).limit_length(2.4))
func _begin_windup(target: Vector2) -> void:
 if flower268:predicted268=prediction268(target)
 super._begin_windup(predicted268 if flower268 else target)
 if flower268:
  battle.flower_stats268.predictions+=1
  battle.telemetry260.event("flower_prediction",{"actor":role110,"goal":[predicted268.x,predicted268.y]})
func _update_windup_target(target: Vector2) -> void:
 if not flower268:super._update_windup_target(target);return
 # Watch briefly, then commit for the remaining anticipation and the whole flight.
 if phase_clock<.18:predicted268=prediction268(target)
 super._update_windup_target(predicted268)
func _render_legacy(lift: float) -> void:
 super._render_legacy(lift)
 if flower268 and attack_phase=="windup" and not dead:
  visual.scale*=Vector3(1.07,.90,1.)
