extends "res://scripts/world/woodland_world274.gd"
var elastic_visual275: Node2D
var elastic_contact275 := false
var elastic_stats275 := {"redirects":0,"ground":0,"stream":0}
func _init() -> void:
 super._init();memory_kit116=preload("res://scripts/combat/memory_kit275.gd").new()
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 275 · 弹力球联动 / 原弹改向")
func balance_profile226() -> Script:return preload("res://scripts/combat/balance_profile275.gd")
func load_test226() -> void:
 levels226={};super.load_test226()
func card_catalog273() -> Array:
 var cards=super.card_catalog273()
 cards[-1]=cards[-1].duplicate();cards[-1].fx="弹幕变为弹力球，原弹保留速度改向一次；反弹伤害70%、结束贯穿。飞机落地弹起，光束折射；分裂子弹各自可弹一次，反弹命中不再分裂。与气球剑互斥。"
 return cards
func _ready() -> void:
 await super._ready()
 elastic_visual275=elastic_visual_script275().new();elastic_visual275.battle=self
 skills110.add_child(elastic_visual275)
func elastic_visual_script275() -> Script:return preload("res://scripts/art/elastic_visual275.gd")
func legacy_contact_art(at: Vector3,direction: Vector3,juice: bool,finishing := false) -> void:
 if elastic_contact275:
  if is_instance_valid(elastic_visual275):elastic_visual275.hit275(at)
 else:super.legacy_contact_art(at,direction,juice,finishing)
func prepare275(shot: Dictionary) -> void:
 if shot.get("elastic275",false):return
 shot.elastic275=true;shot.bounces275=0;shot.ball273=true
 if not shot.get("stream110",false):shot.art.modulate.a=0.
func sugar_contact(at: Vector3,direction: Vector3) -> void:
 if elastic_contact275:
  if is_instance_valid(elastic_visual275):elastic_visual275.hit275(at)
 else:super.sugar_contact(at,direction)
func _apply_shot_hit(shot: Dictionary,hit: Dictionary) -> void:
 if not shot.get("elastic275",false):super._apply_shot_hit(shot,hit);return
 var previous=elastic_contact275;elastic_contact275=true
 if int(shot.bounces275)>0:shot.split_depth110=99
 super._apply_shot_hit(shot,hit);elastic_contact275=previous
func trace275(shot: Dictionary,start: Vector3,end: Vector3) -> Dictionary:
 var exclude: Array[RID]=[hero.get_rid()]
 for rid in shot.ignore_rids110:exclude.append(rid)
 var query=PhysicsRayQueryParameters3D.create(start,end,1|2|8,exclude);query.collide_with_areas=true;query.hit_from_inside=true
 var hit=get_world_3d().direct_space_state.intersect_ray(query)
 if not hit.is_empty():return hit
 # Terrain collision may be skipped by old rain fast paths; resolve the actual walk surface crossing.
 var floor_end=floor_height(Vector2(end.x,end.z))+.06
 if end.y<=floor_end and start.y>floor_end:
  var t=clampf((start.y-floor_end)/maxf(.0001,start.y-end.y),0.,1.)
  return {"position":start.lerp(end,t),"normal":Vector3.UP,"collider":null,"floor275":true}
 return {}
func redirect275(shot: Dictionary,hit: Dictionary,damage: float) -> void:
 var speed: float=shot.velocity.length();var normal: Vector3=hit.get("normal",Vector3.UP)
 var direction: Vector3=shot.velocity.normalized().bounce(normal)
 var ground=normal.y>.65;var enemy: Object=hit.collider.get_meta("enemy") if is_instance_valid(hit.get("collider")) and hit.collider.has_meta("enemy") else null
 if is_instance_valid(enemy):shot.ignore_rids110.append(hit.collider.get_rid())
 var closest=7.5
 var candidates=enemies if ground or is_instance_valid(enemy) else []
 for target in candidates:
  if not is_instance_valid(target) or target.dead or target==enemy or target.hit_area.collision_layer==0 or target.hit_area.get_rid() in shot.ignore_rids110:continue
  var offset: Vector3=target.hit_area.global_position-hit.position
  if offset.length()<closest:closest=offset.length();direction=offset.normalized()
 if ground and direction.y>.8:direction=Vector3(.9,.3,.3).normalized()
 shot.velocity=direction.normalized()*speed;shot.bounces275=1;shot.piercing110=false;shot.charged=false
 shot.fixed_damage110=damage*.7;shot.final_damage234=true
 shot.node.previous=hit.position;shot.node.at=hit.position+direction.normalized()*.08
 if ground:shot.life=maxf(float(shot.life),.7);elastic_stats275.ground+=1
 if shot.get("stream110",false):shot.stream_joint275=hit.position;shot.stream_generation110+=100000;elastic_stats275.stream+=1
 elastic_stats275.redirects+=1
 if is_instance_valid(elastic_visual275):elastic_visual275.hit275(hit.position)
func _step_shots(delta: float) -> void:
 if buffs.level("bouncy_ball")==0:super._step_shots(delta);return
 # Keep the same BulletState, art, record and resolved weapon speed through every redirect.
 for i in range(shots.size()-1,-1,-1):
  if i>=shots.size():continue
  var shot: Dictionary=shots[i];prepare275(shot)
  if buffs.level("eye_exercise")>0 and int(shot.bounces275)==0:
   steering_level113=buffs.level("eye_exercise");shot.ball273=false;super._steer_shot(shot,delta);shot.ball273=true
  var start: Vector3=shot.node.at;var end: Vector3=start+shot.velocity*delta
  var hit=trace275(shot,start,end);shot.life-=delta
  if not hit.is_empty():
   var damage=damage_for_shot(shot)
   if not hit.get("floor275",false):_apply_shot_hit(shot,hit)
   if not active114 or i>=shots.size():continue
   if int(shot.bounces275)==0:redirect275(shot,hit,damage);continue
  if not hit.is_empty() or shot.life<=0.:
   pool110.retire(shot);shots.remove_at(i)
  else:shot.node.previous=start;shot.node.at=end
 _flush_splits113()
func report_stats226() -> Dictionary:
 var report=super.report_stats226();report["elastic275"]=elastic_stats275.duplicate(true);return report
func _process(delta: float) -> void:
 super._process(delta)
 if ready264:guide206.text=guide206.text.replace("274 林间空地","275 林间空地").replace("274 大团团挑战","275 大团团挑战")
