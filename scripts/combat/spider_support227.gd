extends "res://scripts/combat/spider173.gd"
## One supporting weaver; no extra pounce or old twelve-point silk damage.
func prepare170(_player: Vector2) -> void:
 pad172=battle.place_pad172(self)
 if is_instance_valid(pad172):impulse=Vector2.ZERO;enter170("weave")
 else:enter170("watch");wait170=1.;relocate171=true
