extends "res://scripts/world/woodland_world160.gd"
const BUILDS161=[
 {"name":"主角·普通射击","levels":{"hero_moment":1}},
 {"name":"主角·纸飞机","levels":{"hero_moment":1,"paper_plane":1}},
 {"name":"主角·气球剑雨","levels":{"hero_moment":1,"paper_plane":1,"balloon_sword":1}},
 {"name":"主角·弹弓枕头窝","levels":{"hero_moment":1,"slingshot":1,"pillow_hut":1}},
 {"name":"主角·剑雨枕头窝","levels":{"hero_moment":1,"paper_plane":1,"balloon_sword":1,"pillow_hut":1}},
 {"name":"课堂笔记·普通射击对照","levels":{"homework":1}},
 {"name":"课堂笔记·飞机对照","levels":{"homework":1,"paper_plane":1}},
 {"name":"课堂笔记·剑雨对照","levels":{"homework":1,"paper_plane":1,"balloon_sword":1}},
 {"name":"主角·分裂","levels":{"hero_moment":1,"snack":1}}]
var build161 := 0
var moment161: Node
func _init() -> void:
 buffs=preload("res://scripts/combat/buff_book161.gd").new();buffs.rng110.randomize()
 memory_kit116=preload("res://scripts/combat/memory_kit161.gd").new();memory_save116="user://hero_moment161.cfg"
func _memory_ui_script116() -> Script: return preload("res://scripts/combat/notebook_ui161.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/hero_hud161.gd")
func _paper_manager_script146() -> Script: return preload("res://scripts/combat/paper_float162.gd")
func _moment_manager161() -> Script: return preload("res://scripts/combat/hero_moment161.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 161 · 主角时刻 / 惯性悬浮跟随")
func _ready() -> void:
 super._ready()
 while not is_instance_valid(pillow160): await get_tree().physics_frame
 moment161=_moment_manager161().new();moment161.battle=self;add_child(moment161)
 if "--hero161" in OS.get_cmdline_user_args(): trial152=true;paper_trial129=false;start_combat()
func _projectile_record110(node: Variant,velocity: Vector3) -> Dictionary:
 var shot := super._projectile_record110(node,velocity)
 shot.moment_gain161=1.3 if is_instance_valid(moment161) and moment161.running161() else 1.
 return shot
func damage_for_shot(shot: Dictionary) -> float:
 # Fixed packet/split damage already contains the launch-time bonus.
 return super.damage_for_shot(shot)*(1. if shot.has("fixed_damage110") else float(shot.get("moment_gain161",1.)))
func apply_paper_build129() -> void:
 _cancel_charge();_clear_combat_shots();paper_build129=0;paper_build146=0;build152=0;build153=0;build160=0
 buffs.levels=BUILDS161[build161].levels.duplicate();beam_left110=0.;_apply_owned_buffs();reset_metrics152();announce152()
func announce152() -> void:
 var tip := "Q主角时刻 · 伤害+30% 射速+40% · 7秒舞台／结束后20秒冷却" if buffs.level("hero_moment")>0 else "Q翻阅课堂笔记 · 未装备主角时刻 · 1—5／9切回新主动"
 if is_instance_valid(encounter_hud): encounter_hud.announce(BUILDS161[build161].name,tip,3.)
func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed and hill_ready146 and (not is_instance_valid(memory_ui116) or not memory_ui116.visible):
  if event.physical_keycode==KEY_Q and buffs.level("hero_moment")>0:
   if is_instance_valid(moment161): moment161.request161()
   get_viewport().set_input_as_handled();return
  if active114 and (trial152 or paper_trial129):
   if event.physical_keycode>=KEY_1 and event.physical_keycode<=KEY_9:
    build161=event.physical_keycode-KEY_1;apply_paper_build129();get_viewport().set_input_as_handled();return
   if event.physical_keycode==KEY_F9:
    build161=(build161+1)%BUILDS161.size();apply_paper_build129();get_viewport().set_input_as_handled();return
 super._input(event)
func _physics_process(delta: float) -> void:
 if is_instance_valid(moment161): moment161.step161(delta)
 super._physics_process(delta)
func _clear_combat_shots() -> void:
 super._clear_combat_shots()
 if is_instance_valid(moment161): moment161.reset161()
