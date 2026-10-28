extends Resource
## Reusable art direction. Route geometry supplies placement; accents are optional.
@export var route_name := "home_to_junction"
@export var seed_value := 5018
@export_range(4.,18.) var opening_spacing := 8.7
@export var opening_radius := Vector2(3.7,2.6)
@export_range(0.,3.) var lateral_jitter := 1.1
@export_range(3.,18.) var corridor_radius := 9.
@export var shade_multiplier := Vector3(.43,.58,.60)
@export var sun_multiplier := Vector3(1.10,1.035,.89)
@export_range(0.,1.) var actor_response := .55
@export_range(128,512,32) var map_resolution := 320
## World X,Z and radii, for a landmark that needs deliberate emphasis.
@export var accents: Array[Vector4] = []
