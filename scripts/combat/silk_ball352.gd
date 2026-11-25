extends "res://scripts/combat/silk_ball172.gd"
func _physics_process(delta: float) -> void:
 if battle.combat_paused: return
 previous172=position
 if not battle.active114 or battle.player_hp<=0.: battle.remove_silk171(self);return
 if retired171:
  fade171+=delta;_render_legacy(0.)
  if fade171>=UNRAVEL171: battle.remove_silk171(self)
  return
 clock171+=delta
 if clock171>=LIFE171: retire171("timeout");return
 var before := position
 velocity=Vector3(direction171.x*3.8,-.3 if is_on_floor() else velocity.y-20.*delta,direction171.y*3.8)
 move_and_slide();travelled171+=Vector2(position.x-before.x,position.z-before.z).length()
 if is_on_wall(): retire171("wall");return
 if before.distance_to(position)<delta*.10: retire171("blocked");return
 if defense171(before): _render_legacy(0.);return
 var player := Vector2(battle.hero.position.x,battle.hero.position.z)
 var crossed: float=battle.aim_model.sweep_circle(Vector2(before.x,before.z),Vector2(position.x,position.z),player,.70)
 if crossed<INF and absf(position.y-battle.hero.position.y)<.65:
  if battle.hero.can_parry(): retire171("parry")
  else:
   retire171("touch");battle.hurt_player(touch110,Vector2(position.x,position.z))
 _render_legacy(0.)
