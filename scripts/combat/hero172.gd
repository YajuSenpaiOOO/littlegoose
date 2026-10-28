extends "res://scripts/combat/hero146.gd"
var web_left172 := 0.
func movement_speed() -> float:
 return super.movement_speed()*(web_speed172() if web_left172>0. and dash_left<=0. else 1.)
func web_speed172() -> float: return .75
func clear_web172() -> void: web_left172=0.
func reset_actions() -> void:
 web_left172=0.;super.reset_actions()
func _physics_process(delta: float) -> void:
 if not battle.combat_paused:
  web_left172=maxf(0.,web_left172-delta)
  if not battle.active114: web_left172=0.
  elif dash_left<=0. and battle.on_web172(position): web_left172=.30
 var before := position;var was_dash := dash_left>0.;var count := dash_count
 super._physics_process(delta)
 if battle.combat_paused or not dash_eligible or not (was_dash or dash_count!=count): return
 for ball in battle.silk171:
  if not is_instance_valid(ball) or ball.dead or ball.dodged172 or absf(ball.position.y-position.y)>.65: continue
  var start := Vector2(before.x-ball.previous172.x,before.z-ball.previous172.z)
  var end := Vector2(position.x-ball.position.x,position.z-ball.position.z)
  if battle.aim_model.sweep_circle(start,end,Vector2.ZERO,1.05)<INF:
   dash_eligible=false;ball.dodged172=true;web_left172=0.;battle.perfect_dodge();break
