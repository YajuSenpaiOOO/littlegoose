extends "res://scripts/art/sister_transport205.gd"
var display_scale206 := .76
var durations206 := DURATIONS.duplicate()
var swing206 := 0.
var swing_speed206 := 0.
var previous_rig206 := Vector2.INF
var velocity206 := Vector2.ZERO
var drop_enabled206 := true
var attack_trip206 := true
var emitted206 := 0
var entry206 := Vector2.ZERO
var exit206 := Vector2.ZERO

func _ready() -> void:
 # Compare at a shared alpha-foot and depth in the actual perspective camera.
 display_scale206=desired_scale206()
 durations206.approach=2.6;durations206.depart=2.6
 super._ready();name="SisterTransport206"
 (body.get_child(0).shape as CylinderShape3D).radius=.29
 (contact.mesh as PlaneMesh).size=Vector2(.9,.65)

func hero_extent206() -> Array[Vector3]:
 var v: Sprite3D=world.hero.visual
 var bounds=opaque_bounds(v.texture.get_image())
 var x=float(bounds.position.x)+bounds.size.x*.5
 var top=Vector3((x-v.texture.get_width()*.5+v.offset.x)*v.pixel_size,(v.texture.get_height()*.5-bounds.position.y+v.offset.y)*v.pixel_size,0.)
 var bottom=top-Vector3.UP*bounds.size.y*v.pixel_size
 return [v.to_global(top),v.to_global(bottom)]

func desired_scale206() -> float:
 var extent=hero_extent206();var camera: Camera3D=world.camera
 var pixels=camera.unproject_position(extent[0]).distance_to(camera.unproject_position(extent[1]))
 var unit=camera.unproject_position(extent[1]+camera.global_basis.y).distance_to(camera.unproject_position(extent[1]))
 return clampf(pixels*1.08/maxf(unit,.001)/2.10,.62,.95)

func calibrate206() -> void:
 var next=desired_scale206();var ratio=next/display_scale206
 for card in cards: card.pixel_size*=ratio
 display_scale206=next

func make_card(file: String,height: float,pivot: Vector2) -> Sprite3D:
 var sprite=super.make_card(file,height*display_scale206,pivot)
 (sprite.material_override as ShaderMaterial).shader=preload("res://scripts/art/transport_card206.gdshader")
 return sprite

func restart() -> void:
 swing206=0.;swing_speed206=0.;previous_rig206=Vector2.INF;velocity206=Vector2.ZERO;emitted206=0
 attack_trip206=drop_enabled206
 super.restart()

func enter(next: String) -> void:
 super.enter(next)
 if next=="travel": emitted206=0;attack_trip206=drop_enabled206

func outside206(at: Vector2,side: float) -> Vector2:
 var camera: Camera3D=world.camera
 var origin=ground(at)
 var screen=camera.unproject_position(origin)
 var pixels=(camera.unproject_position(origin+camera.global_basis.x)-screen).length()
 var margin=(2.2*display_scale206)*pixels+70.
 var desired=-margin if side<0. else world.get_viewport().get_visible_rect().size.x+margin
 var shifted=origin+camera.global_basis.x*((desired-screen.x)/maxf(pixels,.01))
 return Vector2(shifted.x,shifted.z)

func evaluate() -> void:
 var saved_age=age
 if state in ["approach","depart"]: age=age/float(durations206[state])*float(DURATIONS[state])
 super.evaluate();age=saved_age
 var t=clampf(age/float(durations206[state]),0.,1.)
 if state=="approach":
  entry206=outside206(start_at,-1.)
  rig_at=entry206.lerp(start_at,ease205(t))
 if state=="depart":
  exit206=outside206(end_at,1.)
  rig_at=end_at.lerp(exit206,ease205(t))

func advance(delta: float) -> void:
 if not running: return
 # Bounded substeps keep the spring and attack timeline stable at low frame rates.
 var remaining=delta
 while remaining>.000001:
  var dt=minf(remaining,1./120.);remaining-=dt
  elapsed+=dt;age+=dt
  while age>=float(durations206[state]):
   var carry=age-float(durations206[state]);var index=ORDER.find(state)+1
   if index==ORDER.size():
    var old=start_at;start_at=end_at;end_at=old;cycles+=1;index=0
   enter(ORDER[index]);age=carry
  evaluate()
  var velocity=Vector2.ZERO if previous_rig206==Vector2.INF else (rig_at-previous_rig206)/dt
  previous_rig206=rig_at;velocity206=velocity
  var target=clampf(-velocity.x*.008,-.075,.075) if rig_visible else 0.
  swing_speed206+=((target-swing206)*49.-swing_speed206*6.3)*dt
  swing206=clampf(swing206+swing_speed206*dt,-.11,.11)
  if attack_trip206 and state=="travel" and emitted206<2 and age>=[.75,1.65][emitted206]:
   emitted206+=1
   if is_instance_valid(world.get("drops206")):
    world.drops206.spawn206(person_at,ground(person_at)+Vector3.UP*(lift+.65))

func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(hammock) or not hammock.visible: return
 # Override the parent's fixed .80m flap scale, retaining identical ring anchors.
 for bat in bats: bat.pixel_size=.80*display_scale206/float((manifests.bat_up as Rect2i).size.y)
 var camera_basis: Basis=world.camera.global_basis
 # Empty transport follows a smooth altitude path, never the cliff's ground height.
 var t=clampf(age/float(durations206[state]),0.,1.)
 var vertical_adjust=0.
 if state=="approach": vertical_adjust=ground(start_at).y+2.6*(1.-ease205(t))-ground(rig_at).y
 if state=="depart": vertical_adjust=ground(end_at).y+1.8*ease205(t)-ground(rig_at).y
 for card in [hammock,seated,bats[0],bats[1]]: card.global_position.y+=vertical_adjust
 var pivot=(pixel_point(hammock,textures.hammock.get_size()*Vector2(.089,.091))+pixel_point(hammock,textures.hammock.get_size()*Vector2(.922,.091)))*.5
 var rotation206=Basis(camera_basis.z,swing206)
 for card in [hammock,seated]:
  card.global_position=pivot+rotation206*(card.global_position-pivot)
  card.global_basis=rotation206*camera_basis
 for i in 2:
  var uv=Vector2(.089,.091) if i==0 else Vector2(.922,.091)
  bats[i].global_position=pixel_point(hammock,textures.hammock.get_size()*uv)
  bats[i].global_basis=Basis(camera_basis.z,swing206*.18)*camera_basis

func transport_rect206() -> Rect2:
 var result=Rect2();var first=true
 for card in [hammock,bats[0],bats[1]]:
  for uv in [Vector2.ZERO,Vector2(1,0),Vector2.ONE,Vector2(0,1)]:
   var point=world.camera.unproject_position(pixel_point(card,card.texture.get_size()*uv))
   if first: result=Rect2(point,Vector2.ZERO);first=false
   else: result=result.expand(point)
 return result
