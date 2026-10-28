extends RefCounted
## Exact critically damped spring: stable across render rates, no physics motion.
var position := Vector3.ZERO
var velocity := Vector3.ZERO
var target_before := Vector3.ZERO
var initialized := false
func reset() -> void:
 initialized=false;velocity=Vector3.ZERO
func advance(target: Vector3,delta: float,frequency: float=12.,snap_distance: float=5.) -> Vector3:
 if not initialized or target.distance_squared_to(target_before)>snap_distance*snap_distance:
  position=target;velocity=Vector3.ZERO;target_before=target;initialized=true;return position
 target_before=target
 if delta<=0.: return position
 var offset := position-target
 var j := velocity+offset*frequency
 var decay := exp(-frequency*delta)
 position=target+(offset+j*delta)*decay
 velocity=(velocity-j*frequency*delta)*decay
 return position
