extends "res://scripts/combat/music_clock237.gd"
var pressing239 := false
func press() -> void:
 pressing239=true;super.press();pressing239=false
func result237(beat: int,kind: String,offset := 0.) -> void:
 super.result237(beat,kind,offset)
 var event: Dictionary=events[-1]
 if kind in ["early","late"]:event.gain=1.2
 if pressing239 and float(event.gain)==0.:
  event.kind="miss_shot";event.ghost239=true
