extends Node
# Twinkle's public-domain melody; -1 holds the phrase ending without a new note.
const MELODY := [60,60,67,67,69,69,67,-1,65,65,64,64,62,62,60,-1,67,67,65,65,64,64,62,-1,67,67,65,65,64,64,62,-1,60,60,67,67,69,69,67,-1,65,65,64,64,62,62,60,-1]
var voices: Array[AudioStreamPlayer]=[]
var sounds := {}
var next_voice := 0
var tick: AudioStreamPlayer
func _ready() -> void:
 for midi in [60,62,64,65,67,69]:
  for suffix in ["_plain","_perfect"]:
   var key=str(midi)+suffix;sounds[key]=AudioStreamWAV.load_from_file("res://assets/music235/"+key+".wav")
 for i in 4:
  var voice=AudioStreamPlayer.new();voice.volume_db=-9.;add_child(voice);voices.append(voice)
 tick=AudioStreamPlayer.new();tick.stream=AudioStreamWAV.load_from_file("res://assets/music235/tick.wav");tick.volume_db=-15.;add_child(tick)
func note235(beat: int,perfect: bool) -> void:
 var midi: int=MELODY[posmod(beat-1,MELODY.size())]
 if midi<0:return
 var voice=voices[next_voice];next_voice=(next_voice+1)%voices.size()
 voice.stream=sounds[str(midi)+("_perfect" if perfect else "_plain")];voice.play()
func tick235() -> void:tick.play()
