extends "res://scripts/art/day_fill55.gd"
var stage_strength57 := 0.

func _update_actor() -> void:
	super._update_actor()
	# The actor uses painted sprite shading. Give it the same gentle warm cue
	# as the ground under the spotlight, preserving damage/dodge feedback.
	world.hero.visual.modulate*=Color(1.+stage_strength57*.20,1.+stage_strength57*.10,1.+stage_strength57*.015)
