extends "res://scripts/art/station_kit81.gd"
const PLATFORM_HALF82 := 18.5
const CANOPY_WIDTH82 := 12.8
const CANOPY_DEPTH82 := 3.7
const POST_HEIGHT82 := 2.7
var canopies82: Array[Node3D]=[]
var roofs82: Array[Dictionary]=[]
var contact_marks82: Array[MeshInstance3D]=[]
var pillar_feet82: Array[Vector3]=[]
var wheel_points82: Array[Vector3]=[]
var dressing82: Array[Node3D]=[]
var roof_scan82 := 0.
var board_label82: Label3D

func brick82() -> ShaderMaterial:
	var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/station_brick73.gdshader")
	world.porch49.shade_material(material);return material

func paint81(parent: Node3D,path: String,foot: Vector2,pixel_size: float) -> Sprite3D:
	var visual := super.paint81(parent,path,foot,pixel_size)
	var material: ShaderMaterial=visual.material_override
	material.shader=preload("res://scripts/art/station_paint82.gdshader");world.porch49.shade_material(material)
	return visual

func contact82(parent: Node3D,at: Vector3,size: Vector2,opacity: float) -> void:
	var node := MeshInstance3D.new();node.name="SoftContact82";node.position=at
	var plane := PlaneMesh.new();plane.size=size;node.mesh=plane
	var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/station_contact82.gdshader")
	material.set_shader_parameter("opacity82",opacity);node.material_override=material
	node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;parent.add_child(node);contact_marks82.append(node)

func frame_material82(rect: Vector4) -> ShaderMaterial:
	var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/station_frame82.gdshader")
	material.set_shader_parameter("paint",preload("res://assets/station81/canopy.png"))
	material.set_shader_parameter("sample_rect82",rect);world.porch49.shade_material(material);return material

func timber82(parent: Node3D,at: Vector3,size: Vector3,material: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new();node.name="PaintedTimber82";node.position=at
	var box := BoxMesh.new();box.size=size;node.mesh=box;node.material_override=material;parent.add_child(node);return node

func roof_quad82(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3,d: Vector3) -> void:
	var normal := (d-a).cross(b-a).normalized()
	if normal.y<0.: normal=-normal
	var vertices := [a,b,c,a,c,d]
	var uvs := [Vector2(67,352),Vector2(1851,352),Vector2(1680,132),Vector2(67,352),Vector2(1680,132),Vector2(230,132)]
	for i in 6:
		st.set_normal(normal);st.set_uv(uvs[i]/Vector2(1916,821));st.add_vertex(vertices[i])

func canopy82(x: float,rail_z: float,tag: String) -> void:
	var root := module81(tag,Vector3(x,platform_top81,rail_z+4.3));canopies82.append(root)
	var wood := frame_material82(Vector4(220./1916.,448./821.,46./1916.,170./821.))
	var roof_material := frame_material82(Vector4(0,0,1,1))
	for z in [-1.3,1.3]:
		for px in [-4.9,4.9]:
			var foot := Vector3(px,0,z)
			var post := timber82(root,foot+Vector3.UP*POST_HEIGHT82*.5,Vector3(.25,POST_HEIGHT82,.25),wood)
			post.name="GroundedWoodPost82"
			post_bodies81.append(body81(root,"PostCollision82",foot+Vector3.UP*POST_HEIGHT82*.5,Vector3(.25,POST_HEIGHT82,.25)))
			var base := timber82(root,foot+Vector3.UP*.085,Vector3(.42,.17,.42),brick82());base.name="PostStoneFoot82"
			pillar_feet82.append(root.to_global(foot))
			contact82(root,foot+Vector3.UP*.012,Vector2(.85,.85),.35)
	for z in [-1.3,1.3]: timber82(root,Vector3(0,POST_HEIGHT82-.08,z),Vector3(11.2,.22,.22),wood)
	for px in [-4.9,4.9]: timber82(root,Vector3(px,POST_HEIGHT82-.06,0),Vector3(.22,.22,3.7),wood)
	var roof := MeshInstance3D.new();roof.name="PaintedPitchedRoof82"
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half := CANOPY_WIDTH82*.5;var depth := CANOPY_DEPTH82*.5
	roof_quad82(st,Vector3(-half,POST_HEIGHT82,depth),Vector3(half,POST_HEIGHT82,depth),Vector3(half-.65,POST_HEIGHT82+.95,0),Vector3(-half+.65,POST_HEIGHT82+.95,0))
	roof_quad82(st,Vector3(half,POST_HEIGHT82,-depth),Vector3(-half,POST_HEIGHT82,-depth),Vector3(-half+.65,POST_HEIGHT82+.95,0),Vector3(half-.65,POST_HEIGHT82+.95,0))
	roof.mesh=st.commit();roof.material_override=roof_material;root.add_child(roof)
	# Actual geometry, no rendered post carries a fake vertical position in a card.
	var occluder := body81(root,"RoofOcclusion82",Vector3(0,POST_HEIGHT82+.4,0),Vector3(CANOPY_WIDTH82,1.1,CANOPY_DEPTH82))
	occluder.collision_layer=8
	roofs82.append({"root":root,"collider":occluder,"material":roof_material,"fade":1.,"held":0.,"blocked":false})
	contact82(root,Vector3(0,.011,0),Vector2(12.4,3.5),.13)
	lamp81(root,tag+"檐灯",Vector3(0,2.4,0),null,6.)

func deck_mesh81() -> ArrayMesh:
	var profile := PackedVector2Array([Vector2(-20.,-.025),Vector2(-20.,0),Vector2(-PLATFORM_HALF82,platform_top81),Vector2(PLATFORM_HALF82,platform_top81),Vector2(20.,0),Vector2(20.,-.025)])
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var indices := Geometry2D.triangulate_polygon(profile);var rings: Array[PackedVector3Array]=[]
	for z in [-2.6,2.6]:
		var ring := PackedVector3Array()
		for p in profile: ring.append(Vector3(p.x,p.y,z))
		rings.append(ring)
		for index in indices: st.set_normal(Vector3(0,0,signf(z)));st.add_vertex(ring[index])
	for i in profile.size():
		var j := (i+1)%profile.size();var edge := profile[j]-profile[i]
		world.rail72.quad80(st,rings[0][i],rings[0][j],rings[1][j],rings[1][i],Vector3(-edge.y,edge.x,0).normalized())
	return st.commit()

func prop82(label: String,path: String,at: Vector3,foot: Vector2,scale_px: float,footprint: Vector2) -> void:
	var root := module81(label,at);dressing82.append(root)
	var sprite := paint81(root,path,foot,scale_px);sprite.material_override.set_shader_parameter("glass_band81",Vector2.ONE)
	body81(root,label+"Collision",Vector3(0,.4,-.1),Vector3(footprint.x,.8,footprint.y))
	contact82(root,Vector3(0,.025,-.1),footprint*1.25,.24)

func _ready() -> void:
	name="CenteredAndGroundedStation82"
	var station: Vector2=world.meadow.landmarks.station
	position=Vector3(station.x,world.floor_height(station),station.y)
	var rail_z: float=world.meadow.rail_z73-station.y
	hall81=module81("CenteredWaitingHall82",Vector3(0,.035,-4.5))
	var hall := paint81(hall81,"res://assets/station81/hall.png",Vector2(887,824),14./1613.)
	hall_body81=body81(hall81,"HallSolid82",Vector3(0,2.4,-2.65),Vector3(13.4,4.8,5.1));shadow81(hall81,hall)
	contact82(hall81,Vector3(0,.021,-.2),Vector2(14.2,1.5),.3)
	for x in [-3.7,3.7]: lamp81(hall81,"候车厅暖窗"+str(x),Vector3(x,2.,.25),hall.material_override,6.8)
	var platform := module81("FullWidthPlatform82",Vector3(0,0,rail_z+4.25))
	platform81=MeshInstance3D.new();platform81.name="ClosedFullWidthPlatform82";platform81.mesh=deck_mesh81();platform81.material_override=brick82();platform.add_child(platform81)
	var deck := StaticBody3D.new();deck.name="PlatformFloor82";deck.collision_layer=1;deck.collision_mask=0;platform.add_child(deck)
	var shape := CollisionShape3D.new();shape.shape=platform81.mesh.create_trimesh_shape();shape.shape.backface_collision=true;deck.add_child(shape)
	canopy82(-11.4,rail_z,"WestCanopy82");canopy82(11.4,rail_z,"EastCanopy82");canopy81=canopies82[1]
	coach81=module81("RailAlignedCoach82",Vector3(4.,world.meadow.rail_level73()-position.y+.25,rail_z))
	var coach := paint81(coach81,"res://assets/station81/coach.png",Vector2(1080,615),20./2045.)
	# A side elevation is upright and sits on the visible near rail, not the gauge centre.
	coach.rotation_degrees.x=0.;coach.position.z=.85
	coach.material_override.set_shader_parameter("glass_band81",Vector2(.30,.64))
	coach_body81=body81(coach81,"CoachSolid82",Vector3(0,2.,-.1),Vector3(19.5,4.,1.9))
	shadow81(coach81,coach)
	for px in [318.,562.,1516.,1744.]:
		var point := Vector3((px-1080.)*coach.pixel_size,0,.85)
		wheel_points82.append(world._pixel_world(coach,Vector2(px,615.)))
		contact82(coach81,Vector3(point.x,-.207,.3),Vector2(1.5,1.25),.28)
	lamp81(coach81,"静态车厢暖窗",Vector3(4.,2.,1.),coach.material_override,5.5)
	prop82("DepartureBoard82","res://assets/station82/board.png",Vector3(-9.,.04,-2.7),Vector2(580,1096),2.3/920.,Vector2(1.65,.55))
	board_label82=Label3D.new();board_label82.text="林间微光站\n候车请至后侧\n旅途愉快"
	board_label82.font_size=48;board_label82.pixel_size=.003;board_label82.outline_size=0
	board_label82.modulate=Color("60422d");board_label82.position=Vector3(0,.96,.02)
	visuals81[2].add_child(board_label82)
	prop82("LuggageCart82","res://assets/station82/cart.png",Vector3(13.5,.04,-1.8),Vector2(1070,746),2.7/1300.,Vector2(2.4,1.))
	prop82("ParcelStack82","res://assets/station82/crates.png",Vector3(16.3,.04,-2.2),Vector2(687,896),1.5/750.,Vector2(1.4,1.))
	for x in [-11.7,11.7]:
		prop82("BenchFlowerBox82","res://assets/departure_plaza_v1/flower_box_v1.png",Vector3(x,.04,4.1),Vector2(887,632),2.6/985.,Vector2(2.6,.65))
	for prop in world.props15:
		if prop.id=="bench" and Vector2(prop.root.position.x-station.x,prop.root.position.z-station.y).length()<10.:
			prop.root.position=position+Vector3(-11.7 if prop.root.position.x<station.x else 11.7,.04,2.4)
	fades81.resize(visuals81.size());fades81.fill(1.)
	held81.resize(visuals81.size());held81.fill(0.)
	blocked81.resize(visuals81.size());blocked81.fill(false)
	print("STATION82_CENTERED_FULL_WIDTH_GROUNDED_READY")

func _process(delta: float) -> void:
	super._process(delta)
	if is_instance_valid(board_label82): board_label82.modulate.a=fades81[2]
	roof_scan82-=delta
	if roof_scan82<=0.:
		roof_scan82=.08
		var query := PhysicsRayQueryParameters3D.create(world.camera.global_position,world.hero.global_position+Vector3.UP*.9,8)
		var hit := get_world_3d().direct_space_state.intersect_ray(query)
		for roof in roofs82:
			roof.blocked=world.fade_enabled and not world.review72 and not hit.is_empty() and hit.collider==roof.collider
			if roof.blocked: roof.held=.35
	for roof in roofs82:
		roof.held=maxf(0.,roof.held-delta)
		roof.fade=move_toward(roof.fade,0. if roof.held>0. else 1.,delta*(4. if roof.held>0. else 1.7))
		roof.material.set_shader_parameter("fade82",roof.fade)
