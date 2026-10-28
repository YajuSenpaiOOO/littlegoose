extends Node2D
## Independently editable road/paving geometry sampling real pixel ground materials.
var paving_outline := PackedVector2Array()
var soil_paths: Array[PackedVector2Array] = []
var rng := RandomNumberGenerator.new()
var ground_material: ShaderMaterial
var paving_material: ShaderMaterial

func _ready() -> void:
	rng.seed = 161001
	var plan: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://docs/courtyard-route-reservations.json"))
	var path := PackedVector2Array()
	for point in plan.centerline: path.append(Vector2(point[0],point[1]))
	path.insert(0,Vector2(28,12))
	path.append(Vector2(300,-260))
	_lane(path,float(plan.corridor_width))
	_lane(PackedVector2Array([Vector2(-91,12),Vector2(-78,69),Vector2(-70,108),Vector2(28,119)]),31)
	_lane(PackedVector2Array([Vector2(28,84),Vector2(65,63),Vector2(92,38)]),25)
	paving_outline = PackedVector2Array([Vector2(-105,-7),Vector2(-25,-9),Vector2(48,-8),Vector2(64,15),Vector2(55,39),Vector2(66,65),Vector2(47,92),Vector2(48,110),Vector2(25,131),Vector2(7,118),Vector2(-19,120),Vector2(-40,104),Vector2(-76,106),Vector2(-99,86),Vector2(-103,55),Vector2(-113,29)])
	paving_material = _surface(paving_outline,true,-6)
	# The lower approach has a few irregular islands of the same actual stonework.
	for at in [Vector2(27,147),Vector2(30,168),Vector2(23,190)]:
		var island := PackedVector2Array([Vector2(-7,-5),Vector2(5,-6),Vector2(9,-1),Vector2(6,5),Vector2(-4,6),Vector2(-8,2)])
		for i in island.size(): island[i]+=at
		_surface(island,true,-6,1.5)

func _lane(points: PackedVector2Array,width: float) -> void:
	var curve := Curve2D.new()
	for i in points.size():
		var tangent := Vector2.ZERO
		if i>0 and i<points.size()-1:
			tangent = (points[i+1]-points[i-1]).normalized()*minf(24,minf(points[i].distance_to(points[i-1]),points[i].distance_to(points[i+1]))*0.25)
		curve.add_point(points[i],-tangent,tangent)
	var line := curve.tessellate(4,5)
	var outlines := Geometry2D.offset_polyline(line,width*0.5+2.5,Geometry2D.JOIN_ROUND,Geometry2D.END_ROUND)
	for outline in outlines:
		var broken := PackedVector2Array()
		for i in outline.size():
			var a := outline[i]
			var b := outline[(i+1)%outline.size()]
			var count := maxi(1,ceili(a.distance_to(b)/9.0))
			for j in count:
				var at := a.lerp(b,float(j)/count)
				if j>0: at+=(b-a).normalized().orthogonal()*rng.randf_range(-2.2,2.2)
				broken.append(at.snapped(Vector2.ONE))
		soil_paths.append(broken)
		ground_material = _surface(broken,false,-7)

func _surface(points: PackedVector2Array,paving: bool,layer: int,feather := 5.5) -> ShaderMaterial:
	var poly := Polygon2D.new()
	poly.name = "WornFlagstone" if paving else "TexturedEarth"
	poly.polygon = points
	poly.z_index = layer
	var material := ShaderMaterial.new()
	material.shader = preload("res://scripts/art/courtyard_ground_material.gdshader")
	material.set_shader_parameter("material_atlas",preload("res://assets/courtyard_v1/ground_materials_v2.png"))
	material.set_shader_parameter("paving",paving)
	material.set_shader_parameter("repeat_size",Vector2(90,180) if paving else Vector2(125,250))
	material.set_shader_parameter("tint",Vector3(0.98,1.0,0.96) if paving else Vector3(0.90,0.93,0.90))
	material.set_shader_parameter("shoulder",feather)
	# Decimate only the shader's distance contour; visible geometry retains its
	# fine broken edge. Distances are evaluated once per ground fragment.
	var outline := PackedVector2Array()
	var count := mini(64,points.size())
	for i in count: outline.append(points[floori(float(i)*points.size()/count)])
	for i in range(count,64): outline.append(Vector2.ZERO)
	material.set_shader_parameter("edge_points",outline)
	material.set_shader_parameter("edge_count",count)
	poly.material = material
	add_child(poly)
	return material

func on_dirt(at: Vector2) -> bool:
	for shape in soil_paths:
		if Geometry2D.is_point_in_polygon(at,shape): return true
	return Geometry2D.is_point_in_polygon(at,paving_outline)
