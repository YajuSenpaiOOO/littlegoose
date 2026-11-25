extends "res://scripts/combat/goose_follow375.gd"
var motion376:=true
var body_clock376:=0.0
var stride_blend376:=0.0
func _physics_process(delta: float) -> void:
 var before:=walked375
 super._physics_process(delta)
 if not ready373 or not is_instance_valid(visual):return
 body_clock376+=delta
 var walking: bool=walked375>before or (preview374>0 and not host.sleeping362 and not host.leaving371)
 stride_blend376=move_toward(stride_blend376,1.0 if walking else 0.0,delta*8.0)
 if not motion376:
  visual.scale=Vector3.ONE;visual.rotation=Vector3.ZERO;visual.position=Vector3.ZERO;return
 var phase:=gait375 if preview374==0 else fposmod(clock373*2.4/4.0,1.0)
 var wave:=sin(phase*TAU)
 var step:=absf(wave)
 var blend:=stride_blend376
 var breath:=sin(body_clock376*PI*1.8)*.006*(1.0-blend)
 # Artwork foot anchor is local zero: stretch and roll around the soles.
 # Only the small stride lift leaves the ground; physics stays grounded.
 visual.scale=Vector3(1.0-breath-step*.018*blend,1.0+breath+step*.028*blend,1.0)
 visual.rotation=Vector3(0.0,0.0,-wave*.013*blend)
 visual.position=Vector3(0.0,step*.018*blend,0.0)
