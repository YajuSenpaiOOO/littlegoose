extends "res://scripts/combat/tuantuan124.gd"
# Candidate shove expressions are awaiting the user's choice. Keep the original
# vacant round eyes in game rather than silently selecting another expression.
func _ready() -> void:
 super._ready()
 poses["shove124"]=poses.idle
 textures["shove124"]=textures.idle
