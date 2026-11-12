extends "res://scripts/world/woodland_world343.gd"
const ORDER344: Array[int]=[0,1,2,4]
const DURATIONS344: Dictionary={0:4.8,1:6.4,2:5.8,4:6.8}
var order344:=0
var phase_age344:=0.
var breath344:=0.
var jobs344: Array[Dictionary]=[]
var paired_mortar344:=-1
var rhythm344:="开场 · 重纸弹"
var events344: Array[Dictionary]=[]
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 344 · 城防错拍配合")
func _ready() -> void:
 await super._ready()
 hint288.text="344 城防错拍配合\n压副炮可打断配合 · 招式收尾有喘息"
func restart301() -> void:
 jobs344.clear();events344.clear();paired_mortar344=-1
 order344=0;phase_age344=0.;breath344=0.;rhythm344="开场 · 重纸弹"
 super.restart301()
 phase331=0;pattern_started327=false;pattern_left327=DURATIONS344[0];volley_left327=.45
func log344(kind: String,source: int) -> void:
 if events344.size()<256:events344.append({"kind":kind,"source":source,"phase":phase331,"age":phase_age344})
func recovery_gap344() -> float:return .85
func phase_clear344() -> bool:
 return jobs344.is_empty() and sweep331.is_empty() and heavies330.is_empty() and flights327.is_empty() and blasts327.is_empty() and cannon_shots326.is_empty() and paper_queue334.is_empty()
func tick_pattern327(delta: float) -> void:
 phase_age344+=delta;pattern_left327-=delta;volley_left327-=delta
 tick_sweep331(delta)
 for i in range(jobs344.size()-1,-1,-1):
  var job:=jobs344[i]
  job.left-=delta
  if cannon_hp326[job.source]<=0.:
   jobs344.remove_at(i);continue
  if job.left>0.:continue
  charge_heavy330(job.source);record_source336(job.source);log344("ring_follow_heavy",job.source)
  jobs344.remove_at(i)
 if pattern_left327<=0.:
  if not phase_clear344():breath344=0.;return
  breath344+=delta;rhythm344="纸幕散去 · 抓紧输出"
  if breath344<recovery_gap344():return
  # Opening solo heavy occurs once; the repeat loop has two duets and a meteor row.
  order344=order344+1 if order344<3 else 1
  phase331=ORDER344[order344];attack330=[0,1,1,2,3][phase331];pattern327=[0,0,0,1,2][phase331]
  pattern_left327=DURATIONS344[phase331];phase_age344=0.;breath344=0.
  pattern_started327=false;volley_left327=.45;paired_mortar344=-1
  rhythm344={1:"往返扫射＋错拍迫击",2:"缺口纸环 → 蓄力重纸弹",4:"有序流星 · 留意间隔"}.get(phase331,"")
 var source:=live_device327()
 if source<0 or pattern_started327:return
 theatre314.aim_cannon326(source,volley_left327<.55)
 if volley_left327>0.:return
 pattern_started327=true
 match phase331:
  0:charge_heavy330(source);record_source336(source);log344("opening_heavy",source)
  1:
   start_sweep331(source);record_source336(source);log344("sweep",source)
   var partner:=1-source
   if cannon_hp326[partner]>0.:
    paired_mortar344=source
    for i in 3:
     var before:=flights327.size()
     add_flight327(Vector2(hero.global_position.x,hero.global_position.z),.9+float(i)*.85,1.65,partner,false)
     if flights327.size()>before:flights327[-1].paired_lead344=source
    log344("paired_mortar",partner)
  2:
   normal_form335=3
   scatter327(source);record_source336(source);log344("gap_ring",source)
   var partner:=1-source
   if cannon_hp326[partner]>0.:
    # Ring launches after .5s. Heavy begins charging .8s after that,
    # then retains its full 1.15s charge and standard flight/parry rules.
    jobs344.append({"source":partner,"lead":source,"left":1.3})
  4:meteor_row327(source);record_source336(source);log344("meteor_row",source)
func interrupt327(source :=-1) -> void:
 jobs344=jobs344.filter(func(job):return source>=0 and job.source!=source and job.lead!=source)
 for i in range(flights327.size()-1,-1,-1):
  var flight:=flights327[i]
  if flight.has("paired_lead344") and (source<0 or flight.paired_lead344==source) and not flight.sprite.visible:
   remove_flight327(i)
 super.interrupt327(source)
func clear_patterns327() -> void:
 jobs344.clear();paired_mortar344=-1;breath344=0.
 super.clear_patterns327()
func report_stats226() -> Dictionary:
 var report:=super.report_stats226();report.runtime_preview=344
 if report.has("paper_theatre337"):report.paper_theatre337.preview=344
 report.rhythm344={"phase":rhythm344,"events":events344.duplicate(true)}
 return report
func _process(delta: float) -> void:
 super._process(delta)
 if is_instance_valid(theatre314):
  guide206.text=guide206.text.replace("343 城防弹幕","344 城防弹幕")
  phase_label326.text=rhythm344+(" · 重纸弹可弹回" if phase331 in [0,2] else "")
