extends Node3D
## Static art never receives a per-frame update. Only three near-view butterflies move.
var world: Node3D
var props: Array[Sprite3D]=[]
var leaves: Array[MeshInstance3D]=[]
var pebbles: MultiMeshInstance3D
var grass: MultiMeshInstance3D
var butterflies: MultiMeshInstance3D
var butterfly_material: ShaderMaterial
var centres: Array[Vector3]=[]
var active: Array[bool]=[false,false,false]
var audio: Node3D
var textures: Array[Texture2D]=[]
var clock101 := 0.
var scan_left := 0.
var move_left := 0.
var flight_updates := 0
var rng := RandomNumberGenerator.new()
var grove: Vector2
func point(p: Vector2,lift := 0.) -> Vector3:
 var at := grove+p
 return Vector3(at.x,world.floor_height(at)+lift,at.y)
func _ready() -> void:
 name="WoodlandDetails101";grove=world.meadow.landmarks.grove;rng.seed=10173
 var atlas: Texture2D=load("res://assets/woodland101/woodland_details101.png")
 var source := atlas.get_image();var half := source.get_width()/2
 for cell in [Vector2i(0,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
  var rect := Rect2i(cell*half,Vector2i(half,half))
  var bounds := source.get_region(rect).get_used_rect()
  var texture := AtlasTexture.new();texture.atlas=atlas;texture.region=Rect2(rect.position+bounds.position,bounds.size);textures.append(texture)
 for at in [Vector2(-9.5,5.4),Vector2(-8.3,7.5),Vector2(12.9,-2.3),Vector2(7.8,-7.6)]: _prop(at,0,rng.randf_range(.36,.49))
 for at in [Vector2(-3.8,9.2),Vector2(10.4,-1.1),Vector2(-10.3,7.)]: _prop(at,1,rng.randf_range(.32,.43))
 for at in [Vector2(-7.2,7.8),Vector2(-8.9,6.),Vector2(12.6,-1.7),Vector2(10.6,-1.8),Vector2(7.4,-8.2)]: _leaf(at,rng.randf_range(.75,1.05))
 _edges()
 _butterflies()
 audio=_audio_script101().new();audio.world=world;add_child(audio)
func _prop(at: Vector2,kind: int,width: float) -> void:
 var sprite := Sprite3D.new();sprite.texture=textures[kind];sprite.pixel_size=width/sprite.texture.get_width()
 sprite.offset.y=sprite.texture.get_height()*.5;sprite.position=point(at,.004);sprite.visibility_range_end=40.
 var mat := ShaderMaterial.new();mat.shader=preload("res://scripts/art/forest_receiver95.gdshader");mat.set_shader_parameter("paint",sprite.texture);mat.set_shader_parameter("tint",Vector3(.78,.85,.73))
 world.porch49.shade_material(mat);sprite.material_override=mat;sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON
 add_child(sprite);props.append(sprite)
 var contact := MeshInstance3D.new();var quad := PlaneMesh.new();quad.size=Vector2(width*.85,width*.48);contact.mesh=quad
 contact.position=point(at,.012);contact.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;contact.visibility_range_end=40.
 var soft := ShaderMaterial.new();soft.shader=preload("res://scripts/art/forest_contact87.gdshader");soft.set_shader_parameter("opacity87",.12);contact.material_override=soft;add_child(contact)
func _leaf(at: Vector2,width: float) -> void:
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var yaw := rng.randf_range(-PI,PI)
 for z in 4:
  for x in 4:
   for corner in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
    var uv: Vector2=(Vector2(x,z)+corner)/4.
    var offset: Vector2=((uv-Vector2.ONE*.5)*width).rotated(yaw)
    st.set_uv(uv);st.set_normal(Vector3.UP);st.add_vertex(point(at+offset,.018)-point(at))
 var mesh := MeshInstance3D.new();mesh.mesh=st.commit();mesh.position=point(at);mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;mesh.visibility_range_end=40.
 var mat := ShaderMaterial.new();mat.shader=preload("res://scripts/art/woodland_floor101.gdshader");mat.set_shader_parameter("paint",textures[2]);world.porch49.shade_material(mat);mesh.material_override=mat;add_child(mesh);leaves.append(mesh)
func _batch(mesh: Mesh,poses: Array[Transform3D],material: Material,cast: bool) -> MultiMeshInstance3D:
 var mm := MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.use_custom_data=true;mm.mesh=mesh;mm.instance_count=poses.size()
 for i in poses.size():
  mm.set_instance_transform(i,poses[i]);mm.set_instance_custom_data(i,Color(rng.randf(),rng.randf(),.75,1.))
 var node := MultiMeshInstance3D.new();node.multimesh=mm;node.material_override=material;node.visibility_range_end=46.;node.position=Vector3(grove.x,0,grove.y)
 node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON if cast else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 add_child(node);return node
func _edges() -> void:
 var stones: Array[Transform3D]=[];var blades: Array[Transform3D]=[]
 for centre in [Vector2(-6.8,2.),Vector2(-4.9,6.2),Vector2(6.9,2.),Vector2(8.6,4.1),Vector2(9.7,7.)]:
  for i in 28:
   var at: Vector2=centre+Vector2(rng.randf_range(-1.1,1.1),rng.randf_range(-.65,.65))
   if world.meadow.normal_at(grove.x+at.x,grove.y+at.y,true).y<.93 or world.PARK99.on_stairs99(at): continue
   var origin := point(at)-Vector3(grove.x,0,grove.y)
   var basis := Basis(Vector3.UP,rng.randf_range(-PI,PI))
   if i<5:
    var size := rng.randf_range(.14,.28)
    stones.append(Transform3D(basis.scaled(Vector3(size,rng.randf_range(.07,.13),size*.8)),origin+Vector3.UP*.025))
   elif world.PARK99.path_distance99(at)>.88:
    blades.append(Transform3D(basis.scaled(Vector3.ONE*rng.randf_range(.45,.8)),origin))
 var rock := SphereMesh.new();rock.radius=.5;rock.height=1.;rock.radial_segments=7;rock.rings=3
 pebbles=_batch(rock,stones,world.park99.stone97,true);pebbles.name="LowPathPebbles101"
 grass=_batch(world.meadow.blades(2),blades,world.grass_material,false);grass.name="ReactivePathGrass101"
func _butterflies() -> void:
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 # Each wing has a centre edge: moving only the two outer edges would
 # translate a single quad vertically rather than actually fold its wings.
 for side in 2:
  for corner in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
   var uv: Vector2=Vector2((float(side)+corner.x)*.5,corner.y)
   st.set_normal(Vector3.UP);st.set_uv(uv);st.add_vertex(Vector3((uv.x-.5)*.28,0,(uv.y-.5)*.28*textures[3].get_height()/textures[3].get_width()))
 var poses: Array[Transform3D]=[]
 for at in [Vector2(4.3,.7),Vector2(-4.5,7.8),Vector2(8.4,-2.7)]:
  centres.append(point(at,.7));poses.append(Transform3D(Basis.IDENTITY,centres[-1]-Vector3(grove.x,0,grove.y)))
 butterfly_material=ShaderMaterial.new();butterfly_material.shader=preload("res://scripts/art/woodland_floor101.gdshader");butterfly_material.set_shader_parameter("paint",textures[3]);butterfly_material.set_shader_parameter("butterfly",true);world.porch49.shade_material(butterfly_material)
 butterflies=_batch(st.commit(),poses,butterfly_material,false);butterflies.name="ThreeLocalButterflies101"
func _process(delta: float) -> void:
 clock101+=delta;scan_left-=delta;move_left-=delta
 if scan_left<=0.:
  scan_left=.25
  var day: bool=world.time55.visual_hour>7. and world.time55.visual_hour<19.
  for i in 3:
   active[i]=day and world.hero.global_position.distance_to(centres[i])<28. and world.effect_scope95.near_view95(centres[i],3.)
   if not active[i]: butterflies.multimesh.set_instance_transform(i,Transform3D(Basis(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO),Vector3.ZERO))
 if not active.has(true): return
 butterfly_material.set_shader_parameter("wing_clock",clock101)
 if move_left>0.: return
 move_left=.1
 for i in 3:
  if not active[i]: continue
  var t := clock101*.65+i*2.17
  var pos := centres[i]+Vector3(sin(t)*.65,sin(t*2.7)*.16,cos(t*.87)*.5)
  var basis := Basis(Vector3.UP,atan2(-cos(t),sin(t*.87)))
  butterflies.multimesh.set_instance_transform(i,Transform3D(basis,pos-butterflies.position));flight_updates+=1

func _audio_script101() -> Script: return preload("res://scripts/art/woodland_audio101.gd")
