extends "res://scripts/world/woodland_world338.gd"

func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 340 · 结构反弹兼容")
func _ready() -> void:
 await super._ready()
 hint288.text="340 结构反弹兼容\n弹力球可由城墙/炮台弹向附近目标"
func structure_aliases340(collider: Object) -> Array[RID]:
 var aliases: Array[RID]=[]
 if collider==theatre314.castle_target327 or collider==theatre314.bodies[0].get_parent():
  aliases.append(theatre314.castle_target327.get_rid())
  aliases.append(theatre314.bodies[0].get_parent().get_rid())
 elif collider is Area3D:
  var i: int=theatre314.cannon_areas326.find(collider)
  if i>=0:
   aliases.append(collider.get_rid())
   aliases.append((theatre314.scenery_shapes322[theatre314.cannons326[i]].get_parent() as CollisionObject3D).get_rid())
 return aliases
func bounce_direction340(at: Vector3, velocity: Vector3, normal: Vector3, ignores: Array[RID]) -> Vector3:
 var points: Array[Dictionary]=[]
 for enemy in enemies:
  if is_instance_valid(enemy) and not enemy.dead and enemy.hit_area.collision_layer!=0:
   points.append({"at":enemy.hit_area.global_position,"aliases":[enemy.hit_area.get_rid()]})
 for i in 2:
  if cannon_hp326[i]>0. and theatre314.cannon_areas326[i].collision_layer!=0:
   points.append({"at":theatre314.cannon_areas326[i].global_position,"aliases":structure_aliases340(theatre314.cannon_areas326[i])})
 if fastener_hp321>0. and theatre314.castle_target327.collision_layer!=0:
  for shape in theatre314.castle_target327.get_children():
   points.append({"at":shape.global_position,"aliases":structure_aliases340(theatre314.castle_target327)})
 var direction:=Vector3.ZERO
 var nearest:=6.5
 for point in points:
  var self_target:=false
  for rid in point.aliases:
   if ignores.has(rid): self_target=true
  if self_target:continue
  var delta: Vector3=point.at-at
  if delta.length()<.1 or delta.length()>=nearest:continue
  var excluded: Array[RID]=[hero.get_rid()]
  excluded.append_array(ignores)
  excluded.append_array(point.aliases)
  var ray:=PhysicsRayQueryParameters3D.create(at,point.at,1|2,excluded)
  if not get_world_3d().direct_space_state.intersect_ray(ray).is_empty():continue
  nearest=delta.length()
  direction=delta.normalized()
 if direction!=Vector3.ZERO:return direction
 var n:=normal.normalized() if normal.length()>.1 else -velocity.normalized()
 return velocity.normalized().bounce(n).normalized()
func _apply_shot_hit(shot: Dictionary, hit: Dictionary) -> void:
 var aliases: Array[RID]=[]
 if active114 and core_phase326 and is_instance_valid(theatre314):aliases=structure_aliases340(hit.collider)
 var rebound: bool=int(shot.get("bounces275",0))>0
 if rebound:
  shot.damage_source260="bouncy_rebound"
  shot.split_depth110=99
 var before:=fastener_hp321+cannon_hp326[0]+cannon_hp326[1]
 super._apply_shot_hit(shot,hit)
 if rebound and not aliases.is_empty() and fastener_hp321+cannon_hp326[0]+cannon_hp326[1]<before:ball_stats273.rebound_hits+=1
func redirect275(shot: Dictionary, hit: Dictionary, damage: float) -> void:
 var aliases: Array[RID]=[]
 if is_instance_valid(theatre314) and is_instance_valid(hit.get("collider")):aliases=structure_aliases340(hit.collider)
 if aliases.is_empty():
  super.redirect275(shot,hit,damage)
  return
 var ignores: Array[RID]=[]
 ignores.append_array(shot.ignore_rids110)
 ignores.append_array(aliases)
 var speed: float=shot.velocity.length()
 var direction:=bounce_direction340(hit.position,shot.velocity,hit.get("normal",-Vector3(shot.velocity).normalized()),ignores)
 shot.ignore_rids110=ignores
 shot.velocity=direction*speed
 shot.bounces275=1
 shot.piercing110=false
 shot.charged=false
 shot.fixed_damage110=damage*.7
 shot.final_damage234=true
 shot.node.previous=hit.position
 shot.node.at=hit.position+direction*.08
 if shot.get("stream110",false):
  shot.stream_joint275=hit.position
  shot.stream_generation110+=100000
  elastic_stats275.stream+=1
 elastic_stats275.redirects+=1
 if is_instance_valid(elastic_visual275):elastic_visual275.hit275(hit.position)
func report_stats226() -> Dictionary:
 var report:=super.report_stats226()
 report.runtime_preview=340
 report.runtime_world_script=get_script().resource_path
 if report.has("paper_theatre337"):report.paper_theatre337.preview=340
 return report
func _process(delta: float) -> void:
 super._process(delta)
 if is_instance_valid(theatre314):guide206.text=guide206.text.replace("338 城防弹幕","340 城防弹幕").replace("337 城防弹幕","340 城防弹幕")
