extends "res://scripts/world/woodland_world168.gd"
const BUILDS169=[
 {"name":"双鹅各自放飞＋笔记","levels":{"forest_fireboy":1,"paper_plane":1,"homework":1}},
 {"name":"三鹅各自放飞＋笔记","levels":{"three_player":1,"paper_plane":1,"homework":1}},
 {"name":"住校四鹅机队","levels":{"boarding_school":1,"paper_plane":1}},
 {"name":"蓄力双鹅机队","levels":{"forest_fireboy":1,"paper_plane":1,"slingshot":1}},
 {"name":"气球剑三鹅机队","levels":{"three_player":1,"paper_plane":1,"balloon_sword":1}},
 {"name":"短抛糖屑双鹅机队","levels":{"forest_fireboy":1,"paper_plane":1,"snack":1}},
 {"name":"火车四鹅机队","levels":{"forest_fireboy":1,"three_player":1,"paper_plane":1}},
 {"name":"快射双鹅机队＋笔记","levels":{"forest_fireboy":1,"paper_plane":1,"eye_exercise":1,"homework":1}},
 {"name":"本体单机对照＋笔记","levels":{"paper_plane":1,"homework":1}}]
var build169 := 0
func _paper_manager_script146() -> Script: return preload("res://scripts/combat/paper_squad169.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/squad_hud169.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 169 · 每鹅各自放飞 / 本体100% 复制40%")
func _ready() -> void:
 super._ready()
 while not is_instance_valid(arc_shadows167): await get_tree().physics_frame
 if "--squad169" in OS.get_cmdline_user_args(): trial152=true;paper_trial129=false;start_combat()
func snapshot_packet146(target: Vector3,charged: bool,ratio: float,retire_all := false,carrier := true) -> Dictionary:
 var main_origin := projectile_origin();var origins: Array[Vector3]=skills110.origins110()
 var packet := super.snapshot_packet146(target,charged,ratio,retire_all,carrier)
 if not packet.is_empty() and packet.plane:
  var intervals := {};var angles := {};var rates := {}
  var main_direction := Vector2(target.x-main_origin.x,target.z-main_origin.z)
  for spec in packet.specs:
   var source := int(spec.get("goose_source168",0));intervals[source]=attack_cooldown()
   rates[source]=buffs.rate()
   var from: Vector3=origins[source] if source<origins.size() else main_origin
   angles[source]=main_direction.angle_to(Vector2(target.x-from.x,target.z-from.z))
  packet.source_intervals169=intervals;packet.source_angles169=angles;packet.source_rates169=rates
 return packet
func apply_paper_build129() -> void:
 _cancel_charge();_clear_combat_shots();paper_build129=0;paper_build146=0;build152=0;build153=0;build160=0;build161=0;build166=0;build168=0
 buffs.levels=BUILDS169[build169].levels.duplicate();beam_left110=0.;_apply_owned_buffs();reset_metrics152();announce152()
func announce152() -> void:
 if is_instance_valid(encounter_hud): encounter_hud.announce(BUILDS169[build169].name,"每只鹅从自己的位置放飞 · 各携自己的弹幕 · 本体100%／额外鹅40%，射速正常继承",3.)
func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed and hill_ready146 and (not is_instance_valid(memory_ui116) or not memory_ui116.visible):
  if active114 and (trial152 or paper_trial129):
   if event.physical_keycode>=KEY_1 and event.physical_keycode<=KEY_9:
    build169=event.physical_keycode-KEY_1;apply_paper_build129();get_viewport().set_input_as_handled();return
   if event.physical_keycode==KEY_F9:
    build169=(build169+1)%BUILDS169.size();apply_paper_build129();get_viewport().set_input_as_handled();return
 super._input(event)
