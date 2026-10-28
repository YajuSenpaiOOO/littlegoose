extends Resource
## Core glow and illumination are separate. A batch can glow without any light.
@export var color := Color("ffc181")
@export var spill_day := 0.
@export var spill_night := 1.
@export var range_day := 3.
@export var range_night := 3.
@export var core_day := 0.
@export var core_night := 1.

