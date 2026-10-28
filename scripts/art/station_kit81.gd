extends Node3D
## A single movable local-coordinate station kit. Art remains in this project.
var world: Node3D
var hall81: Node3D
var canopy81: Node3D
var coach81: Node3D
var platform81: MeshInstance3D
var hall_body81: StaticBody3D
var coach_body81: StaticBody3D
var post_bodies81: Array[StaticBody3D]=[]
var visuals81: Array[Sprite3D]=[]
var emitters81: Array[Node]=[]
var last_hour81 := -100.
var fade_scan81 := 0.
var fades81: Array[float]=[1.,1.,1.]
var held81: Array[float]=[0.,0.,0.]
var blocked81: Array[bool]=[false,false,false]
var platform_top81 := .39

func module81(label: String,at: Vector3) -> Node3D:
	var node := Node3D.new();node.name=label;node.position=at;add_child(node);return node

func paint81(parent: Node3D,path: String,foot: Vector2,pixel_size: float) -> Sprite3D:
	var texture: Texture2D=load(path)
	var visual: Sprite3D=world._sprite(texture,foot,pixel_size,1.)
	visual.billboard=BaseMaterial3D.BILLBOARD_DISABLED;visual.rotation_degrees.x=-25.
	var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/station_paint81.gdshader")
	material.set_shader_parameter("paint",texture);visual.material_override=material
	parent.add_child(visual);world.porch49.shade_material(material)
	visuals81.append(visual);return visual

func body81(parent: Node3D,label: String,at: Vector3,size: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new();body.name=label;body.position=at;body.collision_layer=2;body.collision_mask=0
	var shape := BoxShape3D.new();shape.size=size
	var collision := CollisionShape3D.new();collision.shape=shape;body.add_child(collision);parent.add_child(body);return body

func box81(parent: Node3D,label: String,at: Vector3,size: Vector3) -> MeshInstance3D:
	var mesh := MeshInstance3D.new();mesh.name=label;mesh.position=at
	var box := BoxMesh.new();box.size=size;mesh.mesh=box
	mesh.material_override=world.rail72.material79();parent.add_child(mesh);return mesh

func shadow81(parent: Node3D,visual: Sprite3D) -> void:
	var shadow := preload("res://scripts/art/grounded_prop_shadow63.gd").new()
	shadow.world=world;shadow.visual=visual;parent.add_child(shadow);shadow.update_shadow()

func deck_mesh81() -> ArrayMesh:
	# One closed extrusion includes both sloping ends, side faces and underside.
	var profile := PackedVector2Array([Vector2(-10.5,-.025),Vector2(-10.5,0),Vector2(-9.,platform_top81),Vector2(9.,platform_top81),Vector2(10.5,0),Vector2(10.5,-.025)])
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var indices := Geometry2D.triangulate_polygon(profile)
	var rings: Array[PackedVector3Array]=[]
	for z in [-2.6,2.6]:
		var ring := PackedVector3Array()
		for p in profile: ring.append(Vector3(p.x,p.y,z))
		rings.append(ring)
		for index in indices: st.set_normal(Vector3(0,0,signf(z)));st.add_vertex(ring[index])
	for i in profile.size():
		var j := (i+1)%profile.size();var edge := profile[j]-profile[i]
		world.rail72.quad80(st,rings[0][i],rings[0][j],rings[1][j],rings[1][i],Vector3(-edge.y,edge.x,0).normalized())
	return st.commit()

func lamp81(parent: Node3D,label: String,at: Vector3,material: ShaderMaterial,range_m: float) -> void:
	var light := OmniLight3D.new();light.name=label;light.position=at;parent.add_child(light)
	var preset := preload("res://scripts/art/warm_glow_preset57.gd").new()
	preset.spill_day=.03;preset.spill_night=1.5;preset.range_day=range_m*.6;preset.range_night=range_m
	preset.core_day=.04;preset.core_night=.85
	var emitter := preload("res://scripts/art/warm_emitter57.gd").new();parent.add_child(emitter)
	emitter.bind(preset,light,material,&"glow81");emitters81.append(emitter)
	world.local68.sources.append({"tag":label,"light":light,"softness":2.1})

func _ready() -> void:
	name="PaintedStationKit81"
	var station: Vector2=world.meadow.landmarks.station
	position=Vector3(station.x,world.floor_height(station),station.y)
	var rail_z: float=world.meadow.rail_z73-station.y
	hall81=module81("WaitingHall81",Vector3(-8.,.035,-4.))
	var hall := paint81(hall81,"res://assets/station81/hall.png",Vector2(887,824),14./1613.)
	hall_body81=body81(hall81,"HallSolid81",Vector3(0,2.4,-2.65),Vector3(13.4,4.8,5.1))
	shadow81(hall81,hall)
	for x in [-3.7,3.7]: lamp81(hall81,"候车厅暖窗"+str(x),Vector3(x,2.,.25),hall.material_override,6.8)
	# The platform is low and joins the existing square, rather than a new terrace.
	var platform := module81("Platform81",Vector3(9.,0,rail_z+4.25))
	platform81=MeshInstance3D.new();platform81.name="ClosedBrickPlatform81";platform81.mesh=deck_mesh81()
	platform81.material_override=world.rail72.material79();platform.add_child(platform81)
	# Short continuous ramp at each end; collision top matches the walking deck.
	var deck := StaticBody3D.new();deck.name="PlatformFloor81";deck.collision_layer=1;deck.collision_mask=0;platform.add_child(deck)
	var collision := CollisionShape3D.new();collision.shape=platform81.mesh.create_trimesh_shape();collision.shape.backface_collision=true;deck.add_child(collision)
	canopy81=module81("PlatformCanopy81",Vector3(9.,platform_top81+.015,rail_z+6.1))
	var canopy := paint81(canopy81,"res://assets/station81/canopy.png",Vector2(960,685),15./1784.)
	canopy.material_override.set_shader_parameter("glass_band81",Vector2.ONE)
	# Four posts only. The waiting area and the route under the roof stay open.
	for at in [Vector2(-6.1,0),Vector2(6.1,0),Vector2(-5.,-2.1),Vector2(5.,-2.1)]:
		post_bodies81.append(body81(canopy81,"CanopyPost81",Vector3(at.x,1.3,at.y),Vector3(.28,2.6,.28)))
	lamp81(canopy81,"站台檐灯",Vector3(0,2.4,-1.),canopy.material_override,6.)
	coach81=module81("StaticCoach81",Vector3(7.,world.meadow.rail_level73()-position.y+.25,rail_z))
	var coach := paint81(coach81,"res://assets/station81/coach.png",Vector2(1080,615),20./2045.)
	coach.material_override.set_shader_parameter("glass_band81",Vector2(.30,.64))
	coach_body81=body81(coach81,"CoachSolid81",Vector3(0,2.,-.25),Vector3(19.5,4.,2.6))
	shadow81(coach81,coach)
	# Glass shares the time profile; coach has one inexpensive spill light.
	lamp81(coach81,"静态车厢暖窗",Vector3(4.,2.,1.15),coach.material_override,5.5)
	print("STATION81_KIT_READY")

func _process(delta: float) -> void:
	if not is_instance_valid(world.time55): return
	var hour: float=world.time55.visual_hour
	if absf(hour-last_hour81)>.02:
		last_hour81=hour
		var night: float=1.-smoothstep(5.,7.,hour) if hour<12. else smoothstep(18.5,21.,hour)
		for emitter in emitters81: emitter.set_level(night,night)
	# Sample painted pixels against the hero, then ease whole props out with a hold.
	# No local holes and no changes to the physical collision while faded.
	fade_scan81-=delta
	if fade_scan81<=0.:
		fade_scan81=.08
		var body: Vector3=world.hero.global_position+Vector3.UP*.85
		var screen: Vector2=world.camera.unproject_position(body)
		for i in visuals81.size():
			var visual := visuals81[i]
			blocked81[i]=world.fade_enabled and not world.review72 and visual.global_position.distance_squared_to(body)<900. and world.whole67.in_front(visual,body) and world.whole67.painted_at(visual,screen)
			if blocked81[i]: held81[i]=.35
	for i in visuals81.size():
		held81[i]=maxf(0.,held81[i]-delta)
		fades81[i]=move_toward(fades81[i],0. if held81[i]>0. else 1.,delta*(4. if held81[i]>0. else 1.7))
		visuals81[i].material_override.set_shader_parameter("fade",fades81[i])
