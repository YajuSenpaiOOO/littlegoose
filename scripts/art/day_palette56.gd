extends "res://scripts/art/day_palette55.gd"

func _init() -> void:
	keys=keys.duplicate(true)
	var angles := [Vector2(28.,-65.),Vector2(35.,-55.),Vector2(68.,-5.),Vector2(40.,40.),Vector2(26.,65.),Vector2(42.,15.),Vector2(52.,-32.),Vector2(52.,-32.)]
	for i in keys.size():
		keys[i].elevation56=angles[i].x
		keys[i].azimuth56=angles[i].y
		keys[i].shadow_opacity56=1. if i<5 else [.55,.28,.25][i-5]
	keys[3].air=.36
	keys[4].air=.36
	keys[4].shadow_opacity56=.85
	# A luminous blue woodland, with visible surfaces between the warm pools.
	for i in [5,6,7]:
		keys[i].sun=Color("b4cbff")
		keys[i].energy=.25 if i==5 else .22
		keys[i].ambient=Color("9ab9ff")
		keys[i].air=.46 if i==5 else .43
		keys[i].fog=Color("799bd2") if i==5 else Color("698dc8")
		keys[i].shadow=Vector3(.62,.88,1.55)
		keys[i].highlight=Vector3(.70,.90,1.35)
		keys[i].exposure=.90 if i==5 else .87
		keys[i].saturation=.74
