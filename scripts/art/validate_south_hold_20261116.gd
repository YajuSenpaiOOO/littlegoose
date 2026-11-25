extends SceneTree
const Pose=preload("res://scripts/art/south_pose_hold_20261116.gd")
func _initialize() -> void:
 var failures: Array=[]
 var release_windows: Array=[]
 var transition_counts: Array=[]
 for mode in 3:
  var state=Pose.new();var previous: String="idle";var changes:=0;var first_release:=-1.;var end_release:=-1.
  var last: String="idle"
  for n in 650:
   var t:=n*.01;var trigger: bool=t>=.8 and t<4.2
   var shot: bool=(n==98 or (mode==1 and n>=98 and n<420 and (n-98)%10==0)) and mode!=2
   state.advance(.01,trigger,10. if mode==1 else 1.05,mode==2,shot,trigger and (mode==2 or t<.98))
   if state.phase!=previous: changes+=1;previous=state.phase
   if state.phase=="release" and first_release<0.:first_release=t
   if first_release>=0. and end_release<0. and state.phase!="release":end_release=t
   if mode==1 and t>=.98 and t<4.2 and state.phase!="release":failures.append("rapid posture flickered at "+str(t))
   if mode==2 and trigger and state.phase!="ready":failures.append("beam posture flickered at "+str(t))
   if not is_finite(state.kick) or absf(state.kick)>.08:failures.append("unstable recoil")
   last=state.phase
  if last!="idle":failures.append("did not recover idle")
  transition_counts.append(changes)
  release_windows.append(end_release-first_release if mode!=2 else 0.)
 if release_windows[0]<.31:failures.append("single shot smile released too early")
 if transition_counts[1]>5:failures.append("rapid replays full pose cycle")
 var f:=FileAccess.open("res://art/concepts/black_goose_south_attack_20261116/hold-validation.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"failures":failures,"release_windows":release_windows,"transition_counts":transition_counts},"\t"));f.close()
 print("SOUTH_HOLD_DONE ",failures);quit(0 if failures.is_empty() else 1)
