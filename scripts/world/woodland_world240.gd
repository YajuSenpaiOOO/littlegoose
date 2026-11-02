extends "res://scripts/world/woodland_world239.gd"
var music_stats240=preload("res://scripts/combat/music_stats240.gd").new()
var music_record240=preload("res://scripts/combat/music_stats240.gd").new()
func _init() -> void:
 super._init();rhythm236=preload("res://scripts/combat/music_clock240.gd").new();memory_save116="user://music240_preview.cfg"
func test_config_path226() -> String:return "user://boss_balance240.cfg"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 240 · 节奏采集 / 判定提示优化")
func _candy_script117() -> Script:return preload("res://scripts/combat/music_aim240.gd")
func reset_music236() -> void:
 super.reset_music236();music_stats240.reset();music_record240.reset()
func flush_music236() -> void:
 var pending=rhythm236.drain()
 for event in pending:
  music_stats240.observe(event,battle_phase220,music_sample_time240())
  if recording226.active:music_record240.observe(event,battle_phase220,music_sample_time240())
  if is_instance_valid(candy117):candy117.resolved240=bool(event.get("resolved240",false))
  rhythm236.events.append(event);super.flush_music236()
func report_stats226() -> Dictionary:
 if not recording226.final_report.is_empty() and recording226.final_report.has("music240"):return recording226.final_report.duplicate(true)
 var report=super.report_stats226()
 report["music240"]={"schema_version":1,"session":music_stats240.report(),"recording":music_record240.report(),"clock":"unpaused real seconds; negative offset = early","perfect_ms":80,"great_ms":160,"damage_unchanged":true}
 return report
func summary_stats226() -> String:
 var text=super.summary_stats226()
 var data=music_stats240.report();var c=data.counts;var t=data.timing
 text+="\n乐器课 P %d / Great %d / 空弹 %d / 自动 %d\n漏拍 %d · 避让跳拍 %d"%[c.perfect,c.great,c.empty_click,c.auto,c.missed_beat,c.skip]
 var ratio=data.output_ratios
 text+="\n发射占比 P %.0f%% / G %.0f%% / 空 %.0f%% / 自动 %.0f%%"%[ratio.perfect*100.,ratio.great*100.,ratio.empty_click*100.,ratio.auto*100.]
 if t.count>0:text+="\n点击均值 %+.0fms · 中位 %+.0fms · 负早/正晚"%[float(t.mean_ms),float(t.median_ms)]
 return text
func _process(delta: float) -> void:
 super._process(delta)
 if ready228:guide206.text=guide206.text.replace("239","240")

func music_sample_time240() -> float:return rhythm236.time
