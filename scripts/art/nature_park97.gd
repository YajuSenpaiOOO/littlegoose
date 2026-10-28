extends Node3D
const LAYOUT=preload("res://scripts/world/park_layout97.gd")
var world: Node3D
var wood97: ShaderMaterial
var bark97: ShaderMaterial
var rope97: ShaderMaterial
var stone97: ShaderMaterial
var textures97: Array[Texture2D]=[]
var swing97: Node3D
var swing_origin97 := Vector3.ZERO
var elapsed97 := 0.
var boxes97 := 0
var stumps97: Array[Vector2]=[]
var rail_bodies97: Array[StaticBody3D]=[]

func _material97(kind: int) -> ShaderMaterial:
	var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/park_timber97.gdshader")
	material.set_shader_parameter("timber97",textures97[0 if kind==1 else 1]);material.set_shader_parameter("kind97",kind)
	material.set_shader_parameter("endgrain97",textures97[2])
	world.porch49.shade_material(material);return material

func point97(offset: Vector2,height := 0.) -> Vector3:
	var at: Vector2=Vector2(world.meadow.landmarks.grove)+offset
	return Vector3(at.x,world.floor_height(at)+height,at.y)

func _box97(at: Vector3,size: Vector3,material: Material,solid := false,parent: Node3D=null) -> MeshInstance3D:
	var mesh := BoxMesh.new();mesh.size=size
	var node := MeshInstance3D.new();node.mesh=mesh;node.material_override=material;node.position=at
	(parent if parent!=null else self).add_child(node);boxes97+=1
	if solid:
		var body := StaticBody3D.new();body.collision_layer=2;body.collision_mask=0
		var shape := BoxShape3D.new();shape.size=size
		var collider := CollisionShape3D.new();collider.shape=shape;body.add_child(collider);node.add_child(body)
		rail_bodies97.append(body)
	return node

func _cylinder97(a: Vector3,b: Vector3,radius: float,material: Material,solid := false,parent: Node3D=null) -> MeshInstance3D:
	var axis := b-a;var length := axis.length();var direction := axis/length
	var mesh := CylinderMesh.new();mesh.top_radius=radius*.94;mesh.bottom_radius=radius;mesh.height=length;mesh.radial_segments=12;mesh.rings=2
	var node := MeshInstance3D.new();node.mesh=mesh;node.material_override=material;node.position=(a+b)*.5
	var reference := Vector3.FORWARD if absf(direction.dot(Vector3.FORWARD))<.95 else Vector3.RIGHT
	var right := direction.cross(reference).normalized();node.basis=Basis(right,direction,right.cross(direction))
	(parent if parent!=null else self).add_child(node)
	if solid:
		var body := StaticBody3D.new();body.collision_layer=2;body.collision_mask=0
		var shape := CylinderShape3D.new();shape.radius=radius;shape.height=length
		var collider := CollisionShape3D.new();collider.shape=shape;body.add_child(collider);node.add_child(body)
		rail_bodies97.append(body)
	return node

func _overlook97() -> void:
	var g: Vector2=world.meadow.landmarks.grove
	var center := Vector3(g.x+LAYOUT.DECK.x,LAYOUT.DECK_Y-.035,g.y+LAYOUT.DECK.y)
	var deck := CylinderMesh.new();deck.top_radius=2.85;deck.bottom_radius=2.95;deck.height=.16;deck.radial_segments=14
	var node := MeshInstance3D.new();node.name="StoneOverlook97";node.mesh=deck;node.material_override=stone97;node.position=center;add_child(node)
	for i in 8:
		var step_depth := (LAYOUT.STAIR_FOOT-LAYOUT.STAIR_TOP)/8.
		var top := lerpf(2.1,LAYOUT.DECK_Y,float(i+1)/8.)
		var z: float=g.y+LAYOUT.STAIR_FOOT-(i+.5)*step_depth
		_box97(Vector3(g.x+LAYOUT.STAIR_X,top-.17,z),Vector3(2.7,.34,step_depth+.025),stone97)
		# Small paired stone shoulders frame the stair without enclosing it.
		for side in [-1.,1.]:
			_box97(Vector3(g.x+LAYOUT.STAIR_X+side*1.48,top-.1,z),Vector3(.22,.44,step_depth+.025),stone97)
	var posts: Array[Vector3]=[]
	for i in 7:
		var angle := PI+PI*float(i)/6.
		var at := center+Vector3(cos(angle)*2.65,.08,sin(angle)*2.45)
		_cylinder97(at,at+Vector3.UP*.88,.105,wood97,true)
		posts.append(at+Vector3.UP*.67)
	for i in posts.size()-1: _cylinder97(posts[i],posts[i+1],.075,wood97,true)

func _swing97() -> void:
	var ground := point97(LAYOUT.SWING)
	# A short timber limb belongs to the nearby living tree. Rope anchors are
	# stationary; the child pivot moves the seat and both ropes together.
	_cylinder97(ground+Vector3(.5,3.75,-1.5),ground+Vector3(1.35,3.65,0),.18,bark97)
	_cylinder97(ground+Vector3(1.35,3.65,0),ground+Vector3(-1.15,3.65,0),.14,bark97)
	swing97=Node3D.new();swing97.name="TreeSwing97";swing97.position=ground+Vector3.UP*3.65;add_child(swing97)
	for x in [-.7,.7]:
		_cylinder97(Vector3(x,0,0),Vector3(x,-2.95,0),.025,rope97,false,swing97)
	_box97(Vector3(0,-2.98,0),Vector3(1.8,.14,.62),wood97,false,swing97)
	# Feet and the tree stay clear: the animated seat is decorative for now.
	swing_origin97=swing97.position
	var foot := _box97(ground+Vector3(0,.67,0),Vector3(1.5,.2,.48),wood97,true)
	foot.visible=false

func _bench97() -> void:
	var base := point97(LAYOUT.BENCH)
	for x in [-1.2,1.2]:
		_cylinder97(base+Vector3(x,-.04,-.28),base+Vector3(x,.52,-.28),.17,bark97,true)
		_cylinder97(base+Vector3(x,-.04,.28),base+Vector3(x,.52,.28),.17,bark97,true)
	for z in [-.24,.24]: _box97(base+Vector3(0,.58,z),Vector3(3.15,.2,.43),wood97,true)

func _play97() -> void:
	var base := point97(LAYOUT.LOG)
	_cylinder97(base+Vector3(-3.,.47,0),base+Vector3(2.8,.55,.4),.46,bark97,true)
	_cylinder97(base+Vector3(-.8,.7,.1),base+Vector3(-.6,1.0,.3),.11,bark97)
	# Exposed end grain and low uneven stumps, with navigable gaps.
	for i in 5:
		var at := LAYOUT.LOG+Vector2(-2.+i*1.55,1.7+sin(i*.8)*.4)
		var foot := point97(at,-.03)
		var height := .42+.12*sin(i*1.7)
		_cylinder97(foot,foot+Vector3.UP*height,.36+.035*sin(i),bark97,true)
		stumps97.append(at)

func _ready() -> void:
	name="WoodlandNaturePark97"
	var source: Image=preload("res://assets/park97/painted_timber_atlas97.png").get_image()
	if source.is_compressed(): source.decompress()
	var half := source.get_width()/2
	for cell in [Vector2i(0,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
		var tile := source.get_region(Rect2i(cell*half,Vector2i(half,half)));tile.generate_mipmaps();textures97.append(ImageTexture.create_from_image(tile))
	wood97=_material97(0);bark97=_material97(1);rope97=_material97(2)
	stone97=ShaderMaterial.new();stone97.shader=preload("res://scripts/art/park_stone97.gdshader")
	stone97.set_shader_parameter("pigment97",preload("res://assets/stone84/painted_limestone_top84.png"));world.porch49.shade_material(stone97)
	_overlook97();_swing97();_bench97();_play97()
	print("PARK97_OBJECTS boxes=",boxes97," collision_bodies=",rail_bodies97.size())

func _process(delta: float) -> void:
	elapsed97+=delta
	if is_instance_valid(swing97):
		var near: bool=world.effect_scope95.near_view95(swing_origin97,4.) if is_instance_valid(world.effect_scope95) else true
		if near: swing97.rotation.x=sin(elapsed97*.9)*.035
