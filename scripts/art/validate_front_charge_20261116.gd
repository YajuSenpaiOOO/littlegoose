extends SceneTree
func _initialize() -> void:
 var s=preload("res://scripts/art/front_charge_state_20261116.gd").new();var failures: Array=[]
 for i in 250:s.advance(.01,true)
 if s.phase!="charge" or s.ratio!=1. or s.emissions!=0:failures.append("full charge must hold without auto release")
 var age: float=s.charge_age;s.advance(.5,false,true)
 if s.charge_age!=age or s.phase!="charge":failures.append("pause changed held pose")
 s.advance(.01,false)
 if s.phase!="release" or not s.emitted or s.emissions!=1:failures.append("release did not emit immediately on button up")
 for i in 35:s.advance(.01,false)
 if s.phase!="release":failures.append("release expression ended too soon")
 for i in 100:s.advance(.01,false)
 if s.phase!="idle" or s.emissions!=1 or absf(s.kick)>.001:failures.append("recovery did not settle or repeated shot")
 print("FRONT_CHARGE_STATE_DONE ",failures);quit(0 if failures.is_empty() else 1)
