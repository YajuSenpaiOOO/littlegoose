extends SceneTree
func _initialize() -> void:
 var failures: Array=[];var report: Dictionary={}
 for mode in 3:
  var state=preload("res://scripts/art/fire_pose_20261116.gd").new()
  var count:=0;var next:=1.
  for i in 500:
   var t:=float(i)*.01;var trigger:=t>=1. and t<3.2
   var shot:=false
   if trigger and mode!=2 and t+.0001>=next:shot=true;count+=1;next+=.1 if mode==1 else .65
   state.advance(.01,trigger,10. if mode==1 else 1.54,mode==2,shot)
   if mode>0 and t>1.02 and t<3.19 and not state.casting:failures.append("held pose dropped")
  if state.casting:failures.append("did not recover")
  if mode>0 and state.transitions!=2:failures.append("rapid/beam pose restarted")
  report[str(mode)]={"shots":count,"pose_transitions":state.transitions}
 var state=preload("res://scripts/art/fire_pose_20261116.gd").new()
 state.advance(.01,true,4.,false,true)
 for rate in [3.9,3.2,3.7]:state.advance(.01,true,rate,false,false)
 if not state.rapid:failures.append("rate hysteresis")
 state.advance(.01,true,2.9,false,false)
 if state.rapid:failures.append("rate exit")
 report.failures=failures
 var f:=FileAccess.open("res://docs/fire-pose-20261116-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"\t"));f.close()
 print("FIRE_POSE_DONE ",failures);quit(0 if failures.is_empty() else 1)
