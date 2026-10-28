extends "res://scripts/combat/woodland_navigation21.gd"
var steep_cells72 := 0
func bake(space: PhysicsDirectSpaceState3D,surface: RefCounted,center: Vector2) -> void:
	super.bake(space,surface,center)
	steep_cells72=0
	for y in grid.region.size.y:
		for x in grid.region.size.x:
			var at := origin+Vector2(x,y)*CELL
			if surface.normal_at(at.x,at.y,true).y<.79:
				grid.set_point_solid(Vector2i(x,y),true); steep_cells72+=1
