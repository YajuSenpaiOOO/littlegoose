extends CharacterBody3D
## One-direction map placement preview, not a Boss or mount controller.
var world: Node3D
var visual: Sprite3D
var ink: ShaderMaterial
var shadow: MeshInstance3D
var data: Dictionary
var atlas_frames: Array[AtlasTexture]=[]
var sheet: Texture2D
var original: Texture2D
var origin216 := Vector2.ZERO
var goal216 := Vector2.ZERO
var width216 := 3.0
var clock216 := 0.
var frame216 := -1
var running216 := true
var moving216 := false
var original216 := false
var manual216 := false
var blocked216 := false
func _ready() -> void:
 name="FatCat216"
 collision_layer=1;collision_mask=1|2
 physics_interpolation_mode=Node.PHYSICS_INTERPOLATION_MODE_OFF
 var collision=CollisionShape3D.new();var shape=CylinderShape3D.new();shape.radius=.70;shape.height=.60
 collision.shape=shape;collision.position.y=.30;add_child(collision)
 data=JSON.parse_string(FileAccess.get_file_as_string("res://assets/fat_cat216/frames.json"))
 sheet=load("res://assets/fat_cat216/walk_sheet.png");original=load("res://assets/fat_cat216/original.png")
 for f in data.frames:
  var rect: Array=f.region
  var atlas=AtlasTexture.new();atlas.atlas=sheet;atlas.region=Rect2(rect[0],rect[1],rect[2],rect[3]);atlas.filter_clip=true;atlas_frames.append(atlas)
 visual=Sprite3D.new();visual.layers=1;visual.shaded=true;visual.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
 visual.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;visual.extra_cull_margin=2.;add_child(visual)
 ink=ShaderMaterial.new();ink.shader=preload("res://scripts/art/sister_receiver207.gdshader");visual.material_override=ink
 shadow=preload("res://scripts/combat/actor_shadow105.gd").new();shadow.battle=world;shadow.visual=visual;shadow.opacity_scale=.60;add_child(shadow)
 reset216()
func reset216() -> void:
 global_position=Vector3(origin216.x,world.floor_height(origin216),origin216.y)
 clock216=0.;moving216=false;blocked216=false;running216=true;velocity=Vector3.ZERO
 update_visual216()
func _physics_process(delta: float) -> void:
 if not manual216: advance216(delta)
func advance216(delta: float) -> void:
 if not running216: return
 clock216+=delta
 if moving216:
  var at=Vector2(global_position.x,global_position.z)
  var step=(goal216-at).limit_length(.65*delta)
  var next=at+step
  var h: float=world.floor_height(next)
  if at.distance_to(goal216)<.04:
   moving216=false
  elif absf(h-global_position.y)>.20:
   moving216=false;blocked216=true
  else:
   var hit=move_and_collide(Vector3(step.x,h-global_position.y,step.y))
   if hit!=null: moving216=false;blocked216=true
 update_visual216()
func update_visual216() -> void:
 if not is_instance_valid(visual): return
 var index=int(clock216*14.)%6
 if original216:
  visual.texture=original
  var b: Array=data.original_bounds
  visual.pixel_size=width216/float(b[2])
  var foot=Vector2(float(b[0])+float(b[2])*.46,float(b[1])+float(b[3])*.98)
  visual.offset=Vector2(original.get_width()*.5-foot.x,foot.y-original.get_height()*.5)
  ink.set_shader_parameter("paint",original)
 else:
  visual.texture=atlas_frames[index]
  var f: Dictionary=data.frames[index]
  # Register upper body exactly as the approved 215 loop, with a fixed virtual sole.
  var foot=Vector2(float(f.anchor[0])-25.,float(f.anchor[1])+295.)
  var size=visual.texture.get_size()
  visual.pixel_size=width216/558.
  visual.offset=Vector2(size.x*.5-foot.x,foot.y-size.y*.5)
  ink.set_shader_parameter("paint",sheet)
 frame216=index
func _process(_delta: float) -> void:
 if not is_instance_valid(visual) or not is_instance_valid(world.camera): return
 visual.global_basis=world.camera.global_basis
 visual.global_position=global_position+Vector3.UP*.025
 ink.set_shader_parameter("foot199",global_position)
 ink.set_shader_parameter("camera199",world.camera.global_position)
 var normal=world.camera.global_basis.z;normal.y=0.
 ink.set_shader_parameter("plane_normal199",normal.normalized())
 var light_normal=world.hero.visual.global_basis*Vector3(0.,sin(deg_to_rad(25.)),cos(deg_to_rad(25.)))
 ink.set_shader_parameter("receiver_normal207",light_normal.normalized())
