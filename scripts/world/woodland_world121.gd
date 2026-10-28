extends "res://scripts/world/woodland_world120.gd"
var save_retry121 := 0.
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 121 · 自然散场 / 团团蹦跳与倒地")
func _enemy_script() -> Script: return preload("res://scripts/combat/tuantuan121.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/hud121.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time121.gd")
func finish114() -> void:
 if not active114: return
 # Keep the existing defeat/retry menu when the player is knocked out.
 if player_hp<=0.: super.finish114();return
 active114=false
 results114["A"]={"kills":defeated_count,"hits":landed_hits,"shots":fired_count,"hurt":hurt_count,"parries":parry_count,"seconds":elapsed114}
 if won119: retry_reward119()
 combat_paused=false;wave_state="cleared";between_left=0.;ending119=-1.
 result_open=false;result_dismissed=true;result_at=-1.;reward_offered=true;refill114=0.
 target114=null;aim_tick114=-1;_clear_combat_shots();_cancel_charge();hero.cancel_guard109()
 hero.controls_enabled=true;hero.combat_impulse=Vector2.ZERO
 Engine.time_scale=1.;stop_until=0.;trial_ui114.menu.hide();draft_ui.close();encounter_hud.dismiss_result()
 clear_standby119();notice119=-1.;encounter_hud.notice_until=-1.;encounter_hud.response_until=-1.
 for actor in enemies:
  if is_instance_valid(actor) and not actor.dead:
   actor.mode119="ambient";actor.active_ai=false;actor.hit_area.collision_layer=0;actor.hopping=false;actor.impulse=Vector2.ZERO;actor.velocity=Vector3.ZERO;actor.attack_phase="approach"
func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(drops120) or active114 or not won119 or memory_kit116.last_reward119>=event119: return
 save_retry121-=delta
 if save_retry121<=0.: save_retry121=1.;retry_reward119()
