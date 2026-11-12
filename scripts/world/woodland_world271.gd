extends "res://scripts/world/woodland_world270.gd"
var actor_slot271 := 0
var pair_until271 := {}
var mixed_stats271 := {"ordinary_bumps":0,"head_ons":0,"glances":0}
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 271 · 团团碰碰车")
func roster_script264() -> Script:return preload("res://scripts/combat/mixed_roster271.gd")
func ambient_offsets264() -> Array:return [Vector2(-3,-1),Vector2(3,-1),Vector2(-1.5,2),Vector2(1.5,2)]
func minion_script260() -> Script:
 return preload("res://scripts/combat/tuantuan_roller271.gd") if actor_slot271<2 else preload("res://scripts/combat/tuantuan_bumped271.gd")
func ambient_minion264(at: Vector2) -> void:
 super.ambient_minion264(at);actor_slot271+=1
func yard264() -> void:
 actor_slot271=0;pair_until271.clear();super.yard264()
func ordinary264() -> void:
 pair_until271.clear();mixed_stats271={"ordinary_bumps":0,"head_ons":0,"glances":0};super.ordinary264()
 # Stagger initial rolls, keeping the same move and charge duration.
 var rollers=live_minions260().filter(func(m):return m.has_method("enter269"))
 if rollers.size()>1:rollers[1].timer269=-.55
func actor_collision271(roller: CharacterBody3D,other: Object,normal: Vector2) -> bool:
 return preload("res://scripts/combat/actor_collision272.gd").resolve(self,roller,other,normal)
func report_stats226() -> Dictionary:
 var report=super.report_stats226();report["mixed271"]=mixed_stats271.duplicate(true);report["encounter265"].initial=4;report["encounter265"].total=4;return report
func _process(delta: float) -> void:
 super._process(delta)
 if ready264 and mode264!="boss":guide206.text="271 团团碰碰车 · 两滚滚＋两普通\nE 开始 · 对撞双晕 / 擦碰变向 / 普通团团撞瘪\nC装配 · F7重试 / F8回开场 / F6暂停 / F3回院"
