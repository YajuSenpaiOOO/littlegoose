extends RefCounted
var data := {}
var current := {}
var last_attempts := 0
var last_whiffs := 0
func begin(w: Node) -> void:
 data={"schema_version":1,"clock":"unpaused scaled physics seconds","physics_seconds":0.,"phase_seconds":{},"boss":{"hp_start":w.cat_health226,"damage":0.,"hit_events":0,"chains":0,"landings":0,"wall_crashes":0,"damage_by_source":{},"damage_by_phase":{}},"minions":{"spawned":0,"defeated":0,"thrown":0,"damage":0.,"hit_events":0,"damage_by_source":{}},"parries":{"total":0,"boss":0,"minion":0,"other":0},"inputs":{"parry_attempts":0,"parry_whiffs":0,"dashes":0,"perfect_dodges":0},"injuries":[],"rounds":[],"events":[],"event_cap":400,"finalized":false}
 last_attempts=w.hero.parry_starts;last_whiffs=w.hero.parry_whiffs
 if is_instance_valid(w.boss247) and w.boss247.is_inside_tree() and w.boss247.phase247 not in ["rest","pounce_wait","pounce"]:open_round(true)
func phase(w: Node) -> String:
 if not is_instance_valid(w.boss247):return "rest"
 return {"angry":"preparation","squat":"preparation","flight":"bounce","rebound":"bounce","deflected":"bounce","flat":"recovery","pounce_wait":"pounce_preparation","pounce":"pounce","bumper":"wall_stagger"}.get(w.boss247.phase247,"rest")
func add(bucket: Dictionary,key: String,value: float) -> void:bucket[key]=float(bucket.get(key,0.))+value
func event(kind: String,details: Dictionary={}) -> void:
 if data.is_empty() or data.finalized or data.events.size()>=data.event_cap:return
 var sample=details.duplicate(true);sample["kind"]=kind;sample["time"]=data.physics_seconds;data.events.append(sample)
func poll(w: Node) -> void:
 if data.is_empty() or data.finalized:return
 var attempts=w.hero.parry_starts;var whiffs=w.hero.parry_whiffs
 data.inputs.parry_attempts+=maxi(0,attempts-last_attempts) if attempts>=last_attempts else attempts
 data.inputs.parry_whiffs+=maxi(0,whiffs-last_whiffs) if whiffs>=last_whiffs else whiffs
 last_attempts=attempts;last_whiffs=whiffs
func tick(w: Node,delta: float) -> void:
 if data.is_empty() or data.finalized:return
 poll(w);data.physics_seconds+=delta;add(data.phase_seconds,phase(w),delta)
 if not current.is_empty():current.seconds+=delta
func open_round(partial: bool=false) -> void:
 close_round("next_round",true)
 if not partial:data.boss.chains+=1
 current={"index":data.rounds.size()+1,"start":data.physics_seconds,"seconds":0.,"partial":partial,"boss_damage":0.,"minion_damage":0.,"recovery_damage":0.,"parries":0,"dashes":0,"injuries":0,"landings":0,"minions_thrown":0}
func close_round(reason: String,partial: bool=false) -> void:
 if current.is_empty():return
 current["end"]=data.physics_seconds;current["reason"]=reason;current.partial=current.partial or partial
 data.rounds.append(current.duplicate(true));current.clear()
func phase_changed(old: String,next: String) -> void:
 if data.is_empty() or data.finalized:return
 if next=="angry":open_round()
 if old=="flat" and next!="flat":close_round("recovery_complete")
 event("boss_phase",{"from":old,"to":next})
func damage(w: Node,boss: bool,amount: float,source: String) -> void:
 if data.is_empty() or data.finalized or amount<=0.:return
 var target=data.boss if boss else data.minions
 target.damage+=amount;target.hit_events+=1;add(target.damage_by_source,source,amount)
 if boss:add(data.boss.damage_by_phase,phase(w),amount)
 if not current.is_empty():
  if boss:
   current.boss_damage+=amount
   if phase(w)=="recovery":current.recovery_damage+=amount
  else:current.minion_damage+=amount
func parry(source: String) -> void:
 if data.is_empty() or data.finalized:return
 data.parries.total+=1;data.parries[source]=int(data.parries.get(source,0))+1
 if not current.is_empty():current.parries+=1
 event("parry",{"target":source})
func dash() -> void:
 if data.is_empty() or data.finalized:return
 data.inputs.dashes+=1
 if not current.is_empty():current.dashes+=1
 event("dash")
func injury(w: Node,amount: float,source: String) -> void:
 if data.is_empty() or data.finalized:return
 var item={"time":data.physics_seconds,"phase":phase(w),"source":source,"loss":amount};data.injuries.append(item)
 if not current.is_empty():current.injuries+=1
 event("injury",item)
func landing(index: int) -> void:
 if data.is_empty() or data.finalized:return
 data.boss.landings+=1
 if not current.is_empty():current.landings+=1
 event("boss_landing",{"jump":index+1})
func thrown() -> void:
 if data.is_empty() or data.finalized:return
 data.minions.thrown+=1
 if not current.is_empty():current.minions_thrown+=1
 event("minion_thrown")
func finish(w: Node,reason: String) -> void:
 if data.is_empty() or data.finalized:return
 poll(w);data.minions["alive_at_end"]=w.live_minions260().size();close_round(reason,true);event("encounter_end",{"reason":reason});data.finalized=true
func snapshot(w: Node) -> Dictionary:
 poll(w)
 var report=data.duplicate(true)
 if not current.is_empty():report["current_round"]=current.duplicate(true)
 return report
