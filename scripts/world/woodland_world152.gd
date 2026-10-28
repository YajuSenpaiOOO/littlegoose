extends "res://scripts/world/woodland_world151.gd"
const BUILDS152=[
 {"name":"普通飞机＋笔记","levels":{"paper_plane":1,"homework":1}},
 {"name":"蓄力飞机＋笔记","levels":{"paper_plane":1,"homework":1,"slingshot":1}},
 {"name":"分裂飞机＋笔记","levels":{"paper_plane":1,"homework":1,"snack":1}},
 {"name":"射速飞机＋笔记","levels":{"paper_plane":1,"homework":1,"eye_exercise":1}},
 {"name":"水柱飞机＋笔记","levels":{"paper_plane":1,"homework":1,"flashlight":1}},
 {"name":"直接弹弓＋笔记","levels":{"homework":1,"slingshot":1}},
 {"name":"普通直射＋笔记","levels":{"homework":1}},
 {"name":"分裂直射＋笔记","levels":{"homework":1,"snack":1}},
 {"name":"水柱直射＋笔记","levels":{"homework":1,"flashlight":1}}]
var scatter152 := false
var trial152 := false
var build152 := 0
var damage152 := 0.
var hits152 := 0
var kills152 := 0
func _paper_manager_script146() -> Script: return preload("res://scripts/combat/paper_scatter152.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/paper_hud152.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 152 · 随机九发 / 辅助六发 / 双敌人对照")
func _ready() -> void:
 super._ready()
 while not hill_ready146: await get_tree().physics_frame
 if "--scatter152" in OS.get_cmdline_user_args(): trial152=true;paper_trial129=true;start_combat()
func reset_metrics152() -> void: damage152=0.;hits152=0;kills152=0
func apply_paper_build129() -> void:
 _cancel_charge();_clear_combat_shots();paper_build129=0;paper_build146=0;buffs.levels=BUILDS152[build152].levels.duplicate();beam_left110=0.;_apply_owned_buffs();reset_metrics152()
 if is_instance_valid(encounter_hud): encounter_hud.announce(BUILDS152[build152].name,"F8切换随机/辅助 · F4纸怪 · F5团团 · 7直射 8直分 9直水",2.)
func start_combat(reposition := true) -> void:
 if not trial152: super.start_combat(reposition);return
 var saved := memory_save116;var next: int=memory_kit116.next_event119
 var practice := "user://scatter152_practice_%d.cfg"%get_instance_id()
 memory_save116=practice;won119=false
 super.start_combat(reposition)
 memory_save116=saved;memory_kit116.next_event119=next
 DirAccess.remove_absolute(ProjectSettings.globalize_path(practice))
 if active114: apply_paper_build129();announce152()
func announce152() -> void:
 encounter_hud.announce(("作业纸" if paper_trial129 else "团团怪")+" · "+("随机九发齐射" if scatter152 else "辅助六连投"),"F8切换模式 · F4重开纸怪 · F5重开团团 · 1—9组合 · Q笔记",3.)
func toggle152() -> void:
 _cancel_charge();_clear_combat_shots();scatter152=not scatter152;cooldown=0.;fire_needs_release=true;reset_metrics152();announce152()
func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed and hill_ready146 and (not is_instance_valid(memory_ui116) or not memory_ui116.visible):
  if event.physical_keycode in [KEY_F4,KEY_F5]:
   trial152=true;paper_trial129=event.physical_keycode==KEY_F4;start_combat();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_F8:
   toggle152();get_viewport().set_input_as_handled();return
  if active114 and (trial152 or paper_trial129):
   if event.physical_keycode>=KEY_1 and event.physical_keycode<=KEY_9:
    build152=event.physical_keycode-KEY_1;apply_paper_build129();get_viewport().set_input_as_handled();return
   if event.physical_keycode==KEY_F9:
    build152=(build152+1)%BUILDS152.size();apply_paper_build129();get_viewport().set_input_as_handled();return
 super._input(event)
func _step_shots(delta: float) -> void:
 # The native helper reads tracking globally. Modes clear existing shots, so a
 # scoped zero disables bending for the whole random salvo without losing rate.
 if not scatter152 or buffs.level("paper_plane")==0: super._step_shots(delta);return
 var saved: int=buffs.level("eye_exercise");buffs.levels["eye_exercise"]=0
 super._step_shots(delta)
 if saved>0: buffs.levels["eye_exercise"]=saved
 else: buffs.levels.erase("eye_exercise")
func _apply_shot_hit(shot: Dictionary,hit: Dictionary) -> void:
 var enemy: Variant=hit.collider.get_meta("enemy") if hit.collider.has_meta("enemy") else null
 var before: float=enemy.hp if is_instance_valid(enemy) and not enemy.dead else 0.
 super._apply_shot_hit(shot,hit)
 if before>0. and is_instance_valid(enemy):
  var dealt := maxf(0.,before-maxf(0.,float(enemy.hp)))
  if dealt>0.: damage152+=dealt;hits152+=1
  if enemy.dead: kills152+=1
func defeat_drop120(actor: CharacterBody3D) -> void:
 if not trial152: super.defeat_drop120(actor)
func retry_reward119() -> bool: return true if trial152 else super.retry_reward119()
func reward_text119() -> String: return "双敌人对照试演，不结算材料；F4纸怪，F5团团。" if trial152 else super.reward_text119()
func home116() -> void:
 if trial152: won119=false
 super.home116();trial152=false
