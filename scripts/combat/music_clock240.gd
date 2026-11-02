extends "res://scripts/combat/music_clock239.gd"
func result237(beat: int,kind: String,offset := 0.) -> void:
 super.result237(beat,kind,offset)
 events[-1].resolved240=pressing239 and float(events[-1].gain)==0. and beat<=last
