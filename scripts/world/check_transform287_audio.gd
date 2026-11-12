extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var sound=preload("res://scripts/art/transform_audio287.gd").new();root.add_child(sound)
 var stream=sound.hum.stream as AudioStreamWAV
 var ok=stream.loop_end==roundi(stream.get_length()*stream.mix_rate) and is_equal_approx(stream.get_length(),1.5)
 sound.cue("hum");await create_timer(.10).timeout;ok=ok and sound.hum.playing
 sound.stop_all();ok=ok and not sound.hum.playing
 var f=FileAccess.open("res://docs/transform287-audio-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"hum_loop_frames":stream.loop_end,"mix_rate":stream.mix_rate,"format":stream.format,"seconds":stream.get_length(),"heard_by_agent":false},"  "));f.close()
 sound.hum.stream=null;sound.queue_free();stream=null
 await create_timer(.10).timeout
 print("TRANSFORM287_AUDIO ",ok);quit(0 if ok else 1)
