extends "res://scripts/combat/muzzle_reticle28.gd"
func trajectory_target(at: Vector3,origin: Vector3) -> Vector3:
	return battle.resolved_fire_target(at,origin)
