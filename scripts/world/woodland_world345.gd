extends "res://scripts/world/woodland_world344.gd"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 345 · 城防紧凑换招")
func _ready() -> void:
 await super._ready()
 hint288.text="345 城防紧凑换招\n残影不拖换招 · 喘息0.45秒"
func recovery_gap344() -> float:return .45
func phase_clear344() -> bool:
 # Keep unresolved landing events blocking. Only the consumed blast's
 # remaining BOOM/ring animation is allowed to overlap the next windup.
 return jobs344.is_empty() and sweep331.is_empty() and heavies330.is_empty() and flights327.is_empty() and cannon_shots326.is_empty() and paper_queue334.is_empty() and blasts327.all(func(blast):return blast.get("resolved333",false))
func report_stats226() -> Dictionary:
 var report:=super.report_stats226();report.runtime_preview=345
 if report.has("paper_theatre337"):report.paper_theatre337.preview=345
 report.rhythm344.recovery_seconds=.45
 report.rhythm344.visual_tail_blocks=false
 return report
func _process(delta: float) -> void:
 super._process(delta)
 if is_instance_valid(theatre314):guide206.text=guide206.text.replace("344 城防弹幕","345 城防弹幕")
