extends "res://scripts/art/nature_park97.gd"
const PLAN98=preload("res://scripts/world/park_layout98.gd")
var tilted98: Array[MeshInstance3D]=[]
var embedded_stones98 := 0
var anchors98: Array[Vector3]=[]
func _material97(kind: int) -> ShaderMaterial:
	var material := super._material97(kind)
	material.shader=preload("res://scripts/art/park_timber98.gdshader")
	material.set_shader_parameter("timber97",textures97[1 if kind==1 else 0])
	return material
func _prism98(poly: PackedVector2Array,at: Vector3,depth: float) -> MeshInstance3D:
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var indices := Geometry2D.triangulate_polygon(poly)
	for index in indices:
		st.set_normal(Vector3.UP);st.add_vertex(Vector3(poly[index].x,0.,poly[index].y))
	for i in poly.size():
		var a := poly[i];var b := poly[(i+1)%poly.size()]
		var normal := Vector3(b.y-a.y,0.,a.x-b.x).normalized()
		for point in [Vector3(a.x,0.,a.y),Vector3(a.x,-depth,a.y),Vector3(b.x,-depth,b.y),Vector3(a.x,0.,a.y),Vector3(b.x,-depth,b.y),Vector3(b.x,0.,b.y)]:
			st.set_normal(normal);st.add_vertex(point)
	var node := MeshInstance3D.new();node.mesh=st.commit();node.position=at;node.material_override=stone97;add_child(node)
	return node
func _boulder98(at: Vector3,size: Vector3,seed_value: float) -> void:
	var mesh := SphereMesh.new();mesh.radial_segments=7;mesh.rings=3;mesh.radius=.5;mesh.height=1.
	var node := MeshInstance3D.new();node.mesh=mesh;node.material_override=stone97;node.position=at
	node.scale=size;node.rotation=Vector3(.12*sin(seed_value),seed_value,.10*cos(seed_value));add_child(node)
	embedded_stones98+=1
func _overlook97() -> void:
	var g: Vector2=world.meadow.landmarks.grove
	var center := Vector3(g.x+PLAN98.DECK.x,PLAN98.DECK_Y+.02,g.y+PLAN98.DECK.y)
	# A thin irregular paved front merges into the real mountain behind it.
	_prism98(PackedVector2Array([Vector2(-2.9,-1.4),Vector2(-1.1,-2.),Vector2(1.4,-1.7),Vector2(2.7,-.6),Vector2(2.3,1.1),Vector2(.3,2.25),Vector2(-2.5,1.1)]),center,.13)
	var depth := (PLAN98.STAIR_FOOT-PLAN98.STAIR_TOP)/8.
	for i in 8:
		var top := lerpf(2.1,PLAN98.DECK_Y,float(i+1)/8.)
		var z := g.y+PLAN98.STAIR_FOOT-(i+.5)*depth
		var half := 1.28+.10*sin(i*2.4)
		var poly := PackedVector2Array([Vector2(-half+.13,-depth*.53),Vector2(half-.15,-depth*.56),Vector2(half,-depth*.22),Vector2(half-.05,depth*.38),Vector2(half-.24,depth*.55),Vector2(-half+.12,depth*.51),Vector2(-half-.06,depth*.22),Vector2(-half,-depth*.27)])
		var plan := PLAN98.from_stair98(Vector2(PLAN98.STAIR_X+.06*sin(i*3.1),z-g.y))+g
		var tread := _prism98(poly,Vector3(plan.x,top,plan.y),.32)
		tread.rotation.y=-PLAN98.STAIR_YAW+.018*sin(i*1.8)
		# Uneven shoulders climb WITH the flight, not small blocks placed on it.
		for side in [-1.,1.]:
			if (i+int(side))%3==0: continue
			var x: float=g.x+PLAN98.STAIR_X+side*(1.65+.10*sin(i*1.3))
			var flank := PLAN98.from_stair98(Vector2(x-g.x,z-g.y-.12))+g
			_boulder98(Vector3(flank.x,top-.22,flank.y),Vector3(.78+.2*sin(i),.72,1.0),i*2.7+side)
	var posts: Array[Vector3]=[]
	for offset in [Vector2(-2.25,-.7),Vector2(-1.6,-1.6),Vector2(-.2,-1.9),Vector2(1.25,-1.6),Vector2(2.25,-.6)]:
		var at := center+Vector3(offset.x,.02,offset.y)
		# A post swallowed by the mountain is intentionally omitted.
		if world.floor_height(Vector2(at.x,at.z))>PLAN98.DECK_Y+.2: continue
		_cylinder97(at,at+Vector3(.03*sin(offset.x),.78,.02),.105,wood97,true);posts.append(at+Vector3.UP*.57)
	for i in posts.size()-1: _cylinder97(posts[i],posts[i+1],.073,wood97,true)
func _swing97() -> void:
	var visual: Sprite3D=world.swing_tree98.visual
	var foot := Vector2(1000.,1230.)
	# Rope locations are measured in the generated tree, then transformed using
	# the actual root drop. This also survives a future root-height adjustment.
	for pixel in [Vector2(411.,700.),Vector2(548.,713.)]:
		anchors98.append(visual.global_position+Vector3((pixel.x-foot.x)*visual.pixel_size,(foot.y-pixel.y)*visual.pixel_size,.025))
	swing_origin97=(anchors98[0]+anchors98[1])*.5
	swing97=Node3D.new();swing97.name="BranchAnchoredSwing98";swing97.position=swing_origin97;add_child(swing97)
	var ground_y: float=world.floor_height(Vector2(swing_origin97.x,swing_origin97.z))
	var seat_y := ground_y+.68-swing_origin97.y
	for anchor in anchors98:
		var top := anchor-swing_origin97
		_cylinder97(top,Vector3(top.x,seat_y+.06,top.z),.022,rope97,false,swing97)
	var span := absf(anchors98[1].x-anchors98[0].x)
	_box97(Vector3(0,seat_y,0),Vector3(span+.32,.13,.55),wood97,false,swing97)
func _play97() -> void:
	var base := point97(PLAN98.LOG)
	var a := base+Vector3(-2.75,.43,-.5);var b := base+Vector3(2.3,.63,.65)
	var trunk := _cylinder97(a,b,.44,bark97,true);trunk.mesh.top_radius=.35;trunk.mesh.radial_segments=9
	_cylinder97(base+Vector3(-.5,.65,0),base+Vector3(-1.,1.1,-.25),.15,bark97)
	for i in 5:
		var at := PLAN98.LOG+Vector2(-2.15+i*1.45,1.6+sin(i*.9)*.65)
		var foot := point97(at,-.035)
		var height := .5+.16*sin(i*1.7)
		var lean := Vector3(.16*sin(i*2.2+.6),height,.12*cos(i*1.4))
		var stump := _cylinder97(foot,foot+lean,.39+.045*sin(i),bark97,true)
		stump.mesh.top_radius=stump.mesh.bottom_radius*(.78+.12*sin(i*2.1));stump.mesh.radial_segments=9
		tilted98.append(stump);stumps97.append(at)
	# Small irregular stones interrupt the path edge, never the walking centre.
	for offset in [Vector2(-6.1,6.25),Vector2(4.8,9.7),Vector2(5.2,9.9),Vector2(9.9,3.3),Vector2(-7.8,-5.3),Vector2(1.2,-8.0)]:
		_boulder98(point97(offset,.06),Vector3(.30,.16,.23),offset.x)
func _bench97() -> void:
	var group := Node3D.new();group.name="AngledTimberSeat98";group.position=point97(PLAN98.BENCH);group.rotation.y=-.19;add_child(group)
	for x in [-1.05,1.05]:
		for z in [-.28,.28]: _cylinder97(Vector3(x,-.04,z),Vector3(x+.03,.52,z),.16,bark97,true,group)
	for z in [-.24,.24]: _box97(Vector3(0,.58,z),Vector3(2.8,.2,.43),wood97,true,group)
func _ready() -> void:
	name="WoodlandNaturePark98"
	var source: Image=preload("res://assets/park98/painted_material_atlas98.png").get_image()
	if source.is_compressed(): source.decompress()
	var half := source.get_width()/2
	for cell in [Vector2i(0,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
		var tile := source.get_region(Rect2i(cell*half,Vector2i(half,half)));tile.generate_mipmaps();textures97.append(ImageTexture.create_from_image(tile))
	wood97=_material97(0);bark97=_material97(1);rope97=_material97(2)
	stone97=ShaderMaterial.new();stone97.shader=preload("res://scripts/art/park_stone98.gdshader")
	stone97.set_shader_parameter("pigment97",textures97[3]);world.porch49.shade_material(stone97)
	_overlook97();_swing97();_bench97();_play97()
	print("PARK98_OBJECTS embedded_stones=",embedded_stones98," tilted_stumps=",tilted98.size()," anchors=",anchors98)
