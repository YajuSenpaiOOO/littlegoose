extends "res://scripts/world/woodland_world118.gd"
const BALANCE119=preload("res://scripts/combat/encounter119_balance.gd")
var woodland_ready119 := false
var standby119: Array[CharacterBody3D]=[]
var reuse119: Array[CharacterBody3D]=[]
var retired119 := {}
var joined119 := 0
var notice119 := -1.
var ending119 := -1.
var event119 := 0
var won119 := false
func _init() -> void:
 memory_kit116=preload("res://scripts/combat/memory_kit119.gd").new();memory_save116="user://tuantuan119.cfg"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 119 · 团团约玩 / 蓝色液滴与弹弓")
func _trial_duration114() -> float: return INF
func count_for110(_index: int) -> int: return 5
func _enemy_script() -> Script: return preload("res://scripts/combat/tuantuan119.gd")
func _trial_ui_script114() -> Script: return preload("res://scripts/combat/workshop_result119.gd")
func _memory_ui_script116() -> Script: return preload("res://scripts/combat/notebook_ui119.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/hud119.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time119.gd")
func _workshop_hint_text116() -> String: return "F 翻开笔记本 · F5 去和团团玩"
func _ready() -> void:
 super._ready()
 while not woodland_ready118: await get_tree().physics_frame
 woodland_ready119=true;ambient119();time55.update_guide();_title35();print("WOODLAND119_READY gel=",memory_kit116.gel119)
func clear_standby119() -> void:
 for actor in standby119:
  if is_instance_valid(actor): remove_child(actor);actor.queue_free()
 standby119.clear()
func make_actor119(index: int,at: Vector2) -> CharacterBody3D:
 var actor: CharacterBody3D=_enemy_script().new();actor.name="Playmate119_%d"%index
 actor.battle=self;actor.poses=combat_poses;actor.textures=combat_textures;actor.home=meadow.landmarks.grove
 actor.rank110=0;actor.body_scale110=1.;actor.max_hp110=4.;actor.hp=4.;actor.touch110=15.;actor.speed110=1.;actor.role110=index
 actor.rest=.6+index*.12;actor.attack_wait110=1.2;actor.position=Vector3(at.x,floor_height(at)+.06,at.y)
 add_child(actor);actor.reset_physics_interpolation();_add_actor_shadow(actor,actor.visual);return actor
func ambient119() -> void:
 if not woodland_ready119: return
 var occupied: Array[Vector2]=[];var g: Vector2=meadow.landmarks.grove
 for i in 3:
  var at := _pick_spawn114(g+[Vector2(-4,-2),Vector2(3.5,-3),Vector2(.7,-5.5)][i],occupied);occupied.append(at)
  enemies.append(make_actor119(i,at))
 rebuild_cells110()
func start_combat(reposition := true) -> void:
 if not woodland_ready119: return
 if won119 and memory_kit116.last_reward119<event119:
  encounter_hud.announce("液滴还没收好","先在散场页收好，再约下一场。",2.);return
 var previous: int=memory_kit116.next_event119;memory_kit116.next_event119+=1
 if memory_kit116.save_to(memory_save116)!=OK:
  memory_kit116.next_event119=previous;encounter_hud.announce("暂时没能记下这场约定","稍后再试，原进度没有改变。",2.);return
 event119=previous;won119=false;retired119.clear();joined119=0;notice119=-1.;ending119=-1.;refill114=0.
 reuse119.clear();clear_standby119()
 for actor in enemies:
  if is_instance_valid(actor) and actor.mode119=="ambient": reuse119.append(actor)
 if reuse119.size()==3: enemies.clear()
 else: reuse119.clear()
 super.start_combat(reposition)
 total_enemies=5;encounter_hud.announce("和团团玩一会儿","它们带来了喜欢收集的小东西。",2.4)
func _spawn_wave110(_index: int) -> void:
 round_index=0;between_left=0.;last_attacker=null;_clear_combat_shots();packs114=1
 var occupied: Array[Vector2]=[];var g: Vector2=meadow.landmarks.grove
 for i in 3:
  var actor: CharacterBody3D
  if reuse119.size()==3: actor=reuse119[i]
  else:
   var at := _pick_spawn114(g+[Vector2(-4,-2),Vector2(3.5,-3),Vector2(.7,-5.5)][i],occupied);actor=make_actor119(i,at)
  occupied.append(Vector2(actor.position.x,actor.position.z));enemies.append(actor);actor.play119()
 reuse119.clear()
 for i in 2:
  var at := _pick_spawn114(g+Vector2(-6. if i==0 else 6.,-4.),occupied);occupied.append(at);standby119.append(make_actor119(3+i,at))
 rebuild_cells110();next_attack33=combat_clock33+.9;target114=null;aim_tick114=-1
func enemy_defeated(enemy: CharacterBody3D) -> void:
 if not active114 or retired119.has(enemy.get_instance_id()): return
 retired119[enemy.get_instance_id()]=true
 if steering_indices113.has(enemy): steering_alive113[int(steering_indices113[enemy])]=0
 defeated_count+=1;hitstop(.035);trauma=minf(1.,trauma+.18)
 if target114==enemy: target114=null;aim_tick114=-1
 if defeated_count==5 and joined119==2: ending119=.9
func on_legacy_contact(enemy: CharacterBody3D,contact: Vector3,direction: Vector3,juice: bool) -> void:
 if not enemy.dead: super.on_legacy_contact(enemy,contact,direction,juice);return
 # Finishing the game is a soft impact, not a burst of blue body material.
 feedback_count+=1
 if is_instance_valid(feedback): feedback.marker=.13
 emit_legacy_art(contact,direction,"impact",.5)
 if not cup_contact_active: notify_hit()
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 if not woodland_ready119 or not active114 or combat_paused: return
 _step_outing119(delta)
func _step_outing119(delta: float) -> void:
 if joined119<2 and defeated_count>=1 and elapsed114>=1.4:
  if notice119<0.:
   notice119=BALANCE119.JOIN_NOTICE;encounter_hud.announce("“我们也来！”","旁边的团团正朝空地跑来。",1.8)
  else:
   notice119-=delta
   if notice119<=0.:
    var actor: CharacterBody3D=standby119.pop_front();enemies.append(actor);joined119+=1
    actor.join119(meadow.landmarks.grove+Vector2(-2. if joined119==1 else 2.,-.6));rebuild_cells110()
    notice119=BALANCE119.JOIN_INTERVAL if joined119<2 else -1.
 if ending119>=0.:
  ending119-=delta
  if ending119<=0.: won119=true;finish114()
func retry_reward119() -> bool:
 if not won119: return false
 if memory_kit116.last_reward119>=event119: return true
 var old_gel: int=memory_kit116.gel119;var old_last: int=memory_kit116.last_reward119
 if not memory_kit116.award119(event119): return false
 if memory_kit116.save_to(memory_save116)==OK: return true
 memory_kit116.gel119=old_gel;memory_kit116.last_reward119=old_last;return false
func reward_text119() -> String:
 if not won119: return "随时可以回来再约一场。"
 return "团团分享了蓝色弹性液滴 ×%d"%BALANCE119.GEL_REWARD if memory_kit116.last_reward119>=event119 else "液滴暂未保存，请点下方按钮重试。"
func finish114() -> void:
 if not active114: return
 if won119: retry_reward119()
 super.finish114()
func _leave_encounter() -> void:
 clear_standby119();reuse119.clear();super._leave_encounter()
func home116() -> void:
 if woodland_ready119 and won119 and memory_kit116.last_reward119<event119:
  encounter_hud.announce("液滴还没收好","先在散场页重试保存。",2.);return
 super.home116()
 if woodland_ready119: ambient119()
func close_memory116(commit: bool,trial := false) -> bool:
 var previous: int=memory_kit116.gel119
 if commit and is_instance_valid(memory_ui116) and memory_ui116.visible:
  if memory_ui116.working_gel119<0 or memory_ui116.working_gel119>previous:
   memory_ui116.feedback.text="液滴数量不对，再检查一下笔记本。";return false
  memory_kit116.gel119=memory_ui116.working_gel119
 var result := super.close_memory116(commit,trial)
 if not result: memory_kit116.gel119=previous
 return result
