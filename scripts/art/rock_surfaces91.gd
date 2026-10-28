extends Node3D
## Partition the same terrain geometry along a shared contour. No new collider.
var world: Node3D
var original91: ArrayMesh
var clean91: ArrayMesh
var rock91: MeshInstance3D
var before_materials91: Array[ShaderMaterial]=[]
var after_materials91: Array[ShaderMaterial]=[]
var source_triangles91 := 0
var grass_triangles91 := 0
var rock_triangles91 := 0
var source_area91 := 0.
var grass_area91 := 0.
var rock_area91 := 0.
var active91 := true

func _stone_shader91() -> Shader: return preload("res://scripts/art/bedrock91.gdshader")
func _stone_texture91() -> Texture2D: return preload("res://assets/stone91/bedrock_albedo91.png")
func _needs_edge_distance91() -> bool: return false
func _emit_stone91(st: SurfaceTool,position: Vector3,normal: Vector3,original_normal: Vector3,distance: float) -> void:
	st.set_normal(normal);st.set_uv(Vector2(position.x,position.y)/6.)
	st.set_color(Color(clampf(distance,0.,1.),0,0,1));st.add_vertex(position)

func _rock_score91(at: Vector3,normal: Vector3) -> float:
	return minf(.90-normal.y,minf((at.y-2.24)*.75,minf(at.x+81.,minf(-27.-at.x,minf(at.z+80.,-28.-at.z)))))

func _area91(a: Vector3,b: Vector3,c: Vector3) -> float:
	return (b-a).cross(c-a).length()*.5

func _clean_shader91() -> Shader:
	var code: String=world.terrain_shader90.code
	code=code.replace(preload("res://scripts/art/forest_floor89.gdshaderinc").code,preload("res://scripts/art/clean_floor91.gdshaderinc").code)
	# Grass caps have their original pigment right up to the geometric edge.
	# Side triangles have been removed, so no grass/rock colour crossfade is needed.
	var caps := """
 if(world.x> -81. && world.x< -27. && world.z> -80. && world.z< -28. && world.y>2.15){
  vec2 cap_tile91=world.xz/6.;
  vec2 cap_mirror91=1.-abs(fract(cap_tile91*.5)*2.-1.);
  vec3 cap91=textureGrad(paint,cap_mirror91,dFdx(cap_tile91),dFdy(cap_tile91)).rgb;
  col=mix(col,cap91,1.-path);
 }
"""
	code=code.replace(" ALBEDO=albedo_view ?",caps+" ALBEDO=albedo_view ?")
	var shader := Shader.new();shader.code=code;return shader

func _ready() -> void:
	name="RockFacesAndGrassCaps91"
	original91=world.ground.mesh
	before_materials91.assign(world.ground_materials)
	clean91=ArrayMesh.new()
	var stone := SurfaceTool.new();stone.begin(Mesh.PRIMITIVE_TRIANGLES)
	var grass_shader := _clean_shader91()
	for surface in original91.get_surface_count():
		var arrays: Array=original91.surface_get_arrays(surface)
		var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
		var normals: PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
		var uvs: PackedVector2Array=arrays[Mesh.ARRAY_TEX_UV]
		var indices: PackedInt32Array=arrays[Mesh.ARRAY_INDEX]
		var scores := PackedFloat32Array()
		for v in vertices.size(): scores.append(_rock_score91(vertices[v],normals[v]))
		var keep := PackedInt32Array()
		var count := indices.size() if not indices.is_empty() else vertices.size()
		for i in range(0,count,3):
			var a := i if indices.is_empty() else indices[i]
			var b := i+1 if indices.is_empty() else indices[i+1]
			var c := i+2 if indices.is_empty() else indices[i+2]
			var normal := (vertices[c]-vertices[a]).cross(vertices[b]-vertices[a]).normalized()
			if normal.y<0.: normal=-normal
			source_triangles91+=1
			var area := _area91(vertices[a],vertices[b],vertices[c]);source_area91+=area
			if scores[a]<=0. and scores[b]<=0. and scores[c]<=0.:
				keep.append_array(PackedInt32Array([a,b,c]));grass_triangles91+=1;grass_area91+=area;continue
			var rock_poly: Array[int]=[];var grass_poly: Array[int]=[]
			var triangle := [a,b,c]
			var gradient_size := 1.
			if _needs_edge_distance91():
				var u := vertices[b]-vertices[a];var v := vertices[c]-vertices[a]
				var uu := u.dot(u);var uv := u.dot(v);var vv := v.dot(v)
				var determinant := maxf(.000000001,uu*vv-uv*uv)
				var fu: float=scores[b]-scores[a];var fv: float=scores[c]-scores[a]
				var gradient := u*((fu*vv-fv*uv)/determinant)+v*((fv*uu-fu*uv)/determinant)
				gradient_size=maxf(.000001,gradient.length())
			# Clip at the interpolated contour. Whole-triangle classification caused
			# a sawtooth edge; both materials now share the EXACT intersection points.
			for j in 3:
				var left: int=triangle[j];var right: int=triangle[(j+1)%3]
				var inside := scores[left]>=0.
				if inside: rock_poly.append(left)
				else: grass_poly.append(left)
				if inside!=(scores[right]>=0.):
					var t: float=scores[left]/(scores[left]-scores[right])
					var next := vertices.size()
					vertices.append(vertices[left].lerp(vertices[right],t))
					normals.append(normals[left].lerp(normals[right],t).normalized())
					uvs.append(uvs[left].lerp(uvs[right],t));scores.append(0.)
					rock_poly.append(next);grass_poly.append(next)
			for j in range(1,rock_poly.size()-1):
				var ids := [rock_poly[0],rock_poly[j],rock_poly[j+1]]
				var face_area := _area91(vertices[ids[0]],vertices[ids[1]],vertices[ids[2]])
				if face_area<.0000001: continue
				for index in ids:
					_emit_stone91(stone,vertices[index],normal,normals[index],scores[index]/gradient_size)
				rock_triangles91+=1;rock_area91+=face_area
			for j in range(1,grass_poly.size()-1):
				var ids := PackedInt32Array([grass_poly[0],grass_poly[j],grass_poly[j+1]])
				var face_area := _area91(vertices[ids[0]],vertices[ids[1]],vertices[ids[2]])
				if face_area<.0000001: continue
				keep.append_array(ids);grass_triangles91+=1;grass_area91+=face_area
		# Retain a material slot even if a complete chunk became rock.
		if keep.is_empty(): keep=PackedInt32Array([0,0,0])
		arrays[Mesh.ARRAY_INDEX]=keep
		arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_NORMAL]=normals;arrays[Mesh.ARRAY_TEX_UV]=uvs
		# Original SurfaceTool tangents have the old vertex count. Grass uses its
		# geometric normals and no tangent-space map, so omit that unused channel.
		arrays[Mesh.ARRAY_TANGENT]=null
		clean91.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		var material: ShaderMaterial=before_materials91[surface].duplicate()
		material.shader=grass_shader
		world.porch49.shade_material(material,grass_shader)
		clean91.surface_set_material(surface,material);after_materials91.append(material)
	rock91=MeshInstance3D.new();rock91.name="FacetedBedrock91"
	rock91.mesh=stone.commit() if rock_triangles91>0 else ArrayMesh.new()
	var material := ShaderMaterial.new();material.shader=_stone_shader91()
	material.set_shader_parameter("stone_paint91",_stone_texture91())
	world.porch49.shade_material(material);rock91.material_override=material;add_child(rock91)
	set_enabled91(true)
	print("ROCK91_PARTITION source=",source_triangles91," grass=",grass_triangles91," stone=",rock_triangles91)

func set_enabled91(value: bool) -> void:
	active91=value
	world.ground.mesh=clean91 if value else original91
	world.ground_materials.assign(after_materials91 if value else before_materials91)
	rock91.visible=value
	world.uploaded_revision=-1
	world._sync_tracks()
