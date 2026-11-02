extends "res://scripts/world/woodland_world262.gd"
var red_clock263 := 0.
var red_beacon263: Node3D
func _skills_script110() -> Script:return preload("res://scripts/combat/battle_skills263.gd")
func _encounter_hud_script37() -> Script:return preload("res://scripts/combat/boss_hud263.gd")
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 263 · 连续光线 / 红灯预警")
func red_pulse263() -> float:
 var phase=fmod(red_clock263, .72)
 return exp(-pow((phase-.07)/.055,2.))+ .58*exp(-pow((phase-.24)/.065,2.))
func _ready() -> void:
 await super._ready()
 red_beacon263=preload("res://scripts/combat/red_beacon263.gd").new();red_beacon263.battle=self;add_child(red_beacon263)
func begin251() -> void:
 red_clock263=0.;super.begin251()
func _process(delta: float) -> void:
 if active114 and flashlight_red229():
  if not combat_paused:red_clock263+=delta
 else:red_clock263=0.
 super._process(delta)
 if ready251:guide206.text=guide206.text.replace("262 团团Boss · 黏跳与红灯","263 团团Boss · 连续光线 / 红灯预警")
func report_stats226() -> Dictionary:
 var report=super.report_stats226();report["presentation263"]={"beam":"stable-width batched ribbon","red_pulse_period":.72,"damage_unchanged_from262":true};return report
