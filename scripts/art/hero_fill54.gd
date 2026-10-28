extends "res://scripts/art/hero_fill52.gd"

func _ready() -> void:
	fill_gains=Vector3(.30,.17,.045)
	fill_minimum=.16
	fill_energy=.48
	fill_range=2.
	super._ready()

func set_presence(stronger: bool) -> void:
	fill_gains=Vector3(.30,.17,.045) if stronger else Vector3(.13,.065,.012)
	fill_minimum=.16 if stronger else 0.
	fill_energy=.48 if stronger else .12
	fill_range=2. if stronger else 1.45
	if is_instance_valid(warm_light): warm_light.omni_range=fill_range
	set_fill(fill_enabled)
