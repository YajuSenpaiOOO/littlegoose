extends "res://scripts/world/world_surface99.gd"
const ENTRY103=preload("res://scripts/world/park_layout103.gd")
func height_at(x: float,z: float,enabled: bool) -> float:
 var inherited := super.height_at(x,z,enabled)
 if not enabled or landmarks.is_empty(): return inherited
 # Compact additive banks only; no global max against a reference elevation.
 var p := Vector2(x,z)-Vector2(landmarks.grove)
 if p.x<9.5 or p.x>26. or p.y<4.5 or p.y>17.: return inherited
 return inherited+ENTRY103.lift103(p)
