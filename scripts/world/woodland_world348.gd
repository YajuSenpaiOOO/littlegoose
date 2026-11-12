extends "res://scripts/world/woodland_world347.gd"
const PLAN348=[
 {"name":"纸怪成群飘来","normal":10,"elite":[]},
 {"name":"纸群与喷火","normal":10,"elite":["dinosaur"]},
 {"name":"纸群与骑士","normal":10,"elite":["knight"]},
 {"name":"纸群与怪兽","normal":10,"elite":["monster"]},
 {"name":"双精英收尾","normal":5,"elite":["dinosaur","knight"]}]
var tickets348: Dictionary={}
var cluster_points348: Dictionary={}
var normals348: Dictionary={}
var incoming348:="normal"
var admitted348:=0
var blocked348:=0
func plan347() -> Array:return PLAN348
func normal_script347() -> Script:return preload("res://scripts/combat/paper348.gd")
func normal_gap347() -> float:return .18
func normal_cap347(elite_count: int) -> int:return 4 if batch347==4 else (6 if elite_count>0 else 10)
func elite_gate347() -> int:return 4 if batch347==4 else 6
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 348 · 纸群割草试演")
func _ready() -> void:
 await super._ready()
 hint288.text="348 纸群割草试演\n低血量纸怪成簇入场 · 同时俯冲受限"
func restart301() -> void:
 tickets348.clear();cluster_points348.clear();normals348.clear();admitted348=0;blocked348=0
 super.restart301()
func queue_batch347() -> void:
 batch347+=1;batch_age347=0.
 var row: Dictionary=plan347()[batch347]
 var first:=int(row.normal) if row.elite.is_empty() else (3 if batch347==4 else 6)
 for i in first:jobs347.append({"type":"normal","due":float(i/3)*2.6+float(i%3)*.18})
 for i in row.elite.size():
  jobs347.append({"type":row.elite[i],"due":1.8 if batch347==4 else 3.4})
  if batch347==4 and i==0:
   for n in 2:jobs347.append({"type":"normal","due":3.8+float(n)*.18})
 if batch347!=4:
  for i in range(first,int(row.normal)):
   jobs347.append({"type":"normal","due":float(i/3)*2.6+float(i%3)*.18})
 log347("batch",{"name":row.name,"normal_quota":row.normal})
func spawn347(kind: String) -> CharacterBody3D:
 incoming348=kind
 var actor:=super.spawn347(kind)
 if kind=="normal":normals348[batch347]=int(normals348.get(batch347,0))+1
 return actor
func entry_point347() -> Vector2:
 if incoming348!="normal":return super.entry_point347()
 var n:=int(normals348.get(batch347,0))
 var key:="%d:%d"%[batch347,n/3]
 if not cluster_points348.has(key):cluster_points348[key]=super.entry_point347()
 var base: Vector2=cluster_points348[key]
 var point:=paper_clamp301(base+Vector2(float(n%3-1)*.5,float(n%2)*.35))
 var feet:=Vector2(hero.position.x,hero.position.z)
 return point if point.distance_to(feet)>=3. else super.entry_point347()
func reserve_dive348(actor: CharacterBody3D) -> bool:
 var active: Dictionary={}
 for paper in live347():
  if paper.paper_state129 in ["warning","gust"]:active[paper.get_instance_id()]=true
 for key in tickets348.keys():
  var ticket: Dictionary=tickets348[key]
  var paper: Object=ticket.actor.get_ref()
  if not is_instance_valid(paper) or paper.dead or (paper.paper_state129 not in ["warning","gust"] and age347>float(ticket.until)):
   tickets348.erase(key)
  else:active[key]=true
 var own:=actor.get_instance_id()
 if active.has(own):return true
 var limit:=3 if live347(true).is_empty() else 2
 if active.size()>=limit:blocked348+=1;return false
 tickets348[own]={"actor":weakref(actor),"until":age347+.1}
 admitted348+=1
 return true
func report_stats226() -> Dictionary:
 var report:=super.report_stats226();report.runtime_preview=348
 report.crowd348={"normal_total":45,"elite_total":5,"normal_hp":3.,"dive_admissions":admitted348,"dive_delays":blocked348,"caps":[10,6,4]}
 return report
func _process(delta: float) -> void:
 super._process(delta)
 if ready347:guide206.text=guide206.text.replace("347 纸怪遭遇","348 纸群遭遇")
