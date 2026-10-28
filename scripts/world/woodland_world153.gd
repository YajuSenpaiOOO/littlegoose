extends "res://scripts/world/woodland_world152.gd"
const BUILDS153=[
 {"name":"气球剑","levels":{"balloon_sword":1,"homework":1}},
 {"name":"气球剑雨","levels":{"balloon_sword":1,"paper_plane":1,"homework":1}},
 {"name":"射速气球剑","levels":{"balloon_sword":1,"eye_exercise":1,"homework":1}},
 {"name":"射速剑雨","levels":{"balloon_sword":1,"paper_plane":1,"eye_exercise":1,"homework":1}},
 {"name":"分裂气球剑","levels":{"balloon_sword":1,"snack":1,"homework":1}},
 {"name":"分裂剑雨","levels":{"balloon_sword":1,"paper_plane":1,"snack":1}},
 {"name":"蓄力气球剑","levels":{"balloon_sword":1,"slingshot":1,"homework":1}},
 {"name":"普通直射对照","levels":{"homework":1}},
 {"name":"普通飞机对照","levels":{"paper_plane":1,"homework":1}}]
var swords153: Node3D
var build153 := 0
var shot_serial153 := 0
func _init() -> void:
 buffs=preload("res://scripts/combat/buff_book153.gd").new();buffs.rng110.randomize()
 memory_kit116=preload("res://scripts/combat/memory_kit153.gd").new();memory_save116="user://balloon_sword153.cfg"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 153 · 弹性气球剑 / 黏附减速 / 飞机剑雨")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/paper_hud153.gd")
func _memory_ui_script116() -> Script: return preload("res://scripts/combat/notebook_ui153.gd")
func _sword_manager153() -> Script: return preload("res://scripts/combat/balloon_sword153.gd")
func _ready() -> void:
 super._ready()
 while not hill_ready146: await get_tree().physics_frame
 swords153=_sword_manager153().new();swords153.battle=self
 var effect_root153: Node=call("combat_effect_root159") if has_method("combat_effect_root159") else self
 effect_root153.add_child(swords153)
 if "--sword153" in OS.get_cmdline_user_args(): trial152=true;paper_trial129=false;start_combat()
func apply_paper_build129() -> void:
 _cancel_charge();_clear_combat_shots();paper_build129=0;paper_build146=0;build152=0
 buffs.levels=BUILDS153[build153].levels.duplicate();beam_left110=0.;_apply_owned_buffs();reset_metrics152()
 if is_instance_valid(encounter_hud): encounter_hud.announce(BUILDS153[build153].name,"每剑减速8% · 最多5层 · 每层3秒 · F4纸怪 / F5团团",2.)
func announce152() -> void:
 encounter_hud.announce(("作业纸" if paper_trial129 else "团团怪")+" · "+BUILDS153[build153].name,"1直剑 2剑雨 3快剑 4快剑雨 5分剑 6分剑雨 7蓄剑 8直射 9飞机 · Q笔记",3.)
func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed and hill_ready146 and (not is_instance_valid(memory_ui116) or not memory_ui116.visible):
  if active114 and (trial152 or paper_trial129):
   if event.physical_keycode>=KEY_1 and event.physical_keycode<=KEY_9:
    build153=event.physical_keycode-KEY_1;apply_paper_build129();get_viewport().set_input_as_handled();return
   if event.physical_keycode==KEY_F9:
    build153=(build153+1)%BUILDS153.size();apply_paper_build129();get_viewport().set_input_as_handled();return
 super._input(event)
func tag_sword153(shot: Dictionary,sword: bool,budget := false) -> void:
 shot.sword153=sword;shot.sword_budget153=budget
 if sword:
  shot_serial153+=1;shot.serial153=shot_serial153
  shot.sword_gain153=1.25 if shot.get("charged",false) else 1.
 if shot.has("art"): shot.art.modulate.a=0. if sword else 1.
func data_shot110(origin: Vector3,velocity: Vector3,life: float) -> Dictionary:
 var shot := super.data_shot110(origin,velocity,life)
 tag_sword153(shot,buffs.level("balloon_sword")>0 and buffs.level("flashlight")==0)
 return shot
func _tag_shot110(shot: Dictionary) -> void:
 super._tag_shot110(shot)
 tag_sword153(shot,buffs.level("balloon_sword")>0 and buffs.level("flashlight")==0)
func damage_for_shot(shot: Dictionary) -> float:
 return super.damage_for_shot(shot)*(.75 if shot.get("sword153",false) and not shot.get("sword_budget153",false) else 1.)
func snapshot_packet146(target: Vector3,charged: bool,ratio: float,retire_all := false,carrier := true) -> Dictionary:
 var packet := super.snapshot_packet146(target,charged,ratio,retire_all,carrier)
 if not packet.is_empty():
  for spec in packet.specs: spec.sword153=buffs.level("balloon_sword")>0 and not packet.stream
  if buffs.level("balloon_sword")>0: packet.label=str(packet.label).replace("普通","气球剑")
 return packet
func emit_packet146(packet: Dictionary,origin: Vector3,target: Vector3,gain: float,generation := -1) -> void:
 # The inherited 150 emitter calls down through 146 once per spec.
 var before := shots.size();super.emit_packet146(packet,origin,target,gain,generation)
 for i in range(before,shots.size()):
  var spec: Dictionary=packet.specs[mini(i-before,packet.specs.size()-1)]
  tag_sword153(shots[i],spec.get("sword153",false),true)
func _apply_shot_hit(shot: Dictionary,hit: Dictionary) -> void:
 var sword: bool=shot.get("sword153",false)
 var enemy: Variant=hit.collider.get_meta("enemy") if hit.collider.has_meta("enemy") else null
 var before := pending_splits110.size()
 var direction: Vector3=shot.velocity.normalized();var gain: float=shot.get("sword_gain153",1.)
 super._apply_shot_hit(shot,hit)
 if pending_splits110.size()>before: pending_splits110[-1].sword153=sword
 if sword and is_instance_valid(swords153) and (not is_instance_valid(enemy) or not enemy.dead):
  swords153.attach153(enemy,hit.position,direction,gain,hit)
func inherit_split153(shot: Dictionary,split: Dictionary) -> void:
 tag_sword153(shot,split.get("sword153",false),true)
func _trace_shot(shot: Dictionary,start: Vector3,end: Vector3) -> Dictionary:
 if not shot.get("sword153",false): return super._trace_shot(shot,start,end)
 # Sticky swords stop at the first surface even when carrying a charged payload.
 # Keep the charge flags intact for damage and hit feedback.
 var query := PhysicsRayQueryParameters3D.create(start,end,1|2|8,[hero.get_rid()])
 query.collide_with_areas=true;query.hit_from_inside=true
 var excluded: Array[RID]=[hero.get_rid()]
 for rid in shot.ignore_rids110: excluded.append(rid)
 query.exclude=excluded
 if shot.get("spawn_grace111",0.)>0.: query.collision_mask=1|2
 return get_world_3d().direct_space_state.intersect_ray(query)
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 if is_instance_valid(swords153): swords153.step153(delta)
func _clear_combat_shots() -> void:
 super._clear_combat_shots()
 if is_instance_valid(swords153): swords153.reset153()
