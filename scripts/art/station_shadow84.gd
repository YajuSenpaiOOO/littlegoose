extends "res://scripts/art/grounded_prop_shadow63.gd"
func update_shadow() -> void:
	# Build in the original local frame, then lift onto the paved receiver.
	position.y=0.;super.update_shadow();position.y=.04
