extends "res://scripts/combat/droplets120.gd"

const GROUND_HEIGHT:=.10
const MAGNET_RANGE:=.86
const WATER_BEAD=preload("res://assets/workshop432/water-baby-drop.tres")

var bath_seed:=false

func drop_limit120() -> int:return 48

func _ready() -> void:
 super._ready()
 if bath_seed:
  ink120.set_shader_parameter("paint",WATER_BEAD.atlas)
 else:
  ink120.set_shader_parameter("tint",Color(.83,.89,.94))

func spawn120(at: Vector3,velocity: Vector3) -> void:
 var count_before:=items120.size()
 super.spawn120(at,velocity)
 if not bath_seed or items120.size()==count_before:return
 var sprite:Sprite3D=items120.back().sprite
 sprite.texture=WATER_BEAD
 sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR
 sprite.pixel_size=.225/WATER_BEAD.get_height()
 sprite.position.y=.013

func collect120(index:int) -> bool:
 var item:=items120[index]
 var point:Vector3=item.get("pickup_point",item.root.global_position)
 var count:int=item.get("count",1)
 if bath_seed:
  world.memory_kit116.water_seed=mini(world.memory_kit116.water_seed+count,999999)
 elif not world.collect_gel432(count):return false
 item.root.queue_free()
 item.shadow.queue_free()
 items120.remove_at(index)
 picked120+=count
 world.materials432.pickup_fx.burst(point,Color("ffcfb5") if bath_seed else Color("abdde8"))
 if bath_seed:
  world.say264("哇，是水宝宝！待会儿回去我们把它泡起来吧。")
 else:
  world.materials432.notify("收到蓝色弹性液滴 ×%d"%count)
 return true

func gather_leftovers() -> void:
 # Keep drops already on their way to the player out of the batch.
 var loose:=items120.filter(func(item:Dictionary):return not item.get("attracting",false))
 if loose.is_empty():return
 var bundle:Dictionary=loose.back()
 var count:int=bundle.get("count",1)
 for item in loose:
  if item.root==bundle.root:continue
  count+=int(item.get("count",1))
  items120.erase(item)
  var mesh:Node3D=item.root
  var shadow:Node3D=item.shadow
  var shrink:=create_tween().set_parallel()
  shrink.tween_property(mesh,"scale",Vector3.ONE*.02,.24).set_trans(Tween.TRANS_QUAD)
  shrink.tween_property(shadow,"scale",Vector3.ONE*.02,.24)
  shrink.chain().tween_callback(mesh.queue_free)
  shrink.parallel().tween_callback(shadow.queue_free)
 bundle.count=count
 var sprite:Sprite3D=bundle.sprite
 sprite.pixel_size=(.225/WATER_BEAD.get_height() if bath_seed else .24/750.)*1.55
 sprite.scale=Vector3.ONE*.70
 var anchor:Node3D=bundle.root
 # Late arrivals can fall on the shrub line. Leave the bundle on the clear
 # approach to the arena, where the player can actually stand next to it.
 var at:Vector2=world.grove432+Vector2(0.,2.8)
 var nav:RefCounted=world.entry_navigation261
 var cell:Vector2i=nav.nearest(at)
 at=nav.origin+Vector2(cell)*nav.CELL
 anchor.position=Vector3(at.x,world.floor_height(at)+GROUND_HEIGHT*1.55,at.y)
 bundle.settled=true
 bundle.pickup_ready=clock120+.45

func _physics_process(delta:float) -> void:
 if world.combat_paused:return
 clock120+=delta
 var feet:Vector3=world.hero.global_position
 var hero:=feet+Vector3.UP*.33
 for index in range(items120.size()-1,-1,-1):
  var item:=items120[index]
  var root:Node3D=item.root
  var shadow:Node3D=item.shadow
  var sprite:Sprite3D=item.sprite
  var at:=Vector2(root.position.x,root.position.z)
  var floor_y:float=world.floor_height(at)
  shadow.position=Vector3(at.x,floor_y+.022,at.y)
  shadow.visible=not item.get("attracting",false)
  if not item.get("settled",false):
   var velocity:Vector3=item.velocity
   velocity.y-=10.*delta
   var next:=root.position+velocity*delta
   var ground:=Vector2(next.x,next.z)
   if world.meadow.is_water(ground) or absf(world.floor_height(ground)-floor_y)>.35:
    next.x=root.position.x
    next.z=root.position.z
    velocity.x=0.
    velocity.z=0.
   var landing:float=world.floor_height(Vector2(next.x,next.z))+GROUND_HEIGHT
   if next.y<=landing:
    next.y=landing
    item.bounces+=1
    item.settled=item.bounces>=2
    velocity=Vector3(velocity.x*.36,absf(velocity.y)*.20,velocity.z*.36)
    sprite.scale=Vector3(1.19,.72,1.)
   item.velocity=velocity
   root.position=next
  elif world.hero.controls_enabled and clock120>=float(item.get("pickup_ready",0.)):
   var planar:=Vector2(feet.x-root.position.x,feet.z-root.position.z)
   if item.get("attracting",false) or (planar.length_squared()<MAGNET_RANGE*MAGNET_RANGE and absf(feet.y-floor_y)<.48):
    if not item.get("attracting",false):
     item.attracting=true
     item.pickup_point=root.global_position
    root.position=root.position.move_toward(hero,delta*4.6)
    if root.position.distance_to(hero)<.13 and clock120>=float(item.retry):
     if collect120(index):continue
     item.retry=clock120+1.
  sprite.scale=sprite.scale.lerp(Vector3.ONE,minf(1.,delta*12.))
