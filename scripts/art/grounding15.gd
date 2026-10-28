extends RefCounted
## Lay the source root band onto terrain while seating the trunk at its join.
func root_skirt(texture: Texture2D,profile: Dictionary,height: float,at: Vector3,landscape: RefCounted,terrain_on: bool,ratio: float=.052) -> Dictionary:
	var scale := height/float(profile.height)
	var band := height*ratio
	var foot := Vector2(profile.foot[0],profile.foot[1])
	var cut := foot.y-band/scale
	var image := texture.get_image()
	var center_x := 0.
	var samples := 0
	for y in range(maxi(0,int(cut)-2),mini(image.get_height(),int(cut)+3)):
		for x in image.get_width():
			if image.get_pixel(x,y).a<float(profile.get("cutoff",.5)): continue
			center_x += x
			samples += 1
	var collider_x := (center_x/maxf(1.,float(samples))-foot.x)*scale if samples>0 else 0.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in 6:
		var t0 := float(row)/6.
		var t1 := float(row+1)/6.
		for column in 12:
			var u0 := float(column)/12.
			var u1 := float(column+1)/12.
			for uv in [Vector2(u0,t0),Vector2(u1,t0),Vector2(u1,t1),Vector2(u0,t0),Vector2(u1,t1),Vector2(u0,t1)]:
				var x: float = (uv.x*texture.get_width()-foot.x)*scale
				var z: float = uv.y*band/tan(deg_to_rad(25.))
				var y: float = landscape.height_at(at.x+x,at.z+z,terrain_on)-at.y+.012
				st.set_normal(Vector3.UP)
				st.set_uv(Vector2(uv.x,lerpf(cut,foot.y,uv.y)/texture.get_height()))
				st.add_vertex(Vector3(x,y,z))
	return {"mesh":st.commit(),"drop":band,"cut":cut/texture.get_height(),"collider_x":collider_x}

func roof_shadow() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var a := Vector3(-3.5,2.9,.15)
	var b := Vector3(0,4.9,.15)
	var c := Vector3(3.5,2.9,.15)
	var back := Vector3(0,0,-4.1)
	for triangle in [[a,b,c],[a+back,c+back,b+back],[a,a+back,b],[b,a+back,b+back],[b,b+back,c],[c,b+back,c+back]]:
		st.set_normal((triangle[2]-triangle[0]).cross(triangle[1]-triangle[0]).normalized())
		for p in triangle: st.add_vertex(p)
	return st.commit()
