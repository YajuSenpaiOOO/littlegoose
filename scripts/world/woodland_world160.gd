extends "res://scripts/world/woodland_world159.gd"
const BUILDS160=[
 {"name":"枕头窝＋弹弓＋笔记","levels":{"pillow_hut":1,"slingshot":1,"homework":1}},
 {"name":"枕头窝＋飞机＋笔记","levels":{"pillow_hut":1,"paper_plane":1,"homework":1}},
 {"name":"枕头窝＋剑雨＋笔记","levels":{"pillow_hut":1,"paper_plane":1,"balloon_sword":1,"homework":1}},
 {"name":"枕头窝＋分裂＋笔记","levels":{"pillow_hut":1,"snack":1,"homework":1}},
 {"name":"枕头窝＋快剑＋笔记","levels":{"pillow_hut":1,"balloon_sword":1,"eye_exercise":1,"homework":1}},
 {"name":"弹弓对照","levels":{"slingshot":1,"homework":1}},
 {"name":"飞机对照","levels":{"paper_plane":1,"homework":1}},
 {"name":"剑雨对照","levels":{"balloon_sword":1,"paper_plane":1,"homework":1}},
 {"name":"枕头窝＋普通射击","levels":{"pillow_hut":1,"homework":1}}]
var build160 := 0
var pillow160: Node3D
func _init() -> void:
 buffs=preload("res://scripts/combat/buff_book160.gd").new();buffs.rng110.randomize()
 memory_kit116=preload("res://scripts/combat/memory_kit160.gd").new();memory_save116="user://pillow_hut160.cfg"
func _memory_ui_script116() -> Script: return preload("res://scripts/combat/notebook_ui160.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/pillow_hud160.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 160 · 三秒小窝 / 可返回 / 冷却10秒")
func _ready() -> void:
 super._ready()
 while not is_instance_valid(swords153): await get_tree().physics_frame
 pillow160=preload("res://scripts/combat/pillow_hut160.gd").new();pillow160.battle=self;combat_effect_root159().add_child(pillow160)
 if "--pillow160" in OS.get_cmdline_user_args(): trial152=true;paper_trial129=false;start_combat()
func apply_paper_build129() -> void:
 _cancel_charge();_clear_combat_shots();paper_build129=0;paper_build146=0;build152=0;build153=0
 buffs.levels=BUILDS160[build160].levels.duplicate();beam_left110=0.;_apply_owned_buffs();reset_metrics152()
 if is_instance_valid(encounter_hud): encounter_hud.announce(BUILDS160[build160].name,"蹲防搭窝 · 3秒内可离开再返回 · 消失后10秒冷却",3.)
func announce152() -> void:
 encounter_hud.announce(("作业纸" if paper_trial129 else "团团怪")+" · "+BUILDS160[build160].name,"1—5小屋组合 · 6—8无小屋对照 · 9普通窝 · F4纸怪 F5团团",3.)
func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed and hill_ready146 and (not is_instance_valid(memory_ui116) or not memory_ui116.visible):
  if active114 and (trial152 or paper_trial129):
   if event.physical_keycode>=KEY_1 and event.physical_keycode<=KEY_9:
    build160=event.physical_keycode-KEY_1;apply_paper_build129();get_viewport().set_input_as_handled();return
   if event.physical_keycode==KEY_F9:
    build160=(build160+1)%BUILDS160.size();apply_paper_build129();get_viewport().set_input_as_handled();return
 super._input(event)
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 if is_instance_valid(pillow160): pillow160.step160(delta)
func hurt_player(damage: float,from: Vector2) -> void:
 var blocked := 0.
 if is_instance_valid(pillow160) and player_hp>0. and invulnerability<=0. and not combat_paused and wave_state=="fighting" and hero.dodge_invulnerability<=0.:
  blocked=pillow160.absorb160(damage)
 if blocked>0.:
  encounter_hud.respond("小窝挡住了！",Color("d9e7c7"))
  return
 super.hurt_player(damage,from)
func _clear_combat_shots() -> void:
 super._clear_combat_shots()
 if is_instance_valid(pillow160): pillow160.reset160()
