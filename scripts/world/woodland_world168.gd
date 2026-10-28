extends "res://scripts/world/woodland_world167.gd"
const COPY_DAMAGE168 := .40
const BUILDS168=[
 {"name":"双鹅开火车 · 额外1只／1格","levels":{"forest_fireboy":1,"homework":1}},
 {"name":"三鹅开火车 · 额外2只／2格","levels":{"three_player":1,"homework":1}},
 {"name":"住校团聚 · 额外3只／3格","levels":{"boarding_school":1,"homework":1}},
 {"name":"弹弓双鹅火车","levels":{"forest_fireboy":1,"slingshot":1,"homework":1}},
 {"name":"飞机三鹅火车","levels":{"three_player":1,"paper_plane":1,"homework":1}},
 {"name":"气球剑三鹅火车","levels":{"three_player":1,"balloon_sword":1,"homework":1}},
 {"name":"四鹅火车 · 与住校同数量对照","levels":{"forest_fireboy":1,"three_player":1,"homework":1}},
 {"name":"水柱双鹅火车","levels":{"forest_fireboy":1,"flashlight":1,"homework":1}},
 {"name":"小黑鹅本体对照","levels":{"homework":1}}]
var build168 := 0
var capturing168 := false
var sources168: Array[int]=[]
func _init() -> void:
 buffs=preload("res://scripts/combat/buff_book168.gd").new();buffs.rng110.randomize()
 memory_kit116=preload("res://scripts/combat/memory_kit168.gd").new();memory_save116="user://goose_train168.cfg"
func _skills_script110() -> Script: return preload("res://scripts/combat/battle_skills168.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/goose_hud168.gd")
func _memory_ui_script116() -> Script: return preload("res://scripts/combat/notebook_ui168.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 168 · 鹅队开火车 / 住校团聚 / 复制伤害40%")
func _ready() -> void:
 super._ready()
 while not is_instance_valid(arc_shadows167): await get_tree().physics_frame
 if "--geese168" in OS.get_cmdline_user_args(): trial152=true;paper_trial129=false;start_combat()
func _projectile_record110(node: Variant,velocity: Vector3) -> Dictionary:
 var shot := super._projectile_record110(node,velocity)
 var source := 0
 if is_instance_valid(emitter110) and emitter110!=goose: source=skills110.geese110.find(emitter110)+1
 shot.goose_source168=source;shot.goose_gain168=COPY_DAMAGE168 if source>0 else 1.
 if capturing168: sources168.append(source)
 return shot
func damage_for_shot(shot: Dictionary) -> float:
 buffs.math_scope168+=1;var damage := super.damage_for_shot(shot);buffs.math_scope168-=1
 var weight: float=shot.get("goose_gain168",1.)
 if shot.get("stream110",false): weight=COPY_DAMAGE168 if int(shot.get("stream_lane110",0))/3>0 else 1.
 return damage*(1. if shot.has("fixed_damage110") else weight)
func attack_cooldown() -> float:
 buffs.math_scope168+=1;var interval := super.attack_cooldown();buffs.math_scope168-=1;return interval
func emit_stream110(target: Vector3) -> void:
 var before := shots.size();var captured := sources168.size()
 super.emit_stream110(target)
 for i in range(before,shots.size()):
  var source: int=int(shots[i].get("stream_lane110",0))/3
  shots[i].goose_source168=source;shots[i].goose_gain168=COPY_DAMAGE168 if source>0 else 1.
  if capturing168 and captured+i-before<sources168.size(): sources168[captured+i-before]=source
func snapshot_packet146(target: Vector3,charged: bool,ratio: float,retire_all := false,carrier := true) -> Dictionary:
 var previous := capturing168;var saved := sources168.duplicate()
 capturing168=true;sources168.clear();buffs.math_scope168+=1
 var packet := super.snapshot_packet146(target,charged,ratio,retire_all,carrier)
 buffs.math_scope168-=1
 if not packet.is_empty():
  for i in packet.specs.size():
   packet.specs[i].goose_source168=(i/(1+buffs.level("distract"))) if packet.stream else (sources168[i] if i<sources168.size() else 0)
 capturing168=previous;sources168.assign(saved);return packet
func emit_packet146(packet: Dictionary,origin: Vector3,target: Vector3,gain: float,generation := -1) -> void:
 var before := shots.size();super.emit_packet146(packet,origin,target,gain,generation)
 for i in range(before,shots.size()):
  var spec: Dictionary=packet.specs[mini(i-before,packet.specs.size()-1)]
  shots[i].goose_source168=spec.get("goose_source168",0)
func _apply_shot_hit(shot: Dictionary,hit: Dictionary) -> void:
 var before := pending_splits110.size();super._apply_shot_hit(shot,hit)
 for i in range(before,pending_splits110.size()): pending_splits110[i].goose_source168=shot.get("goose_source168",0)
func inherit_split153(shot: Dictionary,split: Dictionary) -> void:
 super.inherit_split153(shot,split);shot.goose_source168=split.get("goose_source168",0)
func cup_contact_enemy(enemy: CharacterBody3D,direction: Vector3) -> void:
 if not is_instance_valid(contact_emitter110) or contact_emitter110==goose: super.cup_contact_enemy(enemy,direction);return
 if combat_paused or wave_state!="fighting" or player_hp<=0. or enemy.dead: return
 cup_contact_active=true;cup_contact_hits+=1;enemy.impact_contact=contact_emitter110.muzzle()
 enemy.receive_hit(.5*projectile_damage()*COPY_DAMAGE168,direction);cup_contact_active=false
func apply_paper_build129() -> void:
 _cancel_charge();_clear_combat_shots();paper_build129=0;paper_build146=0;build152=0;build153=0;build160=0;build161=0;build166=0
 buffs.levels=BUILDS168[build168].levels.duplicate();beam_left110=0.;_apply_owned_buffs();reset_metrics152();announce152()
func announce152() -> void:
 if is_instance_valid(encounter_hud): encounter_hud.announce(BUILDS168[build168].name,"本体无惩罚 · 每只额外鹅40%伤害 · 3住校团聚／7同数量火车对照",3.)
func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed and hill_ready146 and (not is_instance_valid(memory_ui116) or not memory_ui116.visible):
  if active114 and (trial152 or paper_trial129):
   if event.physical_keycode>=KEY_1 and event.physical_keycode<=KEY_9:
    build168=event.physical_keycode-KEY_1;apply_paper_build129();get_viewport().set_input_as_handled();return
   if event.physical_keycode==KEY_F9:
    build168=(build168+1)%BUILDS168.size();apply_paper_build129();get_viewport().set_input_as_handled();return
 super._input(event)
func _clear_combat_shots() -> void:
 super._clear_combat_shots()
 if is_instance_valid(skills110): skills110.reset_path168()
