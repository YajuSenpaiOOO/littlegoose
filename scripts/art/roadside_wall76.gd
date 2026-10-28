extends Node3D
## Reusable solid roadside wall: six faces, coping, turns and buried footings.
var world: Node3D
var points: PackedVector2Array=PackedVector2Array([Vector2(-23.,-28.5),Vector2(-29.,-30.1),Vector2(-31.,-32.2)])
var thickness := .60
var height := .80
var wall_mesh76: MeshInstance3D
var block_count76 := 0

func _ready() -> void:
	name="SolidMossRoadsideWall76"
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var body := StaticBody3D.new();body.collision_layer=2;body.collision_mask=0;add_child(body)
	for i in range(1,points.size()):
		var a: Vector2=points[i-1];var b: Vector2=points[i]
		var direction := (b-a).normalized()
		var frame := Basis(Vector3(direction.x,0,direction.y),Vector3.UP,Vector3(-direction.y,0,direction.x))
		var count := ceili(a.distance_to(b)/1.2)
		for j in count:
			var p: Vector2=a.lerp(b,(j+.5)/count)
			var bottom: float=minf(world.floor_height(a.lerp(b,float(j)/count)),world.floor_height(a.lerp(b,float(j+1)/count)))-.16
			var top: float=world.floor_height(p)+height
			var length: float=a.distance_to(b)/count+.025
			var box := BoxMesh.new();box.size=Vector3(length,top-bottom,thickness)
			var pose := Transform3D(frame,Vector3(p.x,(bottom+top)*.5,p.y))
			st.append_from(box,0,pose)
			var cap := BoxMesh.new();cap.size=Vector3(length+.035,.14,thickness+.15)
			st.append_from(cap,0,Transform3D(frame,Vector3(p.x,top+.04,p.y)))
			var footing := BoxMesh.new();footing.size=Vector3(length+.08,.20,thickness+.22)
			st.append_from(footing,0,Transform3D(frame,Vector3(p.x,bottom+.12,p.y)))
			var shape := BoxShape3D.new();shape.size=box.size
			var collision := CollisionShape3D.new();collision.shape=shape;collision.transform=pose;body.add_child(collision)
			block_count76+=1
	# Square piers finish both ends and the turn, rather than exposing cut sheets.
	for p in points:
		var y: float=world.floor_height(p)
		var pier := BoxMesh.new();pier.size=Vector3(thickness+.14,height+.28,thickness+.14)
		st.append_from(pier,0,Transform3D(Basis.IDENTITY,Vector3(p.x,y+height*.5,p.y)))
	wall_mesh76=MeshInstance3D.new();wall_mesh76.mesh=st.commit();add_child(wall_mesh76)
	var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/moss_stone75.gdshader")
	wall_mesh76.material_override=material;world.porch49.shade_material(material)
