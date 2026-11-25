extends RefCounted
# Visual-only prototype. Existing gameplay charge_time is .72 / buffs.rate().
const CHARGE_TIME:=.72
const RELEASE_HOLD:=.42
var phase:="idle"
var charge_age:=0.0
var ratio:=0.0
var release_age:=100.0
var held_before:=false
var emitted:=false
var emissions:=0
var kick:=0.0
var velocity:=0.0
func advance(dt: float,held: bool,paused:=false) -> void:
 emitted=false
 if paused:return
 release_age+=dt
 if held:
  if not held_before:charge_age=0.0
  charge_age+=dt;ratio=clampf(charge_age/CHARGE_TIME,0.,1.);phase="charge"
 elif held_before:
  phase="release";release_age=0.;emitted=true;emissions+=1;velocity=.95
 elif phase=="release" and release_age>=RELEASE_HOLD:phase="idle"
 held_before=held
 var remaining:=dt
 while remaining>0.:
  var step:=minf(remaining,1./120.)
  velocity+=(-kick*115.-velocity*14.)*step;kick+=velocity*step;remaining-=step
