extends "res://scripts/art/rail_station82.gd"
func _outside_stair_begin83() -> int: return 0
func _build_side_steps75() -> void:
	super._build_side_steps75()
	# Remove only the old curb/wall fragments inside the repaired stair junction.
	var old: MeshInstance3D=get_node("RetainingWallAndOutsideCurb80")
	var arrays: Array=old.mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
	var retained := SurfaceTool.new();retained.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(0,vertices.size(),3):
		var center := (vertices[i]+vertices[i+1]+vertices[i+2])/3.
		if center.x>2.9 and center.x<11.15 and center.z> -47.7: continue
		for j in 3: retained.set_normal(normals[i+j]);retained.add_vertex(vertices[i+j])
	old.hide();finish79(retained,"RetainedMossWall83")
	var s: RefCounted=world.meadow
	var repair := SurfaceTool.new();repair.begin(Mesh.PRIMITIVE_TRIANGLES)
	var base: float=s.LOW72-.10
	# This landing belongs to the continuous upper shelf, not a detached pad.
	var top: float=s.MAIN72+.055
	bevel79(repair,Vector3(3.95,(base+top)*.5,-45.925),Vector3(1.7,top-base,3.35))
	# Back wall returns into both ends of the original retaining wall.
	# Overlap the retained wall by one bevelled block: centroid-based filtering
	# removes a whole old block even when its edge crosses the repair boundary.
	bevel79(repair,Vector3(8.3,(base+top)*.5,-47.35),Vector3(7.,top-base,.50))
	for i in range(_outside_stair_begin83(),9):
		var x: float=10.-(i+.5)*5.2/9.
		var height: float=world.floor_height(Vector2(x,-45.9))+.15
		bevel79(repair,Vector3(x,(base+height)*.5,-44.5),Vector3(5.2/9.+.012,height-base,.5))
	# Flat foot apron replaces the last thin remnant of the blended ramp.
	bevel79(repair,Vector3(10.525,s.LOW72+.005,-45.675),Vector3(1.05,.07,2.85))
	finish79(repair,"MossStairLandingAndReturns83")
	var landing_body := StaticBody3D.new();landing_body.name="LandingFloor83";landing_body.collision_layer=1;landing_body.collision_mask=0
	var landing_shape := CollisionShape3D.new();var box := BoxShape3D.new();box.size=Vector3(1.7,s.MAIN72-base,3.35)
	landing_shape.shape=box;landing_shape.position=Vector3(3.95,(base+s.MAIN72)*.5,-45.925)
	landing_body.add_child(landing_shape);add_child(landing_body)
