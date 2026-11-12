extends "res://scripts/combat/tuantuan_roller269.gd"
var bump_left271 := 0.
var bump_motion271 := Vector2.ZERO
func bump271(away: Vector2) -> void:
 enter269("dizzy");bump_left271=.18;bump_motion271=away*4.;impulse=Vector2.ZERO;battle.roller_stats269.stuns+=1
func actor_contact271(actor: Object,normal: Vector2) -> bool:
 return battle.actor_collision271(self,actor,normal)
func _physics_process(delta: float) -> void:
 if dead or bump_left271<=0.:super._physics_process(delta);return
 if battle.combat_paused or not battle.active114:return
 bump_left271=maxf(0.,bump_left271-delta);_step_response121(delta)
 velocity=Vector3(bump_motion271.x,-.3 if is_on_floor() else velocity.y-20.*delta,bump_motion271.y);move_and_slide();bump_motion271*=maxf(0.,1.-delta*9.);_render_legacy(0.);shadow.hide()
