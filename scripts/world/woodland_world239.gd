extends "res://scripts/world/woodland_world238.gd"
var ghosts239 := 0
func _init() -> void:
 super._init();rhythm236=preload("res://scripts/combat/music_clock239.gd").new()
 memory_save116="user://music239_preview.cfg";memory_kit116=preload("res://scripts/combat/memory_kit239.gd").new()
func test_config_path226() -> String:return "user://boss_balance239.cfg"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 239 · 点击必回应 / Great与空弹")
func _candy_script117() -> Script:return preload("res://scripts/combat/music_aim239.gd")
func flush_music236() -> void:
 for event in rhythm236.drain():
  if event.get("ghost239",false):
   ghosts239+=1
   if is_instance_valid(candy117):
    candy117.result237("miss_shot",float(event.offset));var aim=paper_aim146()
    if aim.is_finite():candy117.ghost239(aim)
   if is_instance_valid(music_audio236):
    var voice=music_audio236.next_voice
    music_audio236.note236(int(event.beat),false)
    music_audio236.voices[voice].volume_db=-21.
   continue
  if float(event.gain)>0. and is_instance_valid(music_audio236):
   music_audio236.voices[music_audio236.next_voice].volume_db=-9.
  rhythm236.events.append(event);super.flush_music236()
func reset_music236() -> void:
 super.reset_music236();ghosts239=0
 if is_instance_valid(candy117):candy117.ghosts239.clear()
func _process(delta: float) -> void:
 super._process(delta)
 if ready228:guide206.text=guide206.text.replace("238","239")
func report_stats226() -> Dictionary:
 var report=super.report_stats226();report["music239"]={"great_gain":1.2,"perfect_gain":1.4,"auto_gain":1.,"miss_gain":0.,"empty_shots":ghosts239,"ghosts":"visual only, no hit/slow/split"};return report
