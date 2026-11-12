extends "res://scripts/world/woodland_world268.gd"
var roller_stats269 := {"bounces":0,"parries":0,"stuns":0}
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 269 · 滚滚花团团独立试演")
func minion_script260() -> Script:return preload("res://scripts/combat/tuantuan_roller269.gd")
func roster_script264() -> Script:return preload("res://scripts/combat/roller_roster269.gd")
func ambient_offsets264() -> Array:return [Vector2(0,0)]
func ordinary264() -> void:
 roller_stats269={"bounces":0,"parries":0,"stuns":0};super.ordinary264()
func boss264() -> void:pass
func interact264() -> void:
 if mode264=="ambient":ordinary264()
 elif mode264=="ready":say264("它滚累啦。按F8，再陪它玩一次吧。")
func report_stats226() -> Dictionary:
 var report=super.report_stats226();report["roller269"]=roller_stats269.duplicate(true)
 report["encounter265"]={"initial":1,"batches":[],"total":1,"rest_at":[rest_at265.x,rest_at265.y],"awake":awake265};return report
func summary_stats226() -> String:return "滚滚花团团 · 独立试演\n撞墙 %d / 弹反 %d / 眩晕 %d"%[roller_stats269.bounces,roller_stats269.parries,roller_stats269.stuns]
func _process(delta: float) -> void:
 super._process(delta)
 if ready264 and mode264!="boss":guide206.text="269 滚滚花团团 · 独立试演\nE 开始 · 蓄力后直滚 / 撞墙反弹 / 停下眩晕\nC 装配 · F7重试 / F8回开场 / F6暂停 / F3回院"
