extends Node3D
## Small lived-in edges: a picnic under trees, two warm lamps, and a future seat.
var world: Node3D
const PICNIC144=Vector2(-16.7,-28.3)
const ENTRY144=Vector2(-20.8,-14.1)
const SEAT144=Vector2(-24.,-28.3)
const CLOTH_SIZE144=Vector2(2.9,2.15)
const CLOTH_YAW144=-.15
var cloth144: MeshInstance3D
var basket144: Sprite3D
var floor_lamp144: Sprite3D
var branch_lamp144: Sprite3D
var lamps144: Array[OmniLight3D]=[]
var lamp_inks144: Array[ShaderMaterial]=[]
var bodies144: Array[StaticBody3D]=[]
var seat144: Sprite3D
var seats144: Array[Marker3D]=[]
var cleared_ferns144 := 0
var regions144: Dictionary
var cloth_samples144: Array[Vector3]=[]
func point144(p: Vector2,lift := 0.) -> Vector3:
 var at: Vector2=Vector2(world.meadow.landmarks.grove)+p
 return Vector3(at.x,world.floor_height(at)+lift,at.y)
func in_cloth144(at: Vector3,margin := .15) -> bool:
 var p: Vector2=(Vector2(at.x,at.z)-Vector2(world.meadow.landmarks.grove)-PICNIC144).rotated(-CLOTH_YAW144)
 return absf(p.x)<CLOTH_SIZE144.x*.5+margin and absf(p.y)<CLOTH_SIZE144.y*.5+margin
func crop144(label: String) -> Texture2D:
 var image: Image=load("res://assets/picnic144/"+label+".png").get_image()
 if image.is_compressed(): image.decompress()
 var box: Array=regions144[label];var tile := image.get_region(Rect2i(box[0],box[1],box[2],box[3]));tile.generate_mipmaps()
 return ImageTexture.create_from_image(tile)
func body144(p: Vector2,radius: float,height: float,tag: String) -> StaticBody3D:
 var body := StaticBody3D.new();body.name=tag;body.collision_layer=2;body.collision_mask=0
 var shape := CylinderShape3D.new();shape.radius=radius;shape.height=height
 var collider := CollisionShape3D.new();collider.shape=shape;body.add_child(collider);add_child(body)
 body.position=point144(p,height*.5);bodies144.append(body);return body
func sprite144(texture: Texture2D,p: Vector2,width: float,tag: String) -> Sprite3D:
 var sprite: Sprite3D=world.forest87._sprite87(texture,Vector2(world.meadow.landmarks.grove)+p,width,tag)
 sprite.position.y=world.floor_height(Vector2(sprite.position.x,sprite.position.z))+.055
 world.garden._contact(self,Vector2(sprite.position.x,sprite.position.z),Vector2(width*.48,width*.18),.027,.15)
 var shadow := preload("res://scripts/art/grounded_prop_shadow63.gd").new();shadow.world=world;shadow.visual=sprite;add_child(shadow)
 return sprite
func clear_cloth144() -> void:
 for batch in world.grass_batches:
  for i in batch.node.multimesh.instance_count:
   var pose: Transform3D=batch.node.multimesh.get_instance_transform(i)
   if in_cloth144(batch.node.to_global(pose.origin)):
    pose.basis=Basis(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO);batch.node.multimesh.set_instance_transform(i,pose)
 for batch in world.hill_plants142.batches107:
  for i in batch.multimesh.instance_count:
   var pose: Transform3D=batch.multimesh.get_instance_transform(i)
   if in_cloth144(batch.to_global(pose.origin)):
    pose.basis=Basis(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO);batch.multimesh.set_instance_transform(i,pose)
 for body in world.hill_plants142.shrub_bodies143:
  if in_cloth144(body.global_position): body.collision_layer=0;cleared_ferns144+=1
func cloth_mesh144() -> ArrayMesh:
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for y in 16:
  for x in 20:
   for corner in [Vector2(0,0),Vector2(0,1),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(1,0)]:
    var uv: Vector2=(Vector2(x,y)+corner)/Vector2(20,16)
    var edge := maxf(absf(uv.x-.5)*2.,absf(uv.y-.5)*2.)
    var local: Vector2=(uv-Vector2(.5,.5))*CLOTH_SIZE144
    local+=Vector2(sin(uv.y*30.)*.018,sin(uv.x*35.)*.014)*smoothstep(.85,1.,edge)
    var p: Vector2=PICNIC144+local.rotated(CLOTH_YAW144)
    var at: Vector3=point144(p,.035);cloth_samples144.append(at)
    var world_at: Vector2=Vector2(at.x,at.z)
    st.set_normal(world.meadow.normal_at(world_at.x,world_at.y,true));st.set_uv(uv);st.add_vertex(at)
 return st.commit()
func light144(p: Vector2,lift: float,range_value: float) -> OmniLight3D:
 var light := OmniLight3D.new();light.name="WarmPicnicLamp144";light.position=point144(p,lift)
 light.light_color=Color("ffd09a");light.omni_range=range_value;light.omni_attenuation=1.6;light.shadow_enabled=false
 add_child(light);lamps144.append(light);return light
func _ready() -> void:
 name="PicnicAndSeaSeat144"
 regions144=JSON.parse_string(FileAccess.get_file_as_string("res://assets/picnic144/regions.json"))
 clear_cloth144()
 cloth144=MeshInstance3D.new();cloth144.name="GroundFollowingFadedGingham144";cloth144.mesh=cloth_mesh144()
 var cloth_ink := ShaderMaterial.new();cloth_ink.shader=preload("res://scripts/art/picnic_cloth144.gdshader");world.porch49.shade_material(cloth_ink)
 cloth144.material_override=cloth_ink;cloth144.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(cloth144)
 basket144=sprite144(crop144("picnic"),PICNIC144+Vector2(-.30,-.18),1.28,"HalfOpenBasketAndTwoMugs144")
 body144(PICNIC144+Vector2(-.30,-.18),.37,.55,"PicnicBasketFootprint144")
 # The blanket itself stays walkable. Only the solid props get narrow footprints.
 floor_lamp144=sprite144(crop144("lantern"),PICNIC144+Vector2(1.03,-.05),.36,"GroundPicnicLantern144")
 body144(PICNIC144+Vector2(1.03,-.05),.13,.50,"GroundLanternFootprint144")
 var lantern_ink := ShaderMaterial.new();lantern_ink.shader=preload("res://scripts/art/picnic_lantern144.gdshader")
 lantern_ink.set_shader_parameter("paint",floor_lamp144.texture);world.porch49.shade_material(lantern_ink);floor_lamp144.material_override=lantern_ink;lamp_inks144.append(lantern_ink)
 light144(PICNIC144+Vector2(1.03,.02),.42,3.6)
 var branch_root := Node3D.new();branch_root.position=point144(ENTRY144);add_child(branch_root)
 branch_lamp144=world._sprite(preload("res://assets/woodland107/branch_lantern107.png"),Vector2(512,1518),2.50,1510.)
 branch_lamp144.billboard=BaseMaterial3D.BILLBOARD_DISABLED;branch_lamp144.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;branch_root.add_child(branch_lamp144)
 var branch_ink := ShaderMaterial.new();branch_ink.shader=preload("res://scripts/art/lantern107.gdshader");branch_ink.set_shader_parameter("paint",branch_lamp144.texture);world.porch49.shade_material(branch_ink);branch_lamp144.material_override=branch_ink;lamp_inks144.append(branch_ink)
 body144(ENTRY144,.13,2.45,"SummitEntryLampPost144");light144(ENTRY144+Vector2(.38,.08),1.65,4.1)
 world.garden._contact(self,Vector2(branch_root.position.x,branch_root.position.z),Vector2(.32,.19),.02,.15)
 # Reuse the painted low rock, buried further into the soil instead of a raised platform.
 var contacts := SurfaceTool.new();contacts.begin(Mesh.PRIMITIVE_TRIANGLES)
 var before: int=world.forest87.rocks87.size()
 world.forest87._rock87(Vector2(world.meadow.landmarks.grove)+SEAT144,2.10,2,contacts)
 if world.forest87.rocks87.size()>before:
  var entry: Dictionary=world.forest87.rocks87[-1];seat144=entry.visual
  seat144.position.y-=.18;entry.body.position.y-=.18;seat144.name="TwoPersonLowSeaSeat144"
  world.park99.sit_point141.global_position=point144(SEAT144,.38)
  world.park99.sit_point141.set_meta("purpose","Reserved two-person sea-view story seat; no interaction yet.")
  for x in [-.42,.42]:
   var marker := Marker3D.new();marker.name="FutureSeatedPerson144";add_child(marker);marker.position=point144(SEAT144+Vector2(x,0),.38);seats144.append(marker)
 for offset in [Vector2(-1.24,.78),Vector2(.98,.81)]:
  world.forest87._rock87(Vector2(world.meadow.landmarks.grove)+PICNIC144+offset,.32,2,contacts)
 var contact_mesh := contacts.commit()
 if contact_mesh!=null:
  var node := MeshInstance3D.new();node.mesh=contact_mesh;node.material_override=world.forest87.contact_material87;node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(node)
 update_lights144();print("PICNIC144_READY cleared_ferns=",cleared_ferns144," seats=",seats144.size())
func update_lights144() -> void:
 var hour: float=world.time55.visual_hour
 var night := maxf(smoothstep(16.,19.,hour),1.-smoothstep(5.,8.,hour))
 for i in lamps144.size():
  var near: bool=world.hero.global_position.distance_squared_to(lamps144[i].global_position)<35.*35.
  lamps144[i].visible=near;lamps144[i].light_energy=lerpf(.04,1.45 if i==0 else 1.8,night) if near else 0.
  lamp_inks144[i].set_shader_parameter("glow144" if i==0 else "glow106",lerpf(.08,1.35,night))
func _process(_delta: float) -> void:
 if cloth144!=null: cloth144.material_override.set_shader_parameter("clock",world.clock)
 update_lights144()

