extends Node3D
var world: Node3D
var rig: Node3D
var records: Array[Dictionary]=[]
var texture206: Texture2D
var bounds206: Rect2i
var invulnerability206 := 0.
var manual206 := false
var spawned206 := 0
var hits206 := 0
var dodges206 := 0
var parries206 := 0

func _ready() -> void:
 name="PlushDrops206";texture206=load("res://assets/sister206/seal.png")
 bounds206=rig.opaque_bounds(texture206.get_image())

func spawn206(at: Vector2,from: Vector3) -> void:
 if records.size()>=4: return
 var root=Node3D.new();root.name="SealPlush206";add_child(root)
 var card=Sprite3D.new();card.texture=texture206;card.layers=1;card.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 card.pixel_size=.58/bounds206.size.y;card.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
 var foot=Vector2(bounds206.position)+Vector2(bounds206.size)*Vector2(.5,1.)
 card.offset=Vector2(texture206.get_width()*.5-foot.x,foot.y-texture206.get_height()*.5)
 var ink=ShaderMaterial.new();ink.shader=preload("res://scripts/art/transport_card206.gdshader");ink.set_shader_parameter("paint",texture206);card.material_override=ink;root.add_child(card)
 var shadow=preload("res://scripts/combat/actor_shadow105.gd").new();shadow.battle=world;shadow.visual=card;shadow.opacity_scale=.4;root.add_child(shadow)
 var warning=MeshInstance3D.new();var torus=TorusMesh.new();torus.inner_radius=.55;torus.outer_radius=.59;torus.rings=32;torus.ring_segments=6;warning.mesh=torus
 var color=StandardMaterial3D.new();color.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;color.albedo_color=Color("efc5b8");warning.material_override=color;warning.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;root.add_child(warning)
 var ground=Vector3(at.x,world.floor_height(at),at.y)
 root.global_position=ground
 var lane=MeshInstance3D.new();lane.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;lane.visible=false
 var lane_ink=StandardMaterial3D.new();lane_ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;lane_ink.albedo_color=Color("e29fba");lane.material_override=lane_ink;root.add_child(lane)
 records.append({"root":root,"card":card,"shadow":shadow,"warning":warning,"lane":lane,"ink":ink,"origin":at,"at":at,"from":from,"age":0.,"target":at,"locked":false,"resolved":false,"event":""})
 spawned206+=1

func clear206() -> void:
 for item in records: item.root.queue_free()
 records.clear();spawned206=0;hits206=0;dodges206=0;parries206=0;invulnerability206=0.

func _physics_process(delta: float) -> void:
 if not manual206 and rig.running: advance206(delta)

func advance206(delta: float) -> void:
 invulnerability206=maxf(0.,invulnerability206-delta)
 for i in range(records.size()-1,-1,-1):
  var item=records[i];var old: Vector2=item.at
  item.age+=delta
  var age: float=item.age
  if age>=1.65 and not item.locked:
   var hero_at=Vector2(world.hero.position.x,world.hero.position.z)
   item.target=safe_target206(item.origin,item.origin+(hero_at-item.origin).limit_length(2.4))
   item.locked=true
   build_lane206(item)
  if age>=2.25 and age<2.65:
   item.at=item.origin.lerp(item.target,clampf((age-2.25)/.4,0.,1.))
   if not item.resolved:
    var hero_at=Vector2(world.hero.position.x,world.hero.position.z)
    if Geometry2D.get_closest_point_to_segment(hero_at,old,item.at).distance_to(hero_at)<.48:
     resolve206(item)
  elif age>=2.65: item.at=item.target
  if age>=4.5:
   item.root.queue_free();records.remove_at(i)

func resolve206(item: Dictionary) -> void:
 item.resolved=true
 if world.hero.dodge_invulnerability>0.:
  dodges206+=1;item.event="dodge";world.notice206("闪开啦！");return
 if world.hero.can_parry():
  world.hero.consume_parry();parries206+=1;item.event="parry";item.age=2.65;item.target=item.at;world.notice206("弹反成功，玩偶软倒啦！");return
 if world.hero.guarding109:
  item.event="guard";world.notice206("挡住了软软的一扑");return
 if invulnerability206<=0.:
  invulnerability206=.7;hits206+=1;world.preview_hearts206=maxi(0,world.preview_hearts206-1)
  item.event="hit";world.notice206("被玩偶扑到了 · 仅扣试演心心")

func safe_target206(origin: Vector2,desired: Vector2) -> Vector2:
 var sphere=SphereShape3D.new();sphere.radius=.18
 var query=PhysicsShapeQueryParameters3D.new();query.shape=sphere;query.collision_mask=1
 query.exclude=[world.hero.get_rid(),rig.body.get_rid()]
 var last=origin;var floor_origin: float=world.floor_height(origin)
 for i in range(1,13):
  var point=origin.lerp(desired,float(i)/12.)
  var h: float=world.floor_height(point)
  query.transform.origin=Vector3(point.x,h+.25,point.y)
  if absf(h-floor_origin)>.35 or not world.get_world_3d().direct_space_state.intersect_shape(query,1).is_empty(): break
  last=point
 return last

func build_lane206(item: Dictionary) -> void:
 var direction: Vector2=(item.target-item.origin).normalized()
 var side=Vector2(-direction.y,direction.x)*.07
 var surface=SurfaceTool.new();surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 8:
  var a: Vector2=item.origin.lerp(item.target,float(i)/8.)
  var b: Vector2=item.origin.lerp(item.target,float(i+1)/8.)
  for point in [a-side,a+side,b+side,a-side,b+side,b-side]:
   surface.add_vertex(Vector3(point.x,world.floor_height(point)+.045,point.y)-item.root.global_position)
 item.lane.mesh=surface.commit()

func _process(_delta: float) -> void:
 if not is_instance_valid(world.camera): return
 var camera: Camera3D=world.camera
 for item in records:
  var age: float=item.age
  var at: Vector2=item.at
  var floor_y: float=world.floor_height(at)
  var ground=Vector3(at.x,floor_y,at.y)
  item.root.global_position=ground
  var card: Sprite3D=item.card
  card.global_basis=camera.global_basis
  var height=0.
  if age<1.:
   var falling: Vector3=item.from.lerp(ground,clampf(age,0.,1.))
   height=falling.y-floor_y
  elif age<1.65: height=absf(sin((age-1.)/.65*TAU))*.12
  elif age<2.25:
   card.scale=Vector3(1.12,.82,1.)
  elif age<2.65:
   height=sin(clampf((age-2.25)/.4,0.,1.)*PI)*.18
   card.scale=Vector3(1.10,.90,1.)
  else: card.scale=Vector3(1.25,.63,1.)
  if age>4.:
   var fade=1.-smoothstep(4.,4.5,age);card.scale*=maxf(fade,.001)
  card.global_position=ground+Vector3.UP*height
  var ink: ShaderMaterial=item.ink
  ink.set_shader_parameter("foot199",ground);ink.set_shader_parameter("camera199",camera.global_position)
  ink.set_shader_parameter("plane_normal199",Vector3(camera.global_basis.z.x,0.,camera.global_basis.z.z).normalized())
  var warning: MeshInstance3D=item.warning
  warning.global_position=Vector3(item.origin.x,world.floor_height(item.origin)+.035,item.origin.y)
  warning.visible=age<1. or (age>=1.65 and age<2.25)
  item.lane.visible=age>=1.65 and age<2.25
  warning.scale=Vector3.ONE*(1.+sin(age*13.)*.05)
  (warning.material_override as StandardMaterial3D).albedo_color=Color("edbb91") if age<1. else Color("e59ab9")
