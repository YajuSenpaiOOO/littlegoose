extends SceneTree
func _initialize() -> void:
 var errors: Array=[];var results: Array=[]
 for mode in 3:
  var s=preload("res://scripts/art/fire_pose_two_frames_20261116.gd").new();var next:=1.12;var shots:=0;var ready:=0;var release:=0
  for i in 500:
   var t:=i*.01;var trigger:=t>=1. and t<3.2;var shot:=false
   if trigger and mode!=2 and t+.00001>=next:shot=true;shots+=1;next+=.1 if mode==1 else .65
   var prep: bool=trigger and (mode>0 or (next-t<=.12))
   s.advance(.01,trigger,10. if mode==1 else 1.54,mode==2,shot,prep)
   if s.phase=="ready":ready+=1
   if s.phase=="release":release+=1
   if mode>0 and t>1.01 and t<3.19 and s.phase=="idle":errors.append("held interrupted")
   if mode==2 and s.phase=="release":errors.append("beam flickered expression")
  if s.phase!="idle":errors.append("recovery")
  if mode>0 and s.entries!=1:errors.append("rapid/beam arm restarted")
  results.append({"mode":mode,"shots":shots,"arm_raises":s.entries,"ready_samples":ready,"release_samples":release})
 var f:=FileAccess.open("res://docs/two-frame-pose-20261116-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"errors":errors,"results":results},"\t"));f.close()
 print("TWO_FRAME_POSE_DONE ",errors);quit(0 if errors.is_empty() else 1)
