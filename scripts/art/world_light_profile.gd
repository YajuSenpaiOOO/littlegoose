extends Resource
## Reusable sky/direct-light parameters. Elevation controls finite ground shadows.
@export var label := "夜晚"
@export var nighttime := true
@export var sky_color := Color("83899f")
@export var direct_color := Color("fff0d5")
@export_range(0.0,1.0) var direct_energy := 0.0
@export_range(-180.0,180.0) var shadow_azimuth_degrees := 35.0
@export_range(5.0,85.0) var elevation_degrees := 45.0
@export_range(0.0,0.5) var shadow_opacity := 0.0
@export var shadow_tint := Color("374461")
@export_range(0.25,1.0) var ground_y_scale := 0.65
@export_range(0.0,1.0) var local_shadow_visibility := 1.0
@export_range(0.0,1.0) var eave_visibility := 1.0
