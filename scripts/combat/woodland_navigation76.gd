extends "res://scripts/combat/woodland_navigation72.gd"
var outside_cells76 := 0
func grid_half_extent21() -> Vector2i: return Vector2i(42,42)

func bake(space: PhysicsDirectSpaceState3D,surface: RefCounted,center: Vector2) -> void:
	super.bake(space,surface,center)
	outside_cells76=0
	var playable: Rect2=surface.world_bounds.grow(-.75)
	for y in grid.region.size.y:
		for x in grid.region.size.x:
			var at := origin+Vector2(x,y)*CELL
			if not playable.has_point(at) or surface.is_water(at):
				grid.set_point_solid(Vector2i(x,y),true);outside_cells76+=1
