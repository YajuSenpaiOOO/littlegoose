extends "res://scripts/world/woodland_world108.gd"
var woodland_ready109 := false
func _hero_script() -> Script: return preload("res://scripts/combat/hero109.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/hud109.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time109.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 109 · 按住蹲防 / 松开冷却")
func _ready() -> void:
 super._ready()
 while not woodland_ready108: await get_tree().physics_frame
 woodland_ready109=true;_title35();time55.update_guide();print("WOODLAND109_READY")
func hurt_player(damage: float,from: Vector2) -> void:
 var guarded: bool=hero.guarding109 and not hero.knocked_down and not hero.story_knocked
 var hp_before := player_hp
 super.hurt_player(damage*hero.GUARD_DAMAGE109 if guarded else damage,from)
 if player_hp<hp_before and guarded:
  hero.guard_hits109+=1;hero.combat_impulse*=.6
  encounter_hud.respond("蹲防 −%d"%roundi(hp_before-player_hp),Color(.90,.82,.62))
 if player_hp<=0.: hero.cancel_guard109()
func _open_draft() -> void:
 hero.cancel_guard109();super._open_draft()
func _leave_encounter() -> void:
 if is_instance_valid(hero): hero.cancel_guard109()
 super._leave_encounter()
