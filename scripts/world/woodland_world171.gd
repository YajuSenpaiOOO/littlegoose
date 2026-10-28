extends "res://scripts/world/woodland_world170.gd"
const MAX_SILK171 := 8
var silk171: Array[CharacterBody3D]=[]
var silk_clears171 := 0
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 171 · 小蜘蛛B / 搓丝团与屁股墩")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/spider_hud171.gd")
func _enemy_script() -> Script:
 return preload("res://scripts/combat/spider171.gd") if spider_trial170 else super._enemy_script()
func _ready() -> void:
 super._ready()
 while not is_instance_valid(arc_shadows167): await get_tree().physics_frame
 if "--silk171" in OS.get_cmdline_user_args(): start_spider170()
func reserve_spider170(actor: CharacterBody3D) -> bool:
 if not reserve_attack(actor): return false
 if is_instance_valid(attacker170) and not attacker170.dead and attacker170!=actor and attacker170.state170 in ["winding","push"]: return false
 attacker170=actor;return true
func release_silk171(actor: CharacterBody3D,direction: Vector2) -> void:
 if not spider_trial170 or not active114 or actor.dead or combat_paused: return
 while silk171.size()>=MAX_SILK171: remove_silk171(silk171[0])
 var ball: CharacterBody3D=_silk_script171().new();ball.battle=self;ball.direction171=direction
 var at := Vector2(actor.position.x,actor.position.z)+direction*.85
 ball.position=Vector3(at.x,floor_height(at)+.06,at.y)
 combat_effect_root159().add_child(ball);silk171.append(ball);_add_actor_shadow(ball,ball.visual);ball.reset_physics_interpolation()
func _silk_script171() -> Script: return preload("res://scripts/combat/silk_ball171.gd")
func remove_silk171(ball: CharacterBody3D) -> void:
 if target114==ball: target114=null;aim_tick114=-1
 silk171.erase(ball)
 if is_instance_valid(ball): ball.hide();ball.hit_area.collision_layer=0;ball.set_physics_process(false);ball.queue_free()
func clear_silk171() -> void:
 for ball in silk171.duplicate(): remove_silk171(ball)
 _prune_actor_shadows()
func _clear_combat_shots() -> void:
 super._clear_combat_shots();clear_silk171()
func enemy_defeated(actor: CharacterBody3D) -> void:
 if actor.has_meta("silk_ball171"): return
 super.enemy_defeated(actor)
func _apply_shot_hit(shot: Dictionary,hit: Dictionary) -> void:
 var ball: bool=hit.collider.has_meta("enemy") and is_instance_valid(hit.collider.get_meta("enemy")) and hit.collider.get_meta("enemy").has_meta("silk_ball171")
 var before := kills152
 super._apply_shot_hit(shot,hit)
 if ball: kills152=before
func silk_aim_candidate171(ball: CharacterBody3D,cursor: Vector2) -> bool:
 if not is_instance_valid(ball) or ball.dead: return false
 if aim_model.sprite_contains(camera,cursor,ball.visual): return true
 var origin := camera.unproject_position(hero.global_position+Vector3.UP*.8)
 var point := camera.unproject_position(ball.hit_area.global_position)-origin
 var pointer := cursor-origin
 var cone := .34 if target114==ball else .22
 return point.dot(pointer)>0. and absf(point.angle_to(pointer))<cone
func _refresh_aim114(cursor: Vector2) -> void:
 if not spider_trial170 or silk171.is_empty(): super._refresh_aim114(cursor);return
 # Extend only this synchronous aim query. Encounter counts, aircraft and
 # homing keep the real actor list; the normal scorer supplies occlusion/lead.
 var actors := enemies
 enemies=enemies.duplicate()
 for ball in silk171:
  if silk_aim_candidate171(ball,cursor): enemies.append(ball)
 super._refresh_aim114(cursor)
 enemies=actors
func announce152() -> void:
 if not spider_trial170: super.announce152();return
 if is_instance_valid(encounter_hud): encounter_hud.announce("小蜘蛛B · "+BUILDS170[build170].name,"小跳换位 → 搓丝团 → 推球坐倒 · 丝团可绕开或射散 · F6单/三只 F7重开 1—9换组合",4.)
func reward_text119() -> String:
 return "丝团试玩，不发材料、不推进正式进度；F7再玩一场。" if spider_trial170 else super.reward_text119()
