extends "res://scripts/world/woodland_world240.gd"
var plane_budget241 := 0.
var elapsed241 := 0.
func _init() -> void:
 super._init();rhythm236=preload("res://scripts/combat/music_clock241.gd").new()
 memory_save116="user://music241_preview.cfg";memory_kit116=preload("res://scripts/combat/memory_kit241.gd").new()
func balance_profile226() -> Script:return preload("res://scripts/combat/balance_profile241.gd")
func test_config_path226() -> String:return "user://boss_balance241.cfg"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 241 · 射速BPM / 剑雨节奏组合")
func _candy_script117() -> Script:return preload("res://scripts/combat/music_aim241.gd")
func reset_music236() -> void:
 super.reset_music236();elapsed241=0.;plane_budget241=0.
 if is_instance_valid(buffs):rhythm236.set_rate241(buffs.rate())
func music_budget_scale236() -> float:return rhythm236.period237()/maxf(.001,attack_cooldown())
func music_flights236() -> int:return paper_memories146.planes_launched146 if is_instance_valid(paper_memories146) else 0
func music_plane_budget236() -> float:return plane_budget241*1.25
func snapshot_packet146(target: Vector3,charged: bool,ratio: float,retire_all := false,carrier := true) -> Dictionary:
 var packet=super.snapshot_packet146(target,charged,ratio,retire_all,carrier)
 plane_budget241=0.
 if music_enabled236() and not packet.is_empty() and packet.plane:
  for spec in packet.specs:plane_budget241+=float(spec.damage)
 return packet
func advance_music236() -> void:
 var now=Time.get_ticks_usec()
 var delta=0. if stamp236==0 else float(now-stamp236)/1000000.
 stamp236=now
 if not music_running236():return
 elapsed241+=delta
 rhythm236.set_rate241(buffs.rate())
 if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):fire_needs_release=false
 var period=rhythm236.period237();var before=floori(rhythm236.time/period)
 rhythm236.step(delta,fire_input_held() and not suppress_auto237,music_allowed236())
 if floori(rhythm236.time/period)>before and is_instance_valid(music_audio236):music_audio236.tick235()
 flush_music236()
func music_sample_time240() -> float:return elapsed241
func _process(delta: float) -> void:
 super._process(delta)
 if ready228:guide206.text=guide206.text.replace("240","241").replace("120 BPM","%.0f BPM"%(60./rhythm236.period237()))
func report_stats226() -> Dictionary:
 if not recording226.final_report.is_empty() and recording226.final_report.has("music241"):return recording226.final_report.duplicate(true)
 var report=super.report_stats226()
 report.music240.perfect_ms=rhythm236.perfect_window237()*1000.;report.music240.great_ms=rhythm236.great_window237()*1000.
 report.music240.damage_unchanged=false
 report["music241"]={"bpm":60./rhythm236.period237(),"rate":buffs.rate(),"budget":"period / original cooldown; no double rate multiplier","blocked":["slingshot","flashlight"],"enabled":["balloon_sword","paper_plane"],"bpm_bounds":[30,480]}
 return report
func _tag_shot110(shot: Dictionary) -> void:
 super._tag_shot110(shot)
 if music_enabled236():tag_sword153(shot,buffs.level("balloon_sword")>0 and buffs.level("flashlight")==0)
