extends "res://scripts/combat/tuantuan_boss250.gd"
func lock247() -> void:
 if reverse_pending249 or phase247=="pounce":super.lock247();return
 reflected248=false;from247=Vector2(position.x,position.z)
 var player=Vector2(battle.hero.position.x,battle.hero.position.z)
 var velocity=Vector2(battle.hero.velocity.x,battle.hero.velocity.z)
 var lead=(velocity*duration248()*.65).limit_length(1.6)
 var target=player+lead
 var speed=11. if boost248>0 else maxf(6.6,10.-float(jump247)*.55)
 var toward=target-from247
 if toward.length()>.05:forward247=toward.normalized()
 goal247=battle.safe_goal247(from247,from247+toward.limit_length(speed*duration248()))
 flights247.append({"jump":jump247,"from":from247,"goal":goal247,"height":height248(),"duration":duration248(),"reflected":false,"lead":lead,"speed":speed})
 marker247.show();draw_marker247()

func receive_hit(damage: float,direction: Vector3) -> void:
 var before=hp
 super.receive_hit(damage,direction)
 var dealt=maxf(0.,before-maxf(0.,hp))
 if dealt>0.:battle.record_enemy_damage226(self,dealt)
