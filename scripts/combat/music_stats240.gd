extends RefCounted
const KEYS=["perfect","great","empty_click","auto","missed_beat","skip"]
var counts := {}
var phases := {}
var offsets: Array[float]=[]
var histogram := [0,0,0,0,0,0,0,0]
var total_offsets := 0
var sum_ms := 0.
var sum_sq := 0.
var early := 0
var late := 0
var resolved_clicks := 0
var samples: Array[Dictionary]=[]
func reset() -> void:
 counts.clear();phases.clear();offsets.clear();histogram=[0,0,0,0,0,0,0,0];total_offsets=0;sum_ms=0.;sum_sq=0.;early=0;late=0;resolved_clicks=0;samples.clear()
func observe(event: Dictionary,phase: String,time: float) -> void:
 var kind=str(event.kind)
 var key={"perfect":"perfect","early":"great","late":"great","miss_shot":"empty_click","auto":"auto","miss":"missed_beat","skip":"skip"}.get(kind,"")
 if key=="":return
 counts[key]=int(counts.get(key,0))+1
 if not phases.has(phase):phases[phase]={}
 phases[phase][key]=int(phases[phase].get(key,0))+1
 var manual=kind in ["perfect","early","late","miss_shot"]
 var resolved=bool(event.get("resolved240",false))
 if resolved:resolved_clicks+=1
 var ms=float(event.offset)*1000.
 # Already-resolved-beat spam is reported separately, not timing calibration evidence.
 if manual and not resolved:
  total_offsets+=1;sum_ms+=ms;sum_sq+=ms*ms
  if ms<0.:early+=1
  elif ms>0.:late+=1
  var bin=0
  for edge in [-160.,-80.,-40.,0.,40.,80.,160.]:
   if ms>=edge:bin+=1
  histogram[bin]+=1
  if offsets.size()<5000:offsets.append(ms)
 if samples.size()<2000:samples.append({"time":time,"phase":phase,"beat":event.beat,"kind":kind,"gain":event.gain,"offset_ms":ms if manual else null,"resolved_beat":resolved,"bpm":event.get("bpm241",null)})
func report() -> Dictionary:
 var outputs=int(counts.get("perfect",0))+int(counts.get("great",0))+int(counts.get("empty_click",0))+int(counts.get("auto",0))
 var manual=outputs-int(counts.get("auto",0))
 var ratios={};var full={}
 for key in KEYS:
  full[key]=int(counts.get(key,0))
  if key in ["perfect","great","empty_click","auto"]:ratios[key]=float(full[key])/outputs if outputs>0 else 0.
 var ordered=offsets.duplicate();ordered.sort()
 var median=null;var p95=null
 if not ordered.is_empty():
  var n=ordered.size();median=ordered[n/2] if n%2 else (ordered[n/2-1]+ordered[n/2])*.5
  var absolute=offsets.duplicate()
  for i in absolute.size():absolute[i]=absf(absolute[i])
  absolute.sort();p95=absolute[maxi(0,ceili(n*.95)-1)]
 return {"counts":full,"output_count":outputs,"manual_clicks":manual,"output_ratios":ratios,"manual_perfect_ratio":float(full.perfect)/manual if manual>0 else 0.,"by_phase":phases.duplicate(true),"timing":{"count":total_offsets,"negative_is_early":true,"early":early,"late":late,"mean_ms":sum_ms/total_offsets if total_offsets>0 else null,"std_ms":sqrt(maxf(0.,sum_sq/total_offsets-pow(sum_ms/total_offsets,2.))) if total_offsets>0 else null,"median_ms":median,"p95_absolute_ms":p95,"quantiles_sample_cap":5000,"histogram_edges_ms":[-160,-80,-40,0,40,80,160],"histogram":histogram.duplicate(),"excluded_resolved_beat_clicks":resolved_clicks},"event_samples":samples.duplicate(true),"event_sample_cap":2000,"ratio_note":"Output ratios count manual clicks plus auto volleys; missed beats and skips are separate, not added twice."}
