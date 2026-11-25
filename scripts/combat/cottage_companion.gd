extends "res://scripts/combat/goose_follow423.gd"

func navigation_size373() -> Vector2i:
 return Vector2i(44,49)

func navigation_offset373() -> Vector2:
 return super.navigation_offset373()+Vector2(host.global_position.x,host.global_position.z)

func navigation_height373(at: Vector2) -> float:
 return host.world.floor_height(at)

func navigation_floor_bodies373() -> Array[RID]:
 # These surfaces are passable using the physical step-up, even where
 # the navigation capsule overlaps the next riser from the lower tread.
 var bodies: Array[RID]=[host.approach_body.get_rid()]
 for step in host.house.step_bodies:
  bodies.append(step.get_rid())
 return bodies
