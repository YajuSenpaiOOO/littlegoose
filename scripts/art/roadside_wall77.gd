extends "res://scripts/art/roadside_wall76.gd"

func _ready() -> void:
	name="PaintedWornStoneWall77"
	var line: PackedVector2Array=world.meadow._smooth(points)
	var stations := PackedVector2Array([line[0]])
	for i in range(1,line.size()):
		var count := maxi(1,ceili(line[i-1].distance_to(line[i])/.62))
		for j in range(1,count+1): stations.append(line[i-1].lerp(line[i],float(j)/count))
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rings: Array[PackedVector3Array]=[]
	var body := StaticBody3D.new();body.collision_layer=2;body.collision_mask=0;add_child(body)
	for i in stations.size():
		var p: Vector2=stations[i]
		var tangent: Vector2=(stations[mini(i+1,stations.size()-1)]-stations[maxi(i-1,0)]).normalized()
		var crosswise := Vector2(-tangent.y,tangent.x)
		var width: float=thickness*.5*(1.+.045*sin(i*1.7))
		var bottom: float=world.floor_height(p)-.15
		var top: float=world.floor_height(p)+height+.035*sin(i*1.43)
		var bevel := .085
		var section := PackedVector2Array([Vector2(-width+bevel,bottom),Vector2(width-bevel,bottom),Vector2(width,bottom+bevel),Vector2(width,top-bevel),Vector2(width-bevel,top),Vector2(-width+bevel,top),Vector2(-width,top-bevel),Vector2(-width,bottom+bevel)])
		var ring := PackedVector3Array()
		for v in section: ring.append(Vector3(p.x+crosswise.x*v.x,v.y,p.y+crosswise.y*v.x))
		rings.append(ring)
		if i==0: continue
		var a: Vector2=stations[i-1];var b: Vector2=stations[i]
		var center := a.lerp(b,.5)
		var direction := (b-a).normalized()
		var frame := Basis(Vector3(direction.x,0,direction.y),Vector3.UP,Vector3(-direction.y,0,direction.x))
		var shape := BoxShape3D.new();shape.size=Vector3(a.distance_to(b)+.025,height+.15,thickness-.08)
		var collision := CollisionShape3D.new();collision.shape=shape
		collision.transform=Transform3D(frame,Vector3(center.x,world.floor_height(center)+height*.5-.03,center.y));body.add_child(collision)
		block_count76+=1
	for i in range(1,rings.size()):
		for j in 8:
			var next := (j+1)%8
			quad77(st,rings[i-1][j],rings[i][j],rings[i][next],rings[i-1][next])
	for index in [0,rings.size()-1]:
		var ring: PackedVector3Array=rings[index]
		var center := Vector3.ZERO
		for vertex in ring: center+=vertex/8.
		for j in 8:
			if index==0: triangle77(st,center,ring[j],ring[(j+1)%8])
			else: triangle77(st,center,ring[(j+1)%8],ring[j])
	wall_mesh76=MeshInstance3D.new();wall_mesh76.mesh=st.commit();add_child(wall_mesh76)
	var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/painted_wall77.gdshader")
	material.set_shader_parameter("stone_paint77",load("res://assets/wall77/painted_moss_stone77.png"))
	wall_mesh76.material_override=material;world.porch49.shade_material(material)

func triangle77(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3) -> void:
	var normal := (b-a).cross(c-a).normalized()
	st.set_normal(normal)
	for point in [a,b,c]: st.add_vertex(point)

func quad77(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3,d: Vector3) -> void:
	triangle77(st,a,b,c);triangle77(st,a,c,d)
