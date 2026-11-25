extends "res://scripts/art/memory_workshop117.gd"

func near() -> bool:
 if not is_instance_valid(world.workshop_shed432):return false
 var at: Vector3=world.workshop_shed432.to_local(world.hero.global_position)
 return absf(at.x)<.97 and at.z>-.12 and at.z<1.32
