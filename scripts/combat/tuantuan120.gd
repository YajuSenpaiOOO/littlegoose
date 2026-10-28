extends "res://scripts/combat/tuantuan119.gd"
func receive_hit(damage: float,direction: Vector3) -> void:
 var was_dead := dead
 super.receive_hit(damage,direction)
 if not was_dead and dead: battle.defeat_drop120(self)
 if dead: set_physics_process(false)
