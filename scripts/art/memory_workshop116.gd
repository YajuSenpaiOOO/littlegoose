extends Node3D
class Prop116:
 extends Node3D
 var shadow: MeshInstance3D
 var visual: Sprite3D
var world: Node3D
var pot: Prop116
var tin: Prop116
var steam_root: Node3D
var steam_materials: Array[ShaderMaterial]=[]
var steam_clock := 0.
var proximity_check := 0.
var steam_active := false
var effect_ticks := 0
var floor_targets: Array[Vector2]=[]
func _ready() -> void:
 name="MemoryWorkshop116"
 pot=prop116("StumpMagicPot","stump_pot.png",Rect2(94,111,1260,882),Vector2(-8.7,-2.8),1.75,Vector3(1.65,.82,1.12))
 tin=prop116("BiscuitTreasureTin","biscuit_tin.png",Rect2(151,115,1015,1047),Vector2(-7.3,-2.4),.93,Vector3(.95,.4,.65))
 steam_root=Node3D.new();pot.add_child(steam_root)
 # Pot mouth in the cropped sprite's coordinates; use its actual tilted transform.
 steam_root.position=pot.visual.transform*Vector3(.03,1.75*.73,0.)
 for i in 5:
  var node := MeshInstance3D.new();var quad := QuadMesh.new();quad.size=Vector2(.30,.38) if i<3 else Vector2(.10,.06);node.mesh=quad
  node.rotation_degrees.x=-25.;node.position=Vector3((i%3-1)*.085,.015 if i<3 else -.02,0.)
  var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/art/workshop_steam116.gdshader");ink.set_shader_parameter("phase116",i*.31);ink.set_shader_parameter("bubble116",i>=3)
  node.material_override=ink;node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;node.extra_cull_margin=.8;steam_root.add_child(node);steam_materials.append(ink)
func prop116(label: String,file: String,region: Rect2,at: Vector2,height: float,body_size: Vector3) -> Prop116:
 var root := Prop116.new();root.name=label;root.position=Vector3(at.x,world.floor_height(at)+.025,at.y);add_child(root);floor_targets.append(at)
 var sprite := Sprite3D.new();var texture := AtlasTexture.new();texture.atlas=load("res://assets/memory_workshop116/"+file);texture.region=region
 sprite.texture=texture;sprite.pixel_size=height/region.size.y;sprite.offset=Vector2(0,region.size.y*.5);sprite.rotation_degrees.x=-25.
 sprite.shaded=true;sprite.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD;sprite.alpha_scissor_threshold=.12;sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
 sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON;root.add_child(sprite);root.visual=sprite
 var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/art/forest_cutout13.gdshader");ink.set_shader_parameter("paint",texture.atlas);ink.set_shader_parameter("alpha_threshold",.12)
 sprite.material_override=ink;world.porch49.shade_material(ink)
 var body := StaticBody3D.new();body.collision_layer=2;body.collision_mask=0;root.add_child(body)
 var shape := BoxShape3D.new();shape.size=body_size;var collider := CollisionShape3D.new();collider.shape=shape;collider.position.y=body_size.y*.5;body.add_child(collider)
 world._add_actor_shadow(root,sprite)
 return root
func near() -> bool:
 if not is_instance_valid(world.hero): return false
 var at := Vector2(world.hero.position.x,world.hero.position.z)
 return at.distance_to(Vector2(tin.position.x,tin.position.z))<2.9 or at.distance_to(Vector2(pot.position.x,pot.position.z))<2.6
func _process(delta: float) -> void:
 proximity_check-=delta
 if proximity_check<=0.:
  proximity_check=.25
  steam_active=world.hero.position.distance_squared_to(pot.position)<400. and world.camera.is_position_in_frustum(pot.global_position+Vector3.UP)
  steam_root.visible=steam_active
 if not steam_active: return
 steam_clock+=delta;effect_ticks+=1
 for ink in steam_materials: ink.set_shader_parameter("clock116",steam_clock)
