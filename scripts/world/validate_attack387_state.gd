extends SceneTree
const Pose=preload("res://scripts/combat/attack_pose387.gd")
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
 # Base .34s cadence used to leave a .02s idle flash: now it must hold.
 var base=Pose.new();var blinks:=0
 for n in 500:
  base.advance(.01,true,1./.34,false,n%34==0,false)
  if base.phase!="release":blinks+=1
 if blinks>0:failures.append("base cadence flickers "+str(blinks))
 base.advance(.5,false,1./.34,false,false,false)
 if base.phase!="idle":failures.append("base release does not stop")
 var f:=FileAccess.open("res://docs/attack387-state-validation.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"failures":failures,"sequences":transitions,"immediate_shot_pose":immediate.phase},"\t"));f.close()
 print("ATTACK387_STATE_DONE ",failures);quit(0 if failures.is_empty() else 1)
