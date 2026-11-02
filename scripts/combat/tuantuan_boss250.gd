extends "res://scripts/combat/tuantuan_boss249.gd"
func _ready() -> void:
 super._ready();shadow.hide()
func render247() -> void:
 super.render247()
 # The shared silhouette projector is the sole visible shadow source.
 # Keep the legacy contact node only because old pose code still references it.
 if is_instance_valid(shadow):shadow.hide()
