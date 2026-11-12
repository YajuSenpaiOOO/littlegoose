extends "res://scripts/world/woodland_world346.gd"
const PLAN347=[
 {"name":"纸怪飘来","normal":4,"elite":[]},
 {"name":"喷火占区","normal":3,"elite":["dinosaur"]},
 {"name":"骑士冲线","normal":3,"elite":["knight"]},
 {"name":"怪兽与流星","normal":3,"elite":["monster"]},
 {"name":"双精英收尾","normal":2,"elite":["dinosaur","knight"]}]
var ready347:=false
var actors347: Array[CharacterBody3D]=[]
var jobs347: Array[Dictionary]=[]
var batch347:=-1
var batch_age347:=0.
var age347:=0.
var hold347:=0.
var serial347:=0
var kills347:=0
var elite_kills347:=0
var meteor_left347:=4.5
var events347: Array[Dictionary]=[]
var result347:=""
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 347 · 纸怪连续遭遇")
func plan347() -> Array:return PLAN347
func normal_script347() -> Script:return preload("res://scripts/combat/paper347.gd")
func normal_gap347() -> float:return .65
func normal_cap347(elite_count: int) -> int:return 2 if batch347==plan347().size()-1 else (3 if elite_count>0 else 4)
func elite_gate347() -> int:return 2 if batch347==plan347().size()-1 else 3
func total347() -> int:
 var total:=0
 for row in plan347():total+=int(row.normal)+row.elite.size()
 return total
func uses_card_schedule301() -> bool:return false
func _ready() -> void:
 await super._ready()
 ready347=true
 process_priority=120
 restart301()
 hint288.text="347 纸怪连续遭遇\n普通纸怪＋折纸精英 · C装配 / F7重试"
 if not reconfigure346.is_empty() and not console226.visible:toggle_console226()
func restart301() -> void:
 if ready347 and recording226.active:recording226.finish(self,"restart_abort")
 for actor in actors347:
  if is_instance_valid(actor):actor.queue_free()
 actors347.clear();jobs347.clear();events347.clear()
 batch347=-1;age347=0.;batch_age347=0.;hold347=0.;serial347=0;kills347=0;elite_kills347=0;meteor_left347=4.5;result347=""
 super.restart301()
 if not ready347:return
 for actor in enemies:
  if is_instance_valid(actor):actor.queue_free()
 enemies.clear();cards301.clear()
 waiting_intro314=false;core_phase326=false;entry_clock314=-1.;fall314=-1.
 mode264="paper347";wave_state="fighting";active114=true;reward_offered=true;total_enemies=total347()
 theatre314.cancel();theatre314.hide();theatre314.set_process(false)
 disable_stage347(theatre314)
 clear_patterns327();clear_cannon_shots326();structure335.clear()
 camera.v_offset=.8
 queue_batch347()
func disable_stage347(node: Node) -> void:
 if node is CollisionObject3D:node.collision_layer=0;node.collision_mask=0
 for child in node.get_children():disable_stage347(child)
func live347(elite :=false) -> Array:
 return actors347.filter(func(actor):return is_instance_valid(actor) and not actor.dead and bool(actor.get_meta("elite347",false))==elite)
func log347(kind: String,more: Dictionary={}) -> void:
 if events347.size()<512:events347.append({"time":age347,"batch":batch347,"kind":kind,"data":more})
func queue_batch347() -> void:
 batch347+=1;batch_age347=0.
 var plan: Dictionary=plan347()[batch347]
 for i in int(plan.normal):jobs347.append({"type":"normal","due":float(i)*.65})
 for i in plan.elite.size():jobs347.append({"type":plan.elite[i],"due":1.8+float(i)*2.5})
 log347("batch",{"name":plan.name})
func entry_point347() -> Vector2:
 var offsets=[Vector2(-4.2,.8),Vector2(4.2,1.5),Vector2(-4.2,7.8),Vector2(4.2,7.8),Vector2(0,.6)]
 var feet:=Vector2(hero.position.x,hero.position.z)
 var best: Vector2=centre301+offsets[serial347%offsets.size()]
 for i in offsets.size():
  var point: Vector2=centre301+offsets[(serial347+i)%offsets.size()]
  if point.distance_to(feet)>3.5:return point
  if point.distance_to(feet)>best.distance_to(feet):best=point
 return best
func spawn347(kind: String) -> CharacterBody3D:
 var elite:=kind!="normal"
 var actor: CharacterBody3D
 if not elite:actor=normal_script347().new()
 elif kind=="knight":actor=preload("res://scripts/combat/paper_card312.gd").new()
 else:actor=preload("res://scripts/combat/paper_card306.gd").new()
 actor.battle=self;actor.poses=combat_poses;actor.textures=combat_textures
 actor.role110=serial347%3;actor.home=centre301;actor.touch110=1.
 actor.max_hp110=3. if not elite else (12. if kind=="dinosaur" else 14.)
 actor.hp=actor.max_hp110
 if elite:actor.kind301=kind
 actor.set_meta("elite347",elite);actor.set_meta("batch347",batch347);actor.set_meta("kind347",kind)
 var point:=entry_point347()
 actor.position=Vector3(point.x,floor_height(point)+.04,point.y)
 add_child(actor)
 if not elite:actor.mode119="playing";actor.active_ai=false
 actors347.append(actor);enemies.append(actor)
 if elite:cards301.append(actor)
 _add_actor_shadow(actor,actor.visual);actor.reset_physics_interpolation()
 serial347+=1;rebuild_cells110();log347("entry",{"type":kind,"normal_live":live347().size(),"elite_live":live347(true).size()})
 return actor
func director347(delta: float) -> void:
 age347+=delta;batch_age347+=delta;hold347=maxf(0.,hold347-delta)
 actors347=actors347.filter(func(actor):return is_instance_valid(actor))
 var normal:=live347();var elite:=live347(true)
 if hold347<=0. and not jobs347.is_empty():
  var job:=jobs347[0]
  var final:=batch347==plan347().size()-1
  var can_enter: bool=batch_age347>=job.due
  if job.type=="normal":can_enter=can_enter and normal.size()<normal_cap347(elite.size())
  else:can_enter=can_enter and elite.size()<(2 if final else 1) and normal.size()<=elite_gate347()
  if can_enter:
   spawn347(job.type);jobs347.pop_front()
   # Delayed queues must not unload all overdue actors in adjacent frames.
   if job.type!="normal":
    for pending in jobs347:
     if pending.type!="normal":pending.due=maxf(float(pending.due),batch_age347+2.5)
   elif not jobs347.is_empty():
    jobs347[0].due=maxf(float(jobs347[0].due),batch_age347+(normal_gap347() if jobs347[0].type=="normal" else .4))
 if hold347<=0. and jobs347.is_empty():
  normal=live347();elite=live347(true)
  if batch347==plan347().size()-1:
   if normal.is_empty() and elite.is_empty() and flights327.is_empty():finish251(true)
  elif elite.is_empty() and normal.size()<=2 and (batch_age347>=6. or (normal.is_empty() and batch_age347>=1.5)):
   queue_batch347()
 meteor_left347-=delta
 if meteor_left347<=0. and elite.any(func(actor):return actor.kind301=="monster" and actor.state301!="enter"):
  if flights327.is_empty():
   add_flight327(paper_clamp301(Vector2(hero.position.x,hero.position.z)),0.,1.8,0,true)
   log347("meteor")
  meteor_left347=5.
 tick_flights327(delta);tick_blasts327(delta)
func boss_step314(delta: float) -> void:
 if ready347:director347(delta)
func add_flight327(at: Vector2,delay: float,duration: float,source: int,meteor: bool) -> void:
 super.add_flight327(at,delay,duration,source,meteor)
 if ready347:
  flights327[-1].sprite.reparent(self,true);flights327[-1].marker.reparent(self,true)
func resolve_impact333(blast: Dictionary) -> void:
 if ready347:
  blast.radius=1.35
  if not blast.visual.root.get_meta("ordinary347",false):
   blast.visual.root.reparent(self,true);blast.visual.root.scale*=.65;blast.visual.root.set_meta("ordinary347",true)
 super.resolve_impact333(blast)
func enemy_defeated(actor: CharacterBody3D) -> void:
 if not ready347 or not actors347.has(actor):super.enemy_defeated(actor);return
 if actor.get_meta("counted347",false):return
 actor.set_meta("counted347",true);enemies.erase(actor);kills347+=1;defeated_count=kills347
 if actor.get_meta("elite347",false):elite_kills347+=1;hold347=2.;log347("elite_defeated")
 if target114==actor:target114=null
 aim_tick114=-1;rebuild_cells110()
func hurt_player(damage: float,from: Vector2) -> void:
 var old:=ready301
 if ready347:ready301=false
 super.hurt_player(damage,from)
 ready301=old
 if ready347 and player_hp<=0. and active114:finish251(false)
func on_legacy_contact(actor: CharacterBody3D,at: Vector3,direction: Vector3,juice: bool) -> void:
 if ready347 and actors347.has(actor):structure_contact326(at,direction,actor.dead);return
 super.on_legacy_contact(actor,at,direction,juice)
func finish251(victory: bool) -> void:
 if not ready347:super.finish251(victory);return
 if not active114:return
 result347="纸怪清场" if victory else ("挑战失败" if player_hp<=0. else "试演结束")
 active114=false;wave_state="waiting";stage225="waiting";jobs347.clear()
 _clear_combat_shots();clear_patterns327();reset_impact248();hero.cancel_guard109();hero.controls_enabled=true
 stats226.result="victory" if victory else "defeat"
 if recording226.active:recording226.finish(self,stats226.result)
func _workshop_hint_text116() -> String:return ""
func ordinary_record_folder347() -> String:return "user://paper_encounter_records"
func begin_sample337(mode: String) -> String:
 if not ready347:return super.begin_sample337(mode)
 reset_stats226(false);paper337.clear();recording226.folder=ordinary_record_folder347()
 recording226.begin(self,mode)
 return "" if recording226.save(self)==OK else "记录文件写入失败"
func report_stats226() -> Dictionary:
 var report:=super.report_stats226();report.runtime_preview=347
 report.erase("paper_theatre337")
 report.ordinary347={"batch":batch347+1,"seconds":age347,"defeated":kills347,"elite_defeated":elite_kills347,"result":result347,"events":events347.duplicate(true),"reward":"none"}
 return report
func _process(delta: float) -> void:
 super._process(delta)
 if not ready347:return
 guide206.text="347 纸怪遭遇 · %d / 5段 · 已击败%d\n%s · 场上纸怪%d / 精英%d\nC装配 / F7重开 / F4瞄准 / F6暂停\n%s"%[batch347+1,kills347,plan347()[maxi(0,batch347)].name,live347().size(),live347(true).size(),result347]
 phase_label326.hide();boss_bar326.hide()
 encounter_hud.header.text="纸怪遭遇 · "+loadout_name226
