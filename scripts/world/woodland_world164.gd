extends "res://scripts/world/woodland_world163.gd"
func _init() -> void:
 buffs=preload("res://scripts/combat/buff_book164.gd").new();buffs.rng110.randomize()
 memory_kit116=preload("res://scripts/combat/memory_kit164.gd").new();memory_save116="user://fixed_stage164.cfg"
func _moment_manager161() -> Script: return preload("res://scripts/combat/fixed_stage164.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 164 · 固定幻想舞台 / 圈内双倍射速")
func announce152() -> void:
 var tip := "Q脚下展开固定舞台 · 圈内射速+100% 伤害+30% · 7秒／结束后20秒冷却" if buffs.level("hero_moment")>0 else "Q课堂笔记对照 · 1—5／9切回幻想舞台"
 if is_instance_valid(encounter_hud): encounter_hud.announce(BUILDS161[build161].name,tip,3.)
func _ready() -> void:
 super._ready()
 while not is_instance_valid(moment161): await get_tree().physics_frame
 if "--field164" in OS.get_cmdline_user_args(): trial152=true;paper_trial129=false;start_combat()
