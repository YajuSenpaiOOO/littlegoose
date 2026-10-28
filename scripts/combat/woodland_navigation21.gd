extends RefCounted
## Small local grid for this combat trial; collision remains authoritative.
var grid := AStarGrid2D.new()
var origin := Vector2.ZERO
const CELL := .75

func grid_half_extent21() -> Vector2i: return Vector2i(28,24)

func bake(space: PhysicsDirectSpaceState3D,surface: RefCounted,center: Vector2) -> void:
	var half := grid_half_extent21()
	origin = center-Vector2(half)*CELL
	grid.region = Rect2i(Vector2i.ZERO,half*2+Vector2i.ONE)
	grid.cell_size = Vector2.ONE*CELL
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.update()
	var sphere := SphereShape3D.new()
	sphere.radius = .62
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = sphere
	query.collision_mask = 2
	for y in grid.region.size.y:
		for x in grid.region.size.x:
			var at := origin+Vector2(x,y)*CELL
			query.transform = Transform3D(Basis.IDENTITY,Vector3(at.x,surface.walk_height(at,true)+.65,at.y))
			grid.set_point_solid(Vector2i(x,y),not space.intersect_shape(query,1).is_empty())

func nearest(at: Vector2) -> Vector2i:
	var p := Vector2i(((at-origin)/CELL).round())
	p.x = clampi(p.x,0,grid.region.size.x-1)
	p.y = clampi(p.y,0,grid.region.size.y-1)
	if not grid.is_point_solid(p): return p
	for radius in range(1,7):
		var best := Vector2i(-1,-1)
		var distance := INF
		for y in range(-radius,radius+1):
			for x in range(-radius,radius+1):
				var candidate := p+Vector2i(x,y)
				if not grid.region.has_point(candidate) or grid.is_point_solid(candidate): continue
				var d := (origin+Vector2(candidate)*CELL).distance_squared_to(at)
				if d<distance: best=candidate; distance=d
		if best.x>=0: return best
	return p

func path(from: Vector2,to: Vector2) -> PackedVector2Array:
	var result := PackedVector2Array()
	var start := nearest(from)
	var goal := nearest(to)
	if grid.is_point_solid(start) or grid.is_point_solid(goal): return result
	for id in grid.get_id_path(start,goal,true): result.append(origin+Vector2(id)*CELL)
	return result
