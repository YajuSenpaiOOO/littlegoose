extends "res://scripts/combat/muzzle_reticle28.gd"
var path_ready := false
func trajectory_target(at: Vector3,origin: Vector3) -> Vector3:
	return battle.resolved_fire_target(at,origin)
func update_target(at: Vector3) -> void:
	super.update_target(at)
	path_ready=visible and at.is_finite() and line_origin.distance_to(line_end)>.05
	# The actual collision path remains 3D. Only its presentation is replaced.
	if is_instance_valid(guide_mesh): guide_mesh.hide()
	if is_instance_valid(endpoint): endpoint.hide()
