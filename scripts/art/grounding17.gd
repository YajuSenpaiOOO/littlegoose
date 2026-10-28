extends "res://scripts/art/grounding15.gd"
## A single shared seam: horizontal sprite joins a terrain-following root fan.
func root_skirt(texture: Texture2D,profile: Dictionary,height: float,at: Vector3,landscape: RefCounted,terrain_on: bool,ratio: float=.052) -> Dictionary:
	var result := super.root_skirt(texture,profile,height,at,landscape,terrain_on,ratio)
	var scale := height/float(profile.height)
	var foot := Vector2(profile.foot[0],profile.foot[1])
	var root_cut := foot.y-height*ratio/scale
	# Include a short upright transition above the old cut. Merely bridging from
	# Y=0 down to terrain can bury the bridge halfway through a rising slope.
	var rise := height*.08
	var top_cut := root_cut-rise/scale
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in 14:
		for column in 24:
			var a := Vector2(float(column)/24.,float(row)/14.)
			var b := Vector2(float(column+1)/24.,float(row+1)/14.)
			for uv in [a,Vector2(b.x,a.y),b,a,b,Vector2(a.x,b.y)]:
				# Three texels of shared paint hide raster/mipmap cracks at the join.
				var pixel_y := lerpf(top_cut-3.,foot.y,uv.y)
				var x: float = (uv.x*texture.get_width()-foot.x)*scale
				var z := maxf(.003,(pixel_y-root_cut)*scale/tan(deg_to_rad(25.)))
				var terrain: float = landscape.height_at(at.x+x,at.z+z,terrain_on)-at.y+.018
				var source_height := maxf(0.,(root_cut-pixel_y)*scale)
				var vertical := clampf(source_height/rise,0.,1.)
				var y := source_height+terrain*(1.-vertical)
				st.set_normal(Vector3.UP)
				st.set_uv(Vector2(uv.x,pixel_y/texture.get_height()))
				st.add_vertex(Vector3(x,y,z))
	result.mesh = st.commit()
	result.cut = top_cut/texture.get_height()
	return result
