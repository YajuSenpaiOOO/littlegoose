extends RefCounted
## A giant sprite needs a small physical seam, not a seam scaled with its canopy.
func root_skirt(texture: Texture2D,profile: Dictionary,height: float,at: Vector3,landscape: RefCounted,terrain_on: bool) -> Dictionary:
	var scale_px := height/float(profile.height)
	var foot := Vector2(profile.foot[0],profile.foot[1])
	var drop := .20
	var rise := .28
	var root_cut := foot.y-drop/scale_px
	var top_cut := root_cut-rise/scale_px
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in 8:
		for column in 24:
			for corner in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
				var uv: Vector2=(Vector2(column,row)+corner)/Vector2(24,8)
				var py := lerpf(top_cut-3.,foot.y,uv.y)
				var x: float=(uv.x*texture.get_width()-foot.x)*scale_px
				var z := maxf(.003,(py-root_cut)*scale_px/tan(deg_to_rad(25.)))
				var terrain: float=landscape.height_at(at.x+x,at.z+z,terrain_on)-at.y+.018
				var source_height := maxf(0.,(root_cut-py)*scale_px)
				var vertical := clampf(source_height/rise,0.,1.)
				st.set_normal(Vector3.UP)
				st.set_uv(Vector2(uv.x,py/texture.get_height()))
				st.add_vertex(Vector3(x,source_height+terrain*(1.-vertical),z))
	return {"mesh":st.commit(),"drop":drop,"cut":top_cut/texture.get_height()}
