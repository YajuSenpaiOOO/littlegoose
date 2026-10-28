extends Node3D
var world: Node3D
var rocks87: Array[Dictionary]=[]
var plants87: Array[Sprite3D]=[]
var bodies87: Array[StaticBody3D]=[]
var textures87: Dictionary={}
var contact_material87: ShaderMaterial
var enabled87 := true

func _textures87(label: String) -> Array[Texture2D]:
	if textures87.has(label): return textures87[label]
	var rects: Array=JSON.parse_string(FileAccess.get_file_as_string("res://assets/forest87/atlas_regions.json"))[label]
	var source: Texture2D=load("res://assets/forest87/"+label+".png")
	var image := source.get_image()
	if image.is_compressed(): image.decompress()
	var result: Array[Texture2D]=[]
	for r in rects:
		# Runtime atlas extraction, as used by the existing forest14 art pack.
		# The generated source PNG remains intact, with its original alpha.
		var tile := image.get_region(Rect2i(r[0],r[1],r[2],r[3]));tile.generate_mipmaps()
		result.append(ImageTexture.create_from_image(tile))
	textures87[label]=result;return result

func _sprite87(texture: Texture2D,at: Vector2,width: float,label: String) -> Sprite3D:
	var sprite := Sprite3D.new();sprite.name=label;sprite.texture=texture
	sprite.pixel_size=width/texture.get_width();sprite.offset.y=texture.get_height()*.5-2.
	sprite.position=Vector3(at.x,world.floor_height(at)-.055,at.y)
	sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/forest_cutout17.gdshader")
	material.set_shader_parameter("paint",texture);material.set_shader_parameter("tint",Vector3(.88,.92,.85))
	sprite.material_override=material;world.porch49.shade_material(material)
	# Solid painted props opt into the common silhouette service; foliage keeps its own response.
	sprite.set_meta("painted_prop_shadow",not _textures87("woodland_plants87").has(texture))
	add_child(sprite)
	return sprite

func _contact87(st: SurfaceTool,at: Vector2,width: float,depth: float) -> void:
	for corner in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
		var p: Vector2=at+(corner-Vector2.ONE*.5)*Vector2(width,depth)
		st.set_uv(corner);st.set_normal(Vector3.UP);st.add_vertex(Vector3(p.x,world.floor_height(p)+.035,p.y))

func _rock87(at: Vector2,width: float,variant: int,contacts: SurfaceTool) -> void:
	var g: Vector2=world.meadow.landmarks.grove
	# Check the whole footprint, not just its centre, against the playable ellipse.
	for offset in [Vector2(-.43,0),Vector2(.43,0),Vector2(0,-.21),Vector2(0,.21)]:
		if ((at+offset*width-g)/Vector2(20.,15.)).length()<1.035: return
	if world.meadow.route_distance(at)<width*.5+1.1: return
	var visual := _sprite87(_textures87("moss_boulders87")[variant],at,width,"MossBoulder87_%02d"%rocks87.size())
	var height: float=visual.texture.get_height()*visual.pixel_size
	# Seat the broad foot at the lowest local support, then bury its rear edge.
	var low: float=world.floor_height(at)
	for dx in [-.32,.32]: low=minf(low,world.floor_height(at+Vector2(dx*width,0)))
	visual.position.y=low-.075
	var body := StaticBody3D.new();body.name="RockFootprint87";body.collision_layer=2;body.collision_mask=0
	var shape := ConvexPolygonShape3D.new();var points := PackedVector3Array()
	for y in [low-.12,low+height*.82]:
		for i in 12:
			var angle := TAU*i/12.;points.append(Vector3(at.x+cos(angle)*width*.42,y,at.y+sin(angle)*width*.19))
	shape.points=points;var collider := CollisionShape3D.new();collider.shape=shape;body.add_child(collider);add_child(body);bodies87.append(body)
	var shadow := preload("res://scripts/art/grounded_prop_shadow63.gd").new()
	shadow.world=world;shadow.visual=visual;add_child(shadow);shadow.update_shadow()
	rocks87.append({"at":at,"width":width,"visual":visual,"body":body,"shadow":shadow,"fade":1.})
	_contact87(contacts,at+Vector2(0,.12),width*.95,width*.42)

func _ready() -> void:
	name="PaintedWoodlandMargins87"
	var g: Vector2=world.meadow.landmarks.grove
	var contact := SurfaceTool.new();contact.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Three asymmetric groups: entry, west outcrop, and foot of the upper forest.
	for spec in [Vector4(21.,10.,4.5,0),Vector4(24.,7.7,2.6,2),Vector4(-24.,-2.,5.8,0),Vector4(-25.5,-6.,3.3,1),Vector4(-22.8,4.,3.,2),Vector4(-19.,-20.,4.9,0),Vector4(-12.,-23.,3.3,1),Vector4(-5.,-20.,4.8,2),Vector4(6.,-22.,3.6,0)]:
		_rock87(g+Vector2(spec.x,spec.y),spec.z,int(spec.w),contact)
	var rng := RandomNumberGenerator.new();rng.seed=870087
	var patches := [Vector2(20.,12.),Vector2(23.,8.),Vector2(-22.,5.),Vector2(-25.,-3.),Vector2(-22.,-11.),Vector2(-18.,-20.),Vector2(-9.,-21.),Vector2(3.,-22.)]
	for i in 48:
		var group: Vector2=patches[i%patches.size()]
		var at := g+group+Vector2(rng.randf_range(-2.1,2.1),rng.randf_range(-1.1,1.1))
		if world.meadow.route_distance(at)<1.7: continue
		if ((at-g)/Vector2(20.,15.)).length()<.95: continue
		var blocked := false
		for rock in rocks87:
			if absf(at.x-rock.at.x)<rock.width*.36 and absf(at.y-rock.at.y)<rock.width*.18: blocked=true
		if blocked: continue
		var plant := _sprite87(_textures87("woodland_plants87")[i%3],at,rng.randf_range(.8,1.45),"FernAndShrub87_%02d"%i)
		plants87.append(plant);_contact87(contact,at,.8,.45)
	# A few low, non-colliding flowers break the empty lawn without becoming
	# hard obstacles in the fighting space. Three loose patches, not a ring.
	for group in [Vector2(-9.,1.),Vector2(8.,-6.),Vector2(-2.,10.)]:
		for j in 3:
			var at: Vector2=g+group+Vector2(j*.65-.65,rng.randf_range(-.4,.4))
			if world.meadow.route_distance(at)<1.7: continue
			var flower := _sprite87(_textures87("woodland_plants87")[1],at,rng.randf_range(.48,.7),"LowClearingFlowers87")
			plants87.append(flower);_contact87(contact,at,.45,.30)
	var mesh := MeshInstance3D.new();mesh.name="SoftGroundContacts87";mesh.mesh=contact.commit();mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	contact_material87=ShaderMaterial.new();contact_material87.shader=preload("res://scripts/art/forest_contact87.gdshader");mesh.material_override=contact_material87;add_child(mesh)
	print("FOREST87_READY rocks=",rocks87.size()," plants=",plants87.size())

func set_enabled87(value: bool) -> void:
	enabled87=value;visible=value
	for body in bodies87: body.collision_layer=2 if value else 0

func _process(delta: float) -> void:
	if not enabled87: return
	contact_material87.set_shader_parameter("opacity87",.11+.05*world.sun.shadow_opacity)
	for rock in rocks87:
		var player: Vector3=world.hero.position;var visual: Sprite3D=rock.visual
		var hidden_player: bool=player.z<rock.at.y+.15 and player.z>rock.at.y-3.5 and absf(player.x-rock.at.x)<rock.width*.45
		rock.fade=move_toward(float(rock.fade),.28 if hidden_player else 1.,delta*3.)
		visual.material_override.set_shader_parameter("fade",rock.fade)
