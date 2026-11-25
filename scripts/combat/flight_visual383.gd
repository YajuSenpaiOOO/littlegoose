extends Node3D
# Portable 382 visual rig; owns no room/gameplay systems.
var battle: Node3D
var rig379: Node3D
var body379: Sprite3D
var wing379: Sprite3D
var far381: Sprite3D
var hair382: Sprite3D
var shadow380: MeshInstance3D
var ink380: ShaderMaterial
var frames379: Array[Texture2D]=[]
var near_frames381: Array[Texture2D]=[]
var far_frames381: Array[Texture2D]=[]
var front_frames381: Array[Texture2D]=[]
var front_body381: Texture2D
var direction381:=3
var index379:=0
var initialized381:=false
var fixed382:=true
var clock380:=0.0
var age379:=0.0
var camera: Camera3D
var heading383:=Vector2(0,1)
const ROOTS379=[Vector2(384,304),Vector2(384,304),Vector2(384,272),Vector2(384,272)]
func _ready() -> void:
 rig379=self;camera=battle.camera
 process_priority=200
 physics_interpolation_mode=Node.PHYSICS_INTERPOLATION_MODE_OFF
 front_body381=atlas381(preload("res://assets/black_goose_flight378/parts.png"),Rect2(0,0,550,1024))
 body379=sprite379(front_body381,Vector2(300,935),1.44/860.)
 for i in 4:front_frames381.append(atlas381(preload("res://assets/black_goose_flight379/wings.png"),Rect2((i%2)*768,(i/2)*512,768,512)))
 frames379.assign(front_frames381)
 wing379=sprite379(frames379[0],ROOTS379[0],.0019)
 far381=sprite379(frames379[0],ROOTS379[0],.0019)
 hair382=sprite379(front_body381,Vector2(300,935),1.44/860.)
 shadow380=MeshInstance3D.new();shadow380.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 ink380=ShaderMaterial.new();ink380.shader=preload("res://scripts/art/flight_shadow381.gdshader");shadow380.material_override=ink380;battle.add_child(shadow380)
 initialized381=true;set_direction381(3)
func sprite379(texture: Texture2D, anchor: Vector2, density: float) -> Sprite3D:
 var s:=Sprite3D.new();s.texture=texture;s.pixel_size=density;s.offset=Vector2(texture.get_width()*.5-anchor.x,anchor.y-texture.get_height()*.5)
 s.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;s.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;s.layers=1|(1<<19)
 var ink=preload("res://scripts/combat/hero192.gd").make_receiver192();ink.albedo_texture=texture.atlas if texture is AtlasTexture else texture;s.material_override=ink;s.shaded=true;add_child(s);return s
func refresh367() -> void:pass
func _exit_tree() -> void:
 if is_instance_valid(shadow380):shadow380.queue_free()
func face383(vector: Vector3) -> void:
 var v:=Vector2(vector.x,vector.z)
 if v.length()<.15:return
 var horizontal: bool=direction381==0 or direction381==2
 var d: int=direction381
 if horizontal:
  if absf(v.y)>absf(v.x)*1.2:d=1 if v.y<0 else 3
  elif absf(v.x)>.12:d=0 if v.x<0 else 2
 else:
  if absf(v.x)>absf(v.y)*1.2:d=0 if v.x<0 else 2
  elif absf(v.y)>.12:d=1 if v.y<0 else 3
 if d!=direction381:set_direction381(d)
 heading383=v.normalized()
func muzzle383() -> Vector3:
 return to_global(Vector3(heading383.x*.18,.44,heading383.y*.12))
func _process(delta: float) -> void:
 if not initialized381:return
 if not battle.combat_paused:
  clock380+=delta;age379+=delta;show_frame379(int(age379/.14)%4)
 position=Vector3(sin(clock380*TAU*.33)*.012,sin(clock380*TAU*.65)*.045+sin(age379*TAU/.56-1.)*.009,0)
 rotation.z=sin(clock380*TAU*.43)*.012
 var elastic:=sin(clock380*TAU*.8)*.005+sin(age379*TAU/.56-.5)*.008
 scale=Vector3(1.-elastic,1.+elastic,1.)
 align_hair382();update_shadow380()
func atlas381(sheet: Texture2D, rect: Rect2) -> AtlasTexture:
 var tex:=AtlasTexture.new();tex.atlas=sheet;tex.region=rect;return tex
func set_direction381(value: int) -> void:
 direction381=posmod(value,4);near_frames381.clear();far_frames381.clear()
 var side: bool=direction381==0 or direction381==2
 if direction381==3:
  body379.texture=front_body381;body379.offset=Vector2(-25,423);body379.pixel_size=1.44/860.
  frames379.assign(front_frames381);wing379.pixel_size=.0019;wing379.position=Vector3(-25.*1.44/860.,.70,-.025)
 else:
  var col: int=0 if direction381==0 else (2 if direction381==1 else 1)
  body379.texture=atlas381(preload("res://assets/black_goose_flight381/bodies.png"),Rect2(col*512,0,512,1024));body379.pixel_size=1.44/830.;body379.offset=Vector2(0,418)
  var sheet: Texture2D=load("res://assets/black_goose_flight381/"+(["left-wings.png","back-wings.png","right-wings.png"][direction381]))
  frames379.clear()
  for i in 4:
   if side:
    near_frames381.append(atlas381(sheet,Rect2((i%2)*768+4,(i/2)*512+4,376,504)))
    far_frames381.append(atlas381(sheet,Rect2((i%2)*768+388,(i/2)*512+4,376,504)))
    frames379.append(near_frames381[-1])
   else:frames379.append(atlas381(sheet,Rect2((i%2)*768,(i/2)*512,768,512)))
  wing379.pixel_size=.0021 if side else .0019
  wing379.position=Vector3(.055 if direction381==0 else (-.035 if direction381==2 else 0.),.65 if side else .68,.018 if side else -.025)
 body379.material_override.albedo_texture=body379.texture.atlas
 far381.visible=side
 if side:
  far381.pixel_size=.0021;far381.position=Vector3(wing379.position.x+(-.075 if direction381==0 else .075),.73,-.04)
 show_frame379(index379);update_shadow380();apply_order382()
func show_frame379(i: int) -> void:
 if not initialized381:return
 index379=posmod(i,4);wing379.texture=frames379[index379];wing379.material_override.albedo_texture=wing379.texture.atlas
 if direction381==3:wing379.offset=Vector2(0,ROOTS379[index379].y-256.);return
 var y: float=304. if index379<2 else 272.
 if direction381==1:wing379.offset=Vector2(0,y-256.);return
 var nx: float=70. if direction381==0 else 355.
 var fx: float=70. if direction381==0 else 276.
 wing379.offset=Vector2(188.-(nx-4.),y-4.-252.)
 far381.texture=far_frames381[index379];far381.material_override.albedo_texture=far381.texture.atlas
 far381.offset=Vector2(188.-(fx-4.),y-4.-252.)
func apply_order382() -> void:
 if not is_instance_valid(hair382):return
 hair382.visible=false
 if fixed382:
  if direction381==0 or direction381==2:
   # Both wings emerge from the back: the outer arm/sleeve occludes the root.
   wing379.position.z=-.018
  elif direction381==1:
   # Seen from behind, the wings are closer than the back, but below the hair.
   wing379.position=Vector3(0,.70,.018)
   var tex:=atlas381(preload("res://assets/black_goose_flight381/bodies.png"),Rect2(1024,0,512,570))
   hair382.texture=tex;hair382.pixel_size=body379.pixel_size
   hair382.offset=Vector2(0,930.-285.)
   hair382.material_override.albedo_texture=tex.atlas;hair382.visible=true
 align_hair382()
 update_shadow380()
func align_hair382() -> void:
 if not is_instance_valid(hair382) or not hair382.visible:return
 # Homothety towards camera preserves exact screen registration of source pixels.
 # This avoids the duplicate outline caused by simply moving the upper layer in Z.
 var camera_local: Vector3=rig379.to_local(camera.global_position)
 var ratio:=.04/maxf(.1,camera_local.z)
 hair382.position=camera_local*ratio;hair382.scale=Vector3.ONE*(1.-ratio)
func bind_shadow380(prefix: String, visual: Sprite3D) -> void:
 var tex: AtlasTexture=visual.texture
 ink380.set_shader_parameter(prefix+"_tex",tex.atlas)
 var size:=tex.atlas.get_size()
 ink380.set_shader_parameter(prefix+"_region",Vector4(tex.region.position.x/size.x,tex.region.position.y/size.y,tex.region.size.x/size.x,tex.region.size.y/size.y))
 ink380.set_shader_parameter(prefix+"_inverse",visual.global_transform.affine_inverse())
 ink380.set_shader_parameter(prefix+"_layout",Vector4(tex.region.size.x,tex.region.size.y,visual.offset.x,visual.offset.y))
 ink380.set_shader_parameter(prefix+"_density",visual.pixel_size)

func update_shadow380() -> void:
 if not is_instance_valid(shadow380) or not initialized381:return
 shadow380.visible=is_visible_in_tree() and battle.contact_enabled
 var ray: Vector3=-battle.sun.global_basis.z.normalized()
 ink380.set_shader_parameter("light_ray",ray)
 bind_shadow380("body",body379);bind_shadow380("wing",wing379);bind_shadow380("far",far381)
 ink380.set_shader_parameter("far_weight",1. if far381.visible else 0.)
 var low:=Vector2(INF,INF);var high:=Vector2(-INF,-INF)
 var origin: Vector3=global_position
 var base: float=battle.floor_height(Vector2(origin.x,origin.z))+.022
 for visual in [body379,wing379,far381]:
  if not visual.visible:continue
  var size: Vector2=visual.texture.get_size()
  for uv in [Vector2.ZERO,Vector2(1,0),Vector2.ONE,Vector2(0,1)]:
   var p: Vector3=visual.to_global(Vector3(((uv.x-.5)*size.x+visual.offset.x)*visual.pixel_size,((.5-uv.y)*size.y+visual.offset.y)*visual.pixel_size,0))
   p+=ray*((base-p.y)/ray.y);low=low.min(Vector2(p.x,p.z));high=high.max(Vector2(p.x,p.z))
 low-=Vector2(.08,.08);high+=Vector2(.08,.08)
 var points:=PackedVector3Array()
 for y in 5:
  for x in 5:
   var at: Vector2=low+(high-low)*Vector2(x,y)/4.
   points.append(Vector3(at.x,battle.floor_height(at)+.022,at.y))
 var vertices:=PackedVector3Array()
 for y in 4:
  for x in 4:
   for off in [Vector2i.ZERO,Vector2i(1,0),Vector2i(1,1),Vector2i.ZERO,Vector2i(1,1),Vector2i(0,1)]:vertices.append(points[(y+off.y)*5+x+off.x])
 if shadow380.mesh==null:
  var arrays:=[];arrays.resize(Mesh.ARRAY_MAX);arrays[Mesh.ARRAY_VERTEX]=vertices
  shadow380.mesh=ArrayMesh.new();shadow380.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays,[],{},Mesh.ARRAY_FLAG_USE_DYNAMIC_UPDATE)
 else:shadow380.mesh.surface_update_vertex_region(0,0,vertices.to_byte_array())
 shadow380.custom_aabb=AABB(Vector3(low.x,base-2.,low.y),Vector3(high.x-low.x,4.,high.y-low.y))
