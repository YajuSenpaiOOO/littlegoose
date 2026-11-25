extends RefCounted
const ENTER_HOLD_HZ:=4.0
const EXIT_HOLD_HZ:=3.0
var phase:="idle"
var rapid:=false
var age_shot:=100.
var face_left:=0.0
var face_gate:=0.0
var kick:=0.0
var was_trigger:=false
var entries:=0
func advance(dt: float,trigger: bool,rate: float,beam: bool,shot: bool,preparing: bool) -> void:
 age_shot+=dt;face_left=maxf(0.,face_left-dt);face_gate=maxf(0.,face_gate-dt);kick*=exp(-dt*18.)
 if rapid:
  if rate<EXIT_HOLD_HZ:rapid=false
 elif rate>=ENTER_HOLD_HZ:rapid=true
 if shot:
  var first: bool=age_shot>.4
  age_shot=0.
  if not beam and (not rapid or face_gate<=0.):face_left=.10;face_gate=.6
  kick=(.65 if first else minf(.18,kick+.03)) if rapid else .8
 var held: bool=(trigger and (rapid or beam)) or preparing or age_shot<.28
 var next: String=("release" if face_left>0. and not beam else "ready") if held else "idle"
 if phase=="idle" and next!="idle":entries+=1
 phase=next;was_trigger=trigger
