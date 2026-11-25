extends RefCounted
const RELEASE_HOLD:=.32
var phase:="idle"
var rapid:=false
var since_shot:=100.0
var kick:=0.0
var velocity:=0.0
func advance(dt: float, trigger: bool, rate: float, beam: bool, shot: bool, preparing: bool) -> void:
 since_shot+=dt
 if rapid:
  if rate<3.:rapid=false
 elif rate>=4.:rapid=true
 if shot:
  since_shot=0.;velocity=minf(velocity+(.12 if rapid else .65),.8)
 # Bounded integration also handles slow rendered frames without spring blowup.
 var remaining:=dt
 while remaining>0.:
  var step:=minf(remaining,1./120.)
  velocity+=(-kick*170.-velocity*20.)*step;kick+=velocity*step;remaining-=step
 if beam:phase="release" if trigger else ("ready" if preparing else "idle")
 else:
  var held: bool=since_shot<RELEASE_HOLD or (rapid and trigger and since_shot<.4)
  phase="release" if held else ("ready" if preparing else "idle")
