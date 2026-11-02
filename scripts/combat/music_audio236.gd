extends "res://scripts/combat/music_audio235.gd"
var cursor236 := 0
var played236 := 0
func note236(_beat: int,perfect: bool) -> void:
 # Melody position belongs to emitted volleys, never the background beat clock.
 while int(MELODY[cursor236%MELODY.size()])<0:cursor236+=1
 super.note235(cursor236+1,perfect)
 cursor236=(cursor236+1)%MELODY.size();played236+=1
