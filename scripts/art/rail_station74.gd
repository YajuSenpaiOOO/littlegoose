extends "res://scripts/art/rail_station73.gd"

func _build_station73() -> void:
	var surface: RefCounted=world.meadow
	var rect: Rect2=surface.station_rect73
	# Railway ballast stays exposed; the plaza paving meets its near shoulder.
	var rear: float=surface.rail_z73+3.2
	rect=Rect2(Vector2(rect.position.x,rear),Vector2(rect.size.x,rect.end.y-rear))
	var top: float=surface.STATION_LEVEL73
	var base: float=surface.MAIN72
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# A thin paved surface follows the real continuous terrain. No back/side box.
	for iz in ceili(rect.size.y/.4):
		for ix in ceili(rect.size.x/.4):
			for v in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
				var at: Vector2=rect.position+((Vector2(ix,iz)+v)*.4).min(rect.size)
				if at.y>surface.station_front74(at.x)+.2: at.y=surface.station_front74(at.x)+.2
				var pave_y: float=world.floor_height(at)+.035 if absf(at.x-surface.landmarks.station.x)<3.2 and at.y>surface.station_front74(at.x)-.9 else top+.035
				st.set_normal(Vector3.UP);st.add_vertex(Vector3(at.x,pave_y,at.y))
	# Retaining wall is only the downslope front, and grades into natural ground
	# at each end. Terrain continues north behind it and sideways past the paving.
	var station: Vector2=surface.landmarks.station
	for i in 120:
		var x: float=lerpf(station.x-24.,station.x+27.,float(i)/120.)
		if absf(x-station.x)<3.25: continue
		var end_x: float=lerpf(station.x-24.,station.x+27.,float(i+1)/120.)
		var weight := smoothstep(station.x-24.,station.x-19.,x)*(1.-smoothstep(station.x+20.,station.x+27.,x))
		for v in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
			var vx: float=lerpf(x,end_x,v.x)
			var vz: float=surface.station_front74(vx)+.2
			st.set_normal(Vector3(0,0,1));st.add_vertex(Vector3(vx,lerpf(base-.03,base+(top-base)*weight+.035,v.y),vz))
	var stair := SurfaceTool.new();stair.begin(Mesh.PRIMITIVE_TRIANGLES)
	var stair_run: float=surface.station_stair_run74()
	var stair_count: int=surface.station_stair_count74()
	for i in stair_count:
		var at: Vector2=surface.stair_start73()-Vector2(0,(i+.5)*stair_run/stair_count)
		box72(stair,Vector3(at.x,world.floor_height(at)-.045,at.y),Vector3(4.5,.19,stair_run/stair_count+.025))
		for side in [-1.,1.]:
			var h: float=world.floor_height(at)-base+.14
			box72(stair,Vector3(at.x+side*2.6,base+h*.5,at.y),Vector3(.65,h,stair_run/stair_count+.025))
	station_mesh73=MeshInstance3D.new();station_mesh73.name="ContinuousStationPavingAndFrontWall74";station_mesh73.mesh=st.commit()
	var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/station_brick73.gdshader")
	station_mesh73.material_override=material;add_child(station_mesh73);world.porch49.shade_material(material)
	var treads := MeshInstance3D.new();treads.name="StationFrontSteps74";treads.mesh=stair.commit();treads.material_override=material;add_child(treads)
