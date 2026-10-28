extends "res://scripts/world/woodland_world128.gd"
const PAPER_TOTAL129 := 6
const PAPER_BUILDS129 := ["普通射击","蓄力弹弓","小零食分裂","眼保健操追踪"]
var paper_trial129 := false
var paper_build129 := 0
var paper_session129 := false
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 129 · F4纸怪独立试演 / F5团团")
func _enemy_script() -> Script: return preload("res://scripts/combat/paper129.gd") if paper_trial129 else preload("res://scripts/combat/tuantuan128.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/paper_hud129.gd")
func _workshop_hint_text116() -> String: return "F 翻开笔记本 · F4 作业纸试演 · F5 团团固定点"
func _ready() -> void:
 super._ready()
 while not is_instance_valid(drops120): await get_tree().physics_frame
 if "--paper129" in OS.get_cmdline_user_args(): paper_trial129=true;start_combat()
func _unhandled_input(event: InputEvent) -> void:
 if is_instance_valid(memory_ui116) and memory_ui116.visible: super._unhandled_input(event);return
 if event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed:
  if event.physical_keycode==KEY_F4:
   paper_trial129=true;start_combat();return
  if event.physical_keycode==KEY_F5:
   paper_trial129=false;_apply_owned_buffs();start_combat();return
  if paper_trial129 and event.physical_keycode in [KEY_1,KEY_2,KEY_3,KEY_4]:
   paper_build129=event.physical_keycode-KEY_1;apply_paper_build129();return
 super._unhandled_input(event)
func apply_paper_build129() -> void:
 _cancel_charge();_clear_combat_shots();buffs.levels.clear()
 if paper_build129>0: buffs.levels[["","slingshot","snack","eye_exercise"][paper_build129]]=1
 _apply_owned_buffs()
 encounter_hud.announce(PAPER_BUILDS129[paper_build129],"临时试演配装，不消耗材料；F4重新试演。",1.5)
func start_combat(reposition := true) -> void:
 if not paper_trial129:
  if paper_session129: won119=false;paper_session129=false
  super.start_combat(reposition);return
 paper_session129=true
 # Practice uses a disposable event save, never the material/recipe save.
 var path := memory_save116;var next: int=memory_kit116.next_event119
 var practice := "user://paper129_practice_%d.cfg"%get_instance_id()
 memory_save116=practice;won119=false
 super.start_combat(reposition)
 memory_save116=path;memory_kit116.next_event119=next
 DirAccess.remove_absolute(ProjectSettings.globalize_path(practice))
 total_enemies=PAPER_TOTAL129;apply_paper_build129()
 encounter_hud.announce("作业纸 · 独立试演","飘动后落稳，再抖一下扑来；1—4免费切换打法。",3.)
func make_actor119(index: int,at: Vector2) -> CharacterBody3D:
 var actor := super.make_actor119(index,at)
 if paper_trial129: actor.hp=5.;actor.max_hp110=5.;actor.touch110=10.
 return actor
func _spawn_wave110(index: int) -> void:
 if not paper_trial129: super._spawn_wave110(index);return
 for actor in reuse119:
  if is_instance_valid(actor): actor.queue_free()
 reuse119.clear();clear_standby119()
 for actor in enemies:
  if is_instance_valid(actor): remove_child(actor);actor.queue_free()
 enemies.clear();round_index=0;between_left=0.;_clear_combat_shots();packs114=1;created120=PAPER_TOTAL129
 var occupied: Array[Vector2]=[]
 for i in PAPER_TOTAL129:
  var angle := TAU*float(i)/PAPER_TOTAL129
  var at := _pick_spawn114(meadow.landmarks.grove+Vector2(cos(angle),sin(angle))*5.5,occupied);occupied.append(at)
  var actor := make_actor119(i,at);enemies.append(actor);actor.play119()
 rebuild_cells110();target114=null;aim_tick114=-1
func _step_outing119(delta: float) -> void:
 if not paper_trial129: super._step_outing119(delta);return
 if ending119>=0.:
  ending119-=delta
  if ending119<=0.: won119=true;finish114()
func enemy_defeated(actor: CharacterBody3D) -> void:
 if not paper_trial129: super.enemy_defeated(actor);return
 if not active114 or retired119.has(actor.get_instance_id()): return
 retired119[actor.get_instance_id()]=true;defeated_count+=1
 if steering_indices113.has(actor): steering_alive113[int(steering_indices113[actor])]=0
 if target114==actor: target114=null;aim_tick114=-1
 if defeated_count>=PAPER_TOTAL129: ending119=.6
func defeat_drop120(actor: CharacterBody3D) -> void:
 if not paper_trial129: super.defeat_drop120(actor)
func on_legacy_contact(actor: CharacterBody3D,at: Vector3,direction: Vector3,juice: bool) -> void:
 super.on_legacy_contact(actor,at,direction,false if paper_trial129 else juice)
func retry_reward119() -> bool:
 return true if paper_trial129 else super.retry_reward119()
func finish114() -> void:
 super.finish114()
 if paper_trial129: clear_roam122()
func home116() -> void:
 paper_trial129=false;super.home116()
func _leave_encounter() -> void:
 paper_trial129=false;super._leave_encounter()



