extends Node
var voices: Array[AudioStreamPlayer]=[]
var clip: AudioStreamWAV
var last := -1000000
var requests := 0
var played := 0
var merged := 0
var next := 0
func _ready() -> void:
 clip=AudioStreamWAV.load_from_file("res://assets/music242/soft_contact.wav")
 for i in 2:
  var player=AudioStreamPlayer.new();player.stream=clip;player.volume_db=-18.;add_child(player);voices.append(player)
func contact() -> void:
 requests+=1
 var now=Time.get_ticks_usec()
 if now-last<70000:merged+=1;return
 last=now;played+=1;voices[next].play();next=(next+1)%voices.size()
