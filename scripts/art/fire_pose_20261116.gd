extends RefCounted
# Preview/state contract: projectile cadence is independent of pose restarts.
const ENTER_HOLD_HZ:=4.0
const EXIT_HOLD_HZ:=3.0
const RELEASE_SECONDS:=.22
var casting:=false
var rapid:=false
var since_shot:=100.
var kick:=0.0
var transitions:=0
var pulse_gate:=0.0
func advance(dt: float,trigger: bool,rate: float,beam: bool,shot: bool) -> void:
 since_shot+=dt;pulse_gate=maxf(0.,pulse_gate-dt);kick*=exp(-dt*18.)
 if rapid:
  if rate<EXIT_HOLD_HZ:rapid=false
 elif rate>=ENTER_HOLD_HZ:rapid=true
 if shot:since_shot=0.
 var next: bool=(trigger and (rapid or beam)) or since_shot<RELEASE_SECONDS
 if next!=casting:
  casting=next;transitions+=1
  if casting:kick=1.
 elif shot and casting and pulse_gate<=0.:
  kick=minf(.22,kick+.035) if rapid or beam else 1.
  pulse_gate=.12
