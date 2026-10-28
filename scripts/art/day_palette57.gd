extends "res://scripts/art/day_palette56.gd"

func _init() -> void:
	super._init()
	var dusk := sample(19.)
	dusk.hour=19.
	dusk.elevation56=22.
	dusk.azimuth56=75.
	dusk.shadow_opacity56=0.
	keys.insert(5,dusk)
	# The direction handoff occurs only in the shadowless interval.
	keys[6].elevation56=35.
	keys[6].azimuth56=75.
	keys[6].shadow_opacity56=0.
	var moon := sample(20.5)
	moon.hour=20.5
	moon.elevation56=52.
	moon.azimuth56=-32.
	moon.shadow_opacity56=0.
	keys.insert(7,moon)
