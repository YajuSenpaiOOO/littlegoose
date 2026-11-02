extends "res://scripts/combat/music_clock240.gd"
var period241 := .5
func period237() -> float:return period241
func perfect_window237() -> float:return minf(.08,period241*.24)
func great_window237() -> float:return minf(.16,period241*.48)
func set_rate241(rate: float) -> void:
 var next=.5/clampf(rate,.25,4.)
 time*=next/period241;period241=next
func result237(beat: int,kind: String,offset := 0.) -> void:
 super.result237(beat,kind,offset);events[-1].bpm241=60./period241
