extends "res://scripts/art/rail_corridor72.gd"
var station_mesh73: MeshInstance3D
var rail_span73 := Vector2.ZERO

func _ready() -> void:
	name="ThroughRailAndBrickStation73"
	var surface: RefCounted=world.meadow
	var z: float=surface.rail_z73
	var y: float=surface.rail_level73()
	rail_span73=surface.rail_alignment73
	sleeper_count72=ceili((rail_span73.y-rail_span73.x)/1.2)
	var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side in [-.85,.85]: box72(st,Vector3((rail_span73.x+rail_span73.y)*.5,y+.18,z+side),Vector3(rail_span73.y-rail_span73.x,.14,.09))
	for i in sleeper_count72: box72(st,Vector3(rail_span73.x+(i+.5)*1.2,y+.055,z),Vector3(.18,.10,3.0))
	rail_mesh72=solid72(st,Color(.25,.27,.26),"ContinuousRailAcrossWorld73")
	# Continue real track support beyond the playable edge, so approaching that
	# edge never reveals a rail floating over the scene boundary or a cut end.
	var shoulders := SurfaceTool.new();shoulders.begin(Mesh.PRIMITIVE_TRIANGLES)
	var ballast := SurfaceTool.new();ballast.begin(Mesh.PRIMITIVE_TRIANGLES)
	var bounds: Rect2=surface.world_bounds
	for span in [Vector2(rail_span73.x,bounds.position.x),Vector2(bounds.end.x,rail_span73.y)]:
		var center_x: float=(span.x+span.y)*.5
		box72(shoulders,Vector3(center_x,y*.5,z),Vector3(span.y-span.x,y,20.))
		box72(ballast,Vector3(center_x,y+.018,z),Vector3(span.y-span.x,.03,6.4))
	solid72(shoulders,Color(.34,.42,.29),"RailBackgroundLandBeyondBoundary73")
	solid72(ballast,Color(.32,.33,.31),"RailBackgroundBallast73")
	var frame := SurfaceTool.new(); frame.begin(Mesh.PRIMITIVE_TRIANGLES)
	var portal_x: float=surface.portal_x73
	for side in [-2.45,2.45]: box72(frame,Vector3(portal_x,y+1.65,z+side),Vector3(1.5,3.3,.65))
	box72(frame,Vector3(portal_x,y+3.45,z),Vector3(1.8,.40,5.55))
	portal72=solid72(frame,Color(.42,.43,.40),"WestTunnelMassing73")
	var dark := SurfaceTool.new(); dark.begin(Mesh.PRIMITIVE_TRIANGLES)
	box72(dark,Vector3(portal_x-.35,y+1.5,z),Vector3(.06,3.,4.25))
	solid72(dark,Color(.08,.10,.09),"TunnelDepth73")
	_build_station73()

func _build_station73() -> void:
	var rect: Rect2=world.meadow.station_rect73
	var top: float=world.meadow.STATION_LEVEL73
	var base: float=world.meadow.MAIN72
	var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Top conforms to the same sampled physical surface, including the stair cut.
	for iz in ceili(rect.size.y/.3):
		for ix in ceili(rect.size.x/.3):
			for v in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
				var at: Vector2=rect.position+((Vector2(ix,iz)+v)*.3).min(rect.size)
				st.set_normal(Vector3.UP);st.add_vertex(Vector3(at.x,world.floor_height(at)+.025,at.y))
	var corners := [rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]
	for side in 4:
		var a: Vector2=corners[side];var b: Vector2=corners[(side+1)%4]
		var count := ceili(a.distance_to(b)/.4)
		for i in count:
			var midpoint := a.lerp(b,(i+.5)/count)
			if side==2 and absf(midpoint.x-world.meadow.landmarks.station.x)<2.5: continue
			for v in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
				var at := a.lerp(b,(float(i)+v.x)/count)
				st.set_normal(Vector3((b-a).y,0.,-(b-a).x).normalized())
				st.add_vertex(Vector3(at.x,lerpf(top+.025,base-.02,v.y),at.y))
	# Nine clear treads, carried by a smooth physical ramp.
	var stair := SurfaceTool.new(); stair.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 9:
		var at: Vector2=world.meadow.stair_start73()-Vector2(0,(i+.5)*6.1/9.)
		box72(stair,Vector3(at.x,world.floor_height(at)-.055,at.y),Vector3(4.15,.22,6.1/9.+.02))
		for side in [-1.,1.]:
			var h: float=world.floor_height(at)-base+.2
			box72(stair,Vector3(at.x+side*2.4,base+h*.5,at.y),Vector3(.75,h,6.1/9.+.03))
	station_mesh73=MeshInstance3D.new();station_mesh73.name="BrickStationTerrace73";station_mesh73.mesh=st.commit()
	var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/station_brick73.gdshader")
	station_mesh73.material_override=material;add_child(station_mesh73);world.porch49.shade_material(material)
	var treads := MeshInstance3D.new();treads.name="NineBrickTreads73";treads.mesh=stair.commit();treads.material_override=material;add_child(treads)
	# Three cap pieces leave the stair opening free. The ground below remains
	# low and flat; the structure itself supplies the vertical side and top.
	var body := StaticBody3D.new();body.name="StationBrickFoundationCollision73";body.collision_layer=1;body.collision_mask=0;add_child(body)
	var station: Vector2=world.meadow.landmarks.station
	var caps := [Rect2(rect.position,Vector2(7.2,rect.size.y)),Rect2(Vector2(station.x+2.8,rect.position.y),Vector2(7.2,rect.size.y)),Rect2(Vector2(station.x-2.8,rect.position.y),Vector2(5.6,rect.size.y-.8))]
	for cap in caps:
		var shape := BoxShape3D.new();shape.size=Vector3(cap.size.x,top-base,cap.size.y)
		var collision := CollisionShape3D.new();collision.shape=shape;collision.position=Vector3(cap.get_center().x,(top+base)*.5,cap.get_center().y);body.add_child(collision)
