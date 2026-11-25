extends "res://scripts/combat/goose_follow374.gd"
const CYCLE_DISTANCE375=4.1/1.05
var gait375:=0.
var walked375:=0.
func advance_gait373(distance: float) -> void:
 if distance>.0005 and distance<.20:
  walked375+=distance;gait375=fposmod(gait375+distance/CYCLE_DISTANCE375,1.)
func frame_index373(walking: bool) -> int:
 return [1,2,3,2][int(gait375*4.)%4] if walking else 0

func _physics_process(delta: float) -> void:
 if preview374>0 and ready373 and not host.sleeping362 and not host.leaving371:
  clock373+=delta;velocity=Vector3.ZERO
  direction373="left" if preview374==1 else "right"
  apply_frame373([1,2,3,2][int(clock373*2.4)%4]);return
 super._physics_process(delta)
