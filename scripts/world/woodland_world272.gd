extends "res://scripts/world/woodland_world268.gd"
var next_kind272 := "normal"
var pair_until271 := {}
var mixed_stats271 := {"ordinary_bumps":0,"head_ons":0,"glances":0}
var roller_stats269 := {"bounces":0,"parries":0,"stuns":0}
var admissions272: Array=[]
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 272 · 团团六批 / 碰碰车收尾")
func roster_script264() -> Script:return preload("res://scripts/combat/encounter_roster272.gd")
func minion_script260() -> Script:
 if next_kind272=="roller":return preload("res://scripts/combat/tuantuan_roller271.gd")
 if next_kind272=="predict":return preload("res://scripts/combat/tuantuan_predict272.gd")
 return preload("res://scripts/combat/tuantuan_bumped271.gd")
func yard264() -> void:
 next_kind272="normal";pair_until271.clear();super.yard264()
func ordinary264() -> void:
 pair_until271.clear();admissions272=[];mixed_stats271={"ordinary_bumps":0,"head_ons":0,"glances":0};roller_stats269={"bounces":0,"parries":0,"stuns":0};super.ordinary264()
func actor_collision271(roller: CharacterBody3D,other: Object,normal: Vector2) -> bool:
 return preload("res://scripts/combat/actor_collision272.gd").resolve(self,roller,other,normal)
func can_enter272(kind: String) -> bool:
 var live=live_minions260();var predictors=live.filter(func(m):return m.get_meta("kind272","normal")=="predict").size()
 var rollers=live.filter(func(m):return m.get_meta("kind272","normal")=="roller").size()
 if kind=="predict":return predictors==0
 if kind=="roller":return rollers<(3 if roster264.wave==5 else 1) and (predictors==0 if roster264.wave in [3,5] else true)
 return true
func spawn_minion260() -> CharacterBody3D:
 if mode264!="ordinary":next_kind272="normal";return super.spawn_minion260()
 if roster264.queue.is_empty():return null
 var kind: String=roster264.queue[0]
 if not can_enter272(kind):return null
 next_kind272=kind;flower_next268=kind=="predict";entry_notes261=1
 # Skip 268's fixed fifteen-member flower quota; retain native route planning and actor admission.
 var m=spawn_native272();next_kind272="normal";flower_next268=false
 if is_instance_valid(m):
  m.set_meta("kind272",kind);admissions272.append({"wave":roster264.wave,"kind":kind})
  if kind=="roller":m.timer269=-float(live_minions260().filter(func(n):return n.has_method("enter269")).size()-1)*.3
  if kind=="predict" and flower_stats268.spawned==0:say264("那只戴蓝花的，在看我们往哪跑呢！")
  if kind=="roller" and roster264.wave==3:say264("这朵玫瑰……怎么滚起来啦！")
  telemetry260.event("batch_entry",{"wave":roster264.wave,"kind":kind})
 return m
func select_flower268() -> bool:return mode264=="ordinary" and next_kind272=="predict"
func spawn_native272() -> CharacterBody3D:
 return super.spawn_minion260()
func cancel_entry261(m: CharacterBody3D) -> void:
 if mode264=="ordinary":roster264.cancelled_kind=m.get_meta("kind272","normal")
 super.cancel_entry261(m)
func report_stats226() -> Dictionary:
 var report=super.report_stats226();report["encounter265"]={"initial":3,"batches":roster264.BATCHES,"total":24,"rest_at":[rest_at265.x,rest_at265.y],"awake":awake265}
 report["encounter272"]={"admissions":admissions272.duplicate(true),"collisions":mixed_stats271.duplicate(true),"rollers":roller_stats269.duplicate(true)};return report
func summary_stats226() -> String:
 if mode264=="boss":return super.summary_stats226()
 return "团团六批 · %d / 24\n第%d / 6批 · 场上%d\n普通相撞%d / 对撞%d / 擦碰%d"%[roster264.defeated,roster264.wave+1,live_minions260().size(),mixed_stats271.ordinary_bumps,mixed_stats271.head_ons,mixed_stats271.glances]
func _process(delta: float) -> void:
 super._process(delta)
 if ready264:
  guide206.text=guide206.text.replace("268 林间空地","272 林间空地").replace("268 大团团挑战","272 大团团挑战").replace(" / 15"," / 24").replace(" / 4批"," / 6批")
