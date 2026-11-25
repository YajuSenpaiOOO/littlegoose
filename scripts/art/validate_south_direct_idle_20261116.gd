extends SceneTree
const Pose=preload("res://scripts/art/south_pose_direct_idle_20261116.gd")
func _initialize() -> void:
 var failures: Array=[]
 var transitions: Array=[]
 for mode in 3:
  var state=Pose.new();var last: String="idle";var sequence: Array=[last]
  for n in 650:
   var t:=n*.01
   var trigger: bool=t>=.98 and t<4.2
   var shot: bool=(n==98 or (mode==1 and n>=98 and n<420 and (n-98)%10==0)) and mode!=2
   var preparing: bool=t>=.8 and t<.98
   state.advance(.01,trigger,10. if mode==1 else 1.05,mode==2,shot,preparing)
   if state.phase!=last:
    if last=="release" and state.phase=="ready":failures.append("unwanted recovery pose")
    sequence.append(state.phase);last=state.phase
   if shot and state.phase!="release":failures.append("shot waits for animation")
   if mode==1 and trigger and state.phase!="release":failures.append("rapid flicker")
   if mode==2 and trigger and state.phase!="release":failures.append("beam not held release")
  if last!="idle":failures.append("did not restore idle")
  transitions.append(sequence)
 # No prerequisite preparation: an immediate shot must visibly release now.
 var immediate=Pose.new();immediate.advance(.001,true,1.,false,true,false)
 if immediate.phase!="release":failures.append("first shot requires wind-up")
 var f:=FileAccess.open("res://art/concepts/black_goose_south_attack_20261116/direct-idle-hold-validation.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"failures":failures,"sequences":transitions,"immediate_shot_pose":immediate.phase},"\t"));f.close()
 print("SOUTH_DIRECT_HOLD_DONE ",failures);quit(0 if failures.is_empty() else 1)
