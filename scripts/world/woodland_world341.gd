extends "res://scripts/world/woodland_world340.gd"
var split_keys341: Dictionary={}
var split_serial341:=0
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 341 · 角度反弹 / 连续分裂光束")
func _ready() -> void:
 await super._ready()
 hint288.text="341 角度反弹 / 连续分裂光束\n眼保健操让反弹弹幕逐渐追踪"
func card_catalog273() -> Array:
 var cards:=super.card_catalog273()
 cards[-1]=cards[-1].duplicate()
 cards[-1].fx="按碰撞角度反弹一次，保留速度、反弹伤害70%、结束贯穿；眼保健操可让反弹弹幕逐渐追踪。光束折射、分裂子弹各自可弹一次，反弹命中不再分裂。"
 return cards
func bounce_direction340(_at: Vector3, velocity: Vector3, normal: Vector3, _ignores: Array[RID]) -> Vector3:
 var n:=normal.normalized() if normal.length_squared()>.01 else -velocity.normalized()
 # Camera-facing hit boxes tilt 25 degrees; a wall must not kick the
 # projectile skyward merely because its illustration faces the camera.
 if absf(n.y)<.65 and Vector2(n.x,n.z).length_squared()>.01:
  n.y=0.
  n=n.normalized()
 return velocity.normalized().bounce(n).normalized()
func redirect275(shot: Dictionary, hit: Dictionary, damage: float) -> void:
 # Prevent the legacy enemy/ground redirect from choosing a target at impact.
 var reflected:=bounce_direction340(hit.position,shot.velocity,hit.get("normal",Vector3.UP),[])
 super.redirect275(shot,hit,damage)
 shot.velocity=reflected*Vector3(shot.velocity).length()
 shot.node.at=hit.position+reflected*.08
 shot.target110=null
 shot.target_until110=0.
func steer_ball341(shot: Dictionary, delta: float) -> void:
 var level:=buffs.level("eye_exercise")
 if level<=0:return
 var at: Vector3=shot.node.at
 var velocity: Vector3=shot.velocity
 var speed:=velocity.length()
 if speed<.01:return
 var forward:=Vector2(velocity.x,velocity.z)
 var points: Array[Dictionary]=[]
 for enemy in enemies:
  if is_instance_valid(enemy) and not enemy.dead and enemy.hit_area.collision_layer!=0:
   points.append({"at":enemy.hit_area.global_position,"aliases":[enemy.hit_area.get_rid()]})
 if is_instance_valid(theatre314) and core_phase326:
  for i in 2:
   if cannon_hp326[i]>0. and theatre314.cannon_areas326[i].collision_layer!=0:
    points.append({"at":theatre314.cannon_areas326[i].global_position,"aliases":structure_aliases340(theatre314.cannon_areas326[i])})
  if fastener_hp321>0. and theatre314.castle_target327.collision_layer!=0:
   for shape in theatre314.castle_target327.get_children():
    points.append({"at":shape.global_position,"aliases":structure_aliases340(theatre314.castle_target327)})
 var best:=pow(240./Profile.PPM,2.)
 var desired:=Vector3.ZERO
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
  ignores.append_array(shot.ignore_rids110)
  ignores.append_array(point.aliases)
  if not get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(at,point.at,1|2,ignores)).is_empty():continue
  best=flat.length_squared()
  desired=offset.normalized()
 if desired==Vector3.ZERO:return
 var rate:=2.5 if level==1 else 4.
 var turn:=clampf(forward.angle_to(Vector2(desired.x,desired.z)),-rate*delta,rate*delta)
 var flat:=forward.normalized().rotated(turn)
 var vy:=lerpf(velocity.y,desired.y*speed,minf(1.,rate*delta))
 var horizontal:=sqrt(maxf(0.,speed*speed-vy*vy))
 shot.velocity=Vector3(flat.x*horizontal,vy,flat.y*horizontal)
func _step_shots(delta: float) -> void:
 # 275 handles pre-impact steering; steer only existing rebounds here.
 if buffs.level("bouncy_ball")>0 and buffs.level("eye_exercise")>0:
  for shot in shots:
   if int(shot.get("bounces275",0))>0:steer_ball341(shot,delta)
 super._step_shots(delta)
func _apply_shot_hit(shot: Dictionary, hit: Dictionary) -> void:
 var pending:=pending_splits110.size()
 var structures:=structure_splits338.size()
 super._apply_shot_hit(shot,hit)
 if not shot.get("stream110",false):return
 var identity: String=shot.get("split_path341",str(shot.stream_generation110)+":"+str(shot.stream_lane110))
 for queue in [pending_splits110.slice(pending),structure_splits338.slice(structures)]:
  for split in queue:
   split.path341=identity
   split.sequence341=shot.stream_sequence110
   split.branch341=0
func inherit_split153(shot: Dictionary, split: Dictionary) -> void:
 super.inherit_split153(shot,split)
 if not shot.get("stream110",false) or not split.has("path341"):return
 var branch:=int(split.branch341)
 split.branch341=branch+1
 var key: String=split.path341+"/"+str(branch)
 if not split_keys341.has(key):
  split_serial341+=1
  split_keys341[key]=-1000000-split_serial341
 shot.split_path341=key
 shot.stream_generation110=split_keys341[key]
 shot.stream_sequence110=split.sequence341
 shot.stream_joint275=split.at
func _clear_combat_shots() -> void:
 split_keys341.clear()
 split_serial341=0
 super._clear_combat_shots()
func report_stats226() -> Dictionary:
 var report:=super.report_stats226()
 report.runtime_preview=341
 if report.has("paper_theatre337"):report.paper_theatre337.preview=341
 report.beam341={"split_branches":split_keys341.size(),"ribbons":skills110.chains110.size(),"build_us":skills110.build_us263}
 return report
func _process(delta: float) -> void:
 super._process(delta)
 if is_instance_valid(theatre314):guide206.text=guide206.text.replace("340 城防弹幕","341 城防弹幕")
