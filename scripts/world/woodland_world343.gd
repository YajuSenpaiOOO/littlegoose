extends "res://scripts/world/woodland_world342.gd"
var stepping343:=false
var tracking_stats343: Dictionary={"turns":0,"rebounds":0,"splits":0}
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 343 · 衍生追踪 / 平面反弹")
func _ready() -> void:
 await super._ready()
 hint288.text="343 衍生追踪 / 平面反弹"
func section343(shape: CollisionShape3D, height: float) -> Vector3:
 if not shape.shape is BoxShape3D:return Vector3.INF
 var corners: Array[Vector3]=[]
 for i in 8:
  corners.append(shape.global_transform*(shape.shape.size*.5*Vector3(1. if i&1 else -1.,1. if i&2 else -1.,1. if i&4 else -1.)))
 var sum:=Vector3.ZERO
 var count:=0
 for i in 8:
  for bit in [1,2,4]:
   var j: int=i^bit
   if j<i:continue
   var a:=corners[i];var b:=corners[j]
   if absf(b.y-a.y)<.0001:continue
   var t: float=(height-a.y)/(b.y-a.y)
   if t>=0. and t<=1.:sum+=a.lerp(b,t);count+=1
 return sum/float(count) if count>0 else Vector3.INF
func seek343(shot: Dictionary, delta: float) -> void:
 var level:=int(shot.get("tracking146",buffs.level("eye_exercise")))
 if level<=0:return
 var age: float=float(shot.get("seek_age343",0.))+delta
 if age<1./30.-.00001:shot.seek_age343=age;return
 shot.seek_age343=0.;delta=age
 var at: Vector3=shot.node.at
 var velocity: Vector3=shot.velocity
 var speed:=velocity.length()
 var forward:=Vector2(velocity.x,velocity.z)
 if speed<.01 or forward.length_squared()<.0001:return
 var points: Array[Dictionary]=[]
 for enemy in enemies:
  if not is_instance_valid(enemy) or enemy.dead or enemy.hit_area.collision_layer==0:continue
  var shape: CollisionShape3D=enemy.hit_area.get_child(0)
  var point:=section343(shape,at.y)
  if shape.shape is CapsuleShape3D and absf(at.y-shape.global_position.y)<shape.shape.height*.5-.05:
   point=Vector3(shape.global_position.x,at.y,shape.global_position.z)
  if point.is_finite():points.append({"at":point,"aliases":[enemy.hit_area.get_rid()]})
 if is_instance_valid(theatre314) and core_phase326:
  var areas: Array[Area3D]=[]
  for i in 2:
   if cannon_hp326[i]>0. and theatre314.cannon_areas326[i].collision_layer!=0:areas.append(theatre314.cannon_areas326[i])
  if fastener_hp321>0. and theatre314.castle_target327.collision_layer!=0:areas.append(theatre314.castle_target327)
  for area in areas:
   for shape in area.get_children():
    var point:=section343(shape,at.y)
    if point.is_finite():points.append({"at":point,"aliases":structure_aliases340(area)})
 var best:=pow(240./Profile.PPM,2.)
 var desired:=Vector2.ZERO
 for point in points:
  var excluded:=false
  for rid in point.aliases:
   if shot.ignore_rids110.has(rid) or shot.hit_rids.has(rid):excluded=true
  if excluded:continue
  var offset: Vector3=point.at-at
  var flat:=Vector2(offset.x,offset.z)
  if flat.length_squared()<.0001 or flat.length_squared()>=best:continue
  if forward.normalized().dot(flat.normalized())<cos(1.4 if level==1 else 1.9):continue
  var ignores: Array[RID]=[hero.get_rid()]
  ignores.append_array(shot.ignore_rids110);ignores.append_array(point.aliases)
  if not get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(at,point.at,1|2,ignores)).is_empty():continue
  best=flat.length_squared();desired=flat.normalized()
 if desired==Vector2.ZERO:return
 var turn:=clampf(forward.angle_to(desired),-(2.5 if level==1 else 4.)*delta,(2.5 if level==1 else 4.)*delta)
 var direction:=forward.normalized().rotated(turn)
 shot.velocity=Vector3(direction.x,0.,direction.y)*speed
 tracking_stats343.turns+=1
 if int(shot.get("split_depth110",0))>0:tracking_stats343.splits+=1
 if int(shot.get("bounces275",0))>0:tracking_stats343.rebounds+=1
func steer_ball341(shot: Dictionary, delta: float) -> void:
 if not stepping343:seek343(shot,delta)
func _step_shots(delta: float) -> void:
 # Native flight/collision and 275 original-projectile redirects remain intact.
 # Their legacy steering shares steer_age111; suspend only that duplicate
 # steering for derived shots already handled here, restoring the clock after.
 for shot in shots:
  if int(shot.get("split_depth110",0))<=0 and int(shot.get("bounces275",0))<=0:continue
  seek343(shot,delta)
  shot.saved_steer343=shot.get("steer_age111",0.)
  shot.steer_age111=-1000000.
 stepping343=true
 super._step_shots(delta)
 stepping343=false
 for shot in shots:
  if shot.has("saved_steer343"):
   shot.steer_age111=shot.saved_steer343
   shot.erase("saved_steer343")
func redirect275(shot: Dictionary, hit: Dictionary, damage: float) -> void:
 var incoming: Vector3=shot.velocity
 super.redirect275(shot,hit,damage)
 var flat:=Vector3(incoming.x,0.,incoming.z)
 if flat.length_squared()<.001:flat=Vector3.BACK
 var normal: Vector3=hit.get("normal",Vector3.UP)
 normal.y=0.
 var floor_hit: bool=hit.get("floor275",false) or Vector3(hit.get("normal",Vector3.UP)).y>.65
 var direction:=flat.normalized() if floor_hit else flat.normalized().bounce(normal.normalized() if normal.length_squared()>.001 else -flat.normalized())
 shot.velocity=direction.normalized()*incoming.length()
 shot.node.at=hit.position+direction.normalized()*.08
func report_stats226() -> Dictionary:
 var report:=super.report_stats226();report.runtime_preview=343
 if report.has("paper_theatre337"):report.paper_theatre337.preview=343
 report.tracking343=tracking_stats343.duplicate()
 return report
func _process(delta: float) -> void:
 super._process(delta)
 if is_instance_valid(theatre314):guide206.text=guide206.text.replace("342 城防弹幕","343 城防弹幕")
