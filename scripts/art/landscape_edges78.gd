extends "res://scripts/art/forest_terrace70.gd"
## Reuse only stone mesh helpers; never build the rejected closed arena.
var forest_stones78 := 0
var shore_stones78 := 0

func _ready() -> void:
	name="NaturalRockShoulders78";center=Vector2.ZERO;rng.seed=780078
	rock=SurfaceTool.new();rock.begin(Mesh.PRIMITIVE_TRIANGLES)
	moss=SurfaceTool.new();moss.begin(Mesh.PRIMITIVE_TRIANGLES)
	for x in [-69.,-65.,-62.,-50.,-46.,-42.,-34.,-30.]:
		var edge: float=world.meadow.upper_front73(x)
		for j in 3:
			var at := Vector2(x+(j-1)*1.2+rng.randf_range(-.3,.3),edge+2.9+rng.randf_range(-.35,.6))
			if not safe78(at): continue
			_boulder(at,rng.randf_range(1.2,2.4),rng.randf_range(.45,.85));forest_stones78+=1
	# Sparse shoreline rock groups reveal the changing bank profile. Not a ring.
	for polygon in [world.meadow.water,world.meadow.island]:
		for i in range(2,polygon.size()-1,8):
			var a: Vector2=polygon[i];var b: Vector2=polygon[i+1]
			var middle := a.lerp(b,.5)
			var side := Vector2(-(b-a).y,(b-a).x).normalized()
			if world.meadow.is_water(middle+side*.7): side=-side
			var at := middle+side*.8
			if at.x>world.meadow.world_bounds.end.x-4. or not safe78(at): continue
			for j in 3:
				var point := at+Vector2(rng.randf_range(-.7,.7),rng.randf_range(-.6,.6))
				if not safe78(point): continue
				_boulder(point,rng.randf_range(.9,2.1),rng.randf_range(.55,1.1));shore_stones78+=1
	rock_mesh=_finish(rock,"HandPaintedNaturalRockGroups78",Color(.85,.91,.82))
	var green := MeshInstance3D.new();green.name="SmallMossCaps78";moss.generate_normals();green.mesh=moss.commit()
	var material := StandardMaterial3D.new();material.albedo_color=Color(.28,.38,.19);material.roughness=1.
	green.material_override=material;add_child(green)
	print("LANDSCAPE78_ROCK_GROUPS forest=",forest_stones78," shore=",shore_stones78)

func safe78(at: Vector2) -> bool:
	var s: RefCounted=world.meadow
	return s.world_bounds.grow(-2.).has_point(at) and not s.is_water(at) and not s.bridge_rect.grow(4.).has_point(at) and at.distance_to(s.landmarks.landing)>5. and s.route_distance(at)>3. and ((at-Vector2(s.landmarks.grove))/s.ROOT_BUFFER76).length()>1.1

func _boulder(at: Vector2,width: float,height: float) -> void:
	# Embed broad stones into a slope rather than balancing their centres on
	# it and leaving the downhill half suspended above the ground.
	var bottom: float=world.floor_height(at)-.10
	for offset in [Vector2(-.35,0),Vector2(.35,0),Vector2(0,-.28),Vector2(0,.28)]:
		var point: Vector2=at+offset*width
		if not world.meadow.is_water(point): bottom=minf(bottom,world.floor_height(point)-.10)
	_stone(Vector3(at.x,bottom+height*.45,at.y),Vector3(width,height,width*.76),rng.randf_range(.88,1.04))
	var body := _obstacle(Vector3(at.x,bottom+height*.45,at.y),Vector3(width*.64,height,width*.52))
	body.name="EmbeddedRockCollision78";boulders70.append(body)
