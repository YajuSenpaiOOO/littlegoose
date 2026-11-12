extends "res://scripts/world/woodland_world266.gd"
var flower_next268 := false
var flower_stats268 := {"spawned":0,"predictions":0}
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 268 · 花团团 / 抢前路")
func minion_script260() -> Script:return preload("res://scripts/combat/tuantuan_minion268.gd")
func ordinary264() -> void:
 flower_stats268={"spawned":0,"predictions":0};super.ordinary264()
func select_flower268() -> bool:
 var wanted=1 if roster264.spawned<10 else 2
 return mode264=="ordinary" and roster264.spawned>=6 and flower_stats268.spawned<wanted and not live_minions260().any(func(m):return m.flower268)
func spawn_minion260() -> CharacterBody3D:
 flower_next268=select_flower268()
 var m=super.spawn_minion260();flower_next268=false
 if is_instance_valid(m) and m.flower268:
  flower_stats268.spawned+=1;telemetry260.event("flower_entry",{"actor":m.role110,"wave":roster264.wave})
  if flower_stats268.spawned==1:say264("那只戴花的，好像在看我们往哪跑！")
 return m
func report_stats226() -> Dictionary:
 var report=super.report_stats226();report["flower268"]=flower_stats268.duplicate(true);return report
func _process(delta: float) -> void:
 super._process(delta)
 if ready264:guide206.text=guide206.text.replace("266 林间空地","268 林间空地").replace("266 大团团挑战","268 大团团挑战")
