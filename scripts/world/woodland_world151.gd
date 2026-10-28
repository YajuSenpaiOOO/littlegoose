extends "res://scripts/world/woodland_world150.gd"
func _paper_manager_script146() -> Script: return preload("res://scripts/combat/paper_coverage151.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/paper_hud151.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 151 · 区域覆盖 / 六连投")
func _ready() -> void:
 super._ready()
 while not hill_ready146: await get_tree().physics_frame
 if "--coverage151" in OS.get_cmdline_user_args(): paper_trial129=true;start_combat()
func start_combat(reposition := true) -> void:
 super.start_combat(reposition)
 if hill_ready146 and paper_trial129: encounter_hud.announce("区域覆盖 · 快速六连投","左键圈定区域 · 圈内空中目标分配 · 1—6换组合 · Q笔记",3.)
