extends "res://scripts/world/woodland_world261.gd"
const FLASH_BASE262 := .7
const FLASH_RED262 := 1.4
func _init() -> void:
 super._init();memory_kit116=preload("res://scripts/combat/memory_kit262.gd").new()
func boss_script251() -> Script:return preload("res://scripts/combat/tuantuan_boss262.gd")
func minion_script260() -> Script:return preload("res://scripts/combat/tuantuan_minion262.gd")
func flashlight_damage_gain110() -> float:return FLASH_RED262 if flashlight_red229() else FLASH_BASE262
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 262 · 气球剑黏跳 / 红灯光线")
func report_stats226() -> Dictionary:
 var report=super.report_stats226()
 report.balance229.flashlight_damage_gain=FLASH_RED262/FLASH_BASE262
 report.balance229["flashlight_base_gain"]=FLASH_BASE262
 report.balance229["flashlight_red_absolute_gain"]=FLASH_RED262
 report["balance262"]={"flashlight_normal":FLASH_BASE262,"flashlight_red":FLASH_RED262,"red_relative":2.,"red_threshold":"health_fraction < 1/3","minion_lunge_slow_cap":.4,"boss_horizontal_slow_cap":.2,"flight_timing_changed":false,"reflected_bounce_slowed":false}
 return report
func _process(delta: float) -> void:
 super._process(delta)
 if ready251:
  guide206.text=guide206.text.replace("261 团团Boss · 林边入场","262 团团Boss · 黏跳与红灯")
  if active114 and flashlight_red229():guide206.text+="\n红灯：手电伤害×2"
