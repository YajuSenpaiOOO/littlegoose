extends Node
var enabled := true
var voices: Array[AudioStreamPlayer]=[]
var hum: AudioStreamPlayer
var sounds := {}
var events: Array[String]=[]
var cursor := 0
func _ready() -> void:
 for key in ["switch","burst","bloom","hum","pulse","outro"]:sounds[key]=load("res://assets/transform_audio287/"+key+".wav")
 for i in 4:
  var voice=AudioStreamPlayer.new();voice.volume_db=-4.;add_child(voice);voices.append(voice)
 hum=AudioStreamPlayer.new();hum.volume_db=-11.;var stream=sounds.hum.duplicate() as AudioStreamWAV
 # Import may use QOA; loop positions are decoded sample frames, not byte count.
 var frames=roundi(stream.get_length()*stream.mix_rate)
 stream.loop_mode=AudioStreamWAV.LOOP_FORWARD;stream.loop_begin=0;stream.loop_end=frames;hum.stream=stream;add_child(hum)
func cue(key: String) -> void:
 events.append(key)
 if not enabled:return
 if key=="hum":hum.play();return
 var voice=voices[cursor%voices.size()];cursor+=1;voice.stream=sounds[key];voice.volume_db=-7. if key=="pulse" else -4.;voice.play()
func update_bed(red: bool,progress: float,strength: float) -> void:
 hum.pitch_scale=lerpf(1.,.88,progress) if red else 1.
 hum.volume_db=(-10. if red else -11.)+linear_to_db(maxf(.001,strength))
func stop_hum() -> void:hum.stop()
func stop_all() -> void:
 if is_instance_valid(hum):hum.stop()
 for voice in voices:voice.stop()
func set_enabled(value: bool) -> void:
 enabled=value
 if not enabled:stop_all()
