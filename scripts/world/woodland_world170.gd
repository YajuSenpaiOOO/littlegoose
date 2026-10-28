extends "res://scripts/world/woodland_world169.gd"
const BUILDS170 := [
 {"name":"三鹅快射","levels":{"three_player":1,"eye_exercise":1}},
 {"name":"三鹅弹弓","levels":{"three_player":1,"slingshot":1}},
 {"name":"三鹅飞机＋笔记","levels":{"three_player":1,"paper_plane":1,"homework":1}},
 {"name":"三鹅飞机气球剑","levels":{"three_player":1,"paper_plane":1,"balloon_sword":1}},
 {"name":"糖屑舞步","levels":{"snack":1,"exercise":1,"eye_exercise":1}},
 {"name":"双鹅小窝舞台","levels":{"forest_fireboy":1,"pillow_hut":1,"hero_moment":1,"eye_exercise":1}},
 {"name":"三鹅气球剑快射","levels":{"three_player":1,"balloon_sword":1,"eye_exercise":1}},
 {"name":"住校四鹅快射","levels":{"boarding_school":1,"eye_exercise":1}},
 {"name":"本体普通射击","levels":{}}]
var spider_trial170 := false
var spider_count170 := 3
var build170 := 0
var attacker170: CharacterBody3D
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/spider_hud170.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 170 · 小蜘蛛B / 小跳与扑空小饼")
func _enemy_script() -> Script:
 return preload("res://scripts/combat/spider170.gd") if spider_trial170 else super._enemy_script()
func _ready() -> void:
 super._ready()
 while not is_instance_valid(arc_shadows167): await get_tree().physics_frame
 if "--spider170" in OS.get_cmdline_user_args(): start_spider170()
func start_spider170() -> void:
 spider_trial170=true;trial152=true;paper_trial129=false;hill_visited136=true;start_combat()
func start_combat(reposition := true) -> void:
 attacker170=null
 super.start_combat(reposition)
 if spider_trial170 and active114: total_enemies=spider_count170;announce152()
func reserve_spider170(actor: CharacterBody3D) -> bool:
 if not reserve_attack(actor): return false
 if is_instance_valid(attacker170) and not attacker170.dead and attacker170!=actor and attacker170.state170 in ["prepare","pounce"]: return false
 attacker170=actor;return true
func _spawn_wave110(index: int) -> void:
 if not spider_trial170: super._spawn_wave110(index);return
 for actor in reuse119:
  if is_instance_valid(actor): actor.queue_free()
 reuse119.clear();clear_standby119()
 for actor in enemies:
  if is_instance_valid(actor): remove_child(actor);actor.queue_free()
 _prune_actor_shadows()
 enemies.clear();retired119.clear();round_index=0;between_left=0.;_clear_combat_shots();packs114=1;created120=spider_count170;total_enemies=spider_count170
 var g: Vector2=meadow.landmarks.grove
 for i in spider_count170:
  var angle := TAU*float(i)/float(spider_count170)
  var actor := make_actor119(i,g+Vector2(cos(angle),sin(angle))*3.5)
  actor.hp=24.;actor.max_hp110=24.;actor.touch110=12.;actor.home=g
  enemies.append(actor);actor.play119()
 rebuild_cells110();target114=null;aim_tick114=-1
func _step_outing119(delta: float) -> void:
 if not spider_trial170: super._step_outing119(delta);return
 if ending119>=0.:
  ending119-=delta
  if ending119<=0.: won119=true;finish114()
func enemy_defeated(actor: CharacterBody3D) -> void:
 if not spider_trial170: super.enemy_defeated(actor);return
 if not active114 or retired119.has(actor.get_instance_id()): return
 retired119[actor.get_instance_id()]=true;defeated_count+=1
 if steering_indices113.has(actor): steering_alive113[int(steering_indices113[actor])]=0
 if target114==actor: target114=null;aim_tick114=-1
 if defeated_count>=spider_count170: ending119=.8
func apply_paper_build129() -> void:
 if not spider_trial170: super.apply_paper_build129();return
 _cancel_charge();_clear_combat_shots();buffs.levels=BUILDS170[build170].levels.duplicate();beam_left110=0.;_apply_owned_buffs();reset_metrics152();announce152()
func announce152() -> void:
 if not spider_trial170: super.announce152();return
 if is_instance_valid(encounter_hud): encounter_hud.announce("小蜘蛛B · "+BUILDS170[build170].name,"F7重开蜘蛛 · F6单只/三只 · 1—9换组合 · 预警圈锁定落点，扑空后可反击",4.)
func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed and hill_ready146 and (not is_instance_valid(memory_ui116) or not memory_ui116.visible):
  if event.physical_keycode==KEY_F7: start_spider170();get_viewport().set_input_as_handled();return
  if spider_trial170:
   if event.physical_keycode==KEY_F6:
    spider_count170=1 if spider_count170==3 else 3;start_spider170();get_viewport().set_input_as_handled();return
   if event.physical_keycode>=KEY_1 and event.physical_keycode<=KEY_9:
    build170=event.physical_keycode-KEY_1;apply_paper_build129();get_viewport().set_input_as_handled();return
   if event.physical_keycode==KEY_F9:
    build170=(build170+1)%BUILDS170.size();apply_paper_build129();get_viewport().set_input_as_handled();return
  if event.physical_keycode in [KEY_F4,KEY_F5]: spider_trial170=false
 super._input(event)
func home116() -> void:
 spider_trial170=false;super.home116()
func reward_text119() -> String:
 return "小蜘蛛动作试演，不发材料、不推进正式进度；F7再玩一场。" if spider_trial170 else super.reward_text119()
