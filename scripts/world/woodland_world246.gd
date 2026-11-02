extends "res://scripts/world/woodland_world245.gd"
func _init() -> void:
 super._init();memory_save116="user://relay246_preview.cfg";memory_kit116=preload("res://scripts/combat/memory_kit246.gd").new()
func test_config_path226() -> String:return "user://boss_balance246.cfg"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 246 · 留旗接棒 / 只让鹅转头")
func relay_script245() -> Script:return preload("res://scripts/combat/relay_flag246.gd")
func can_plant245() -> bool:return not is_instance_valid(relay245) or relay245.phase=="gone"
func _process(delta: float) -> void:
 super._process(delta)
 if ready228:guide206.text=guide206.text.replace("245","246")
func report_stats226() -> Dictionary:
 if not recording226.final_report.is_empty() and recording226.final_report.has("relay246"):return recording226.final_report.duplicate(true)
 var report=super.report_stats226();report["relay246"]={"wait":"until next attack, no timeout","repeat_dodge":"keep existing flag and pending packet","turning":"goose only, fixed cloth and pencil","gain":relay_gain245};return report
