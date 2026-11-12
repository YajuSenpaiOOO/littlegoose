extends "res://scripts/world/woodland_world348.gd"
func normal_script347() -> Script:return preload("res://scripts/combat/paper349.gd")
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 349 · 纸群飞入 / 主动俯冲")
func _ready() -> void:
 await super._ready()
 hint288.text="349 纸群飞入 / 主动俯冲\n镜头上方飘入 · 更主动接近与俯冲"
func report_stats226() -> Dictionary:
 var report:=super.report_stats226();report.runtime_preview=349
 report.crowd348.entry="offscreen_top_1.7_to_1.94s"
 report.crowd348.initial_attack_wait=.55
 report.crowd348.repeat_attack_wait=1.6
 return report
func _process(delta: float) -> void:
 super._process(delta)
 if ready347:guide206.text=guide206.text.replace("348 纸群遭遇","349 纸群遭遇")
