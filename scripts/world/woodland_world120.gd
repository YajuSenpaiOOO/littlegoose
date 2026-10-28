extends "res://scripts/world/woodland_world119.gd"
const BALANCE120=preload("res://scripts/combat/outing120_balance.gd")
var drops120: Node3D
var rng120 := RandomNumberGenerator.new()
var dropped120 := {}
var created120 := 0
var next_join120 := 6.
var group_left120 := 0
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 120 · 林间聚会 / 弹跳收藏品")
func _enemy_script() -> Script: return preload("res://scripts/combat/tuantuan120.gd")
func _trial_ui_script114() -> Script: return preload("res://scripts/combat/workshop_result120.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time120.gd")
func make_actor119(index: int,at: Vector2) -> CharacterBody3D:
 var actor := super.make_actor119(index,at);actor.max_hp110=BALANCE120.ACTOR_HP;actor.hp=actor.max_hp110;return actor
func count_for110(_index: int) -> int: return BALANCE120.TOTAL
func _ready() -> void:
 super._ready()
 while not woodland_ready119: await get_tree().physics_frame
 drops120=preload("res://scripts/combat/droplets120.gd").new();drops120.world=self;add_child(drops120);rng120.randomize();_title35();print("WOODLAND120_READY")
func start_combat(reposition := true) -> void:
 if not is_instance_valid(drops120): return
 if won119 and memory_kit116.last_reward119<event119: return
 # Picked materials are already saved; starting a new outing clears only loose objects.
 drops120.clear120();dropped120.clear();created120=0;next_join120=BALANCE120.JOIN_GAP;group_left120=0
 super.start_combat(reposition)
 total_enemies=BALANCE120.TOTAL
func _spawn_wave110(_index: int) -> void:
 round_index=0;between_left=0.;last_attacker=null;_clear_combat_shots();packs114=1
 var g: Vector2=meadow.landmarks.grove;var occupied: Array[Vector2]=[]
 for i in 3:
  var actor: CharacterBody3D
  if reuse119.size()==3: actor=reuse119[i]
  else: actor=make_actor119(i,_pick_spawn114(g+[Vector2(-4,-2),Vector2(3.5,-3),Vector2(.7,-5.5)][i],occupied))
  occupied.append(Vector2(actor.position.x,actor.position.z));enemies.append(actor);actor.play119()
 reuse119.clear();created120=3;rebuild_cells110();target114=null;aim_tick114=-1
func enemy_defeated(enemy: CharacterBody3D) -> void:
 if not active114 or retired119.has(enemy.get_instance_id()): return
 retired119[enemy.get_instance_id()]=true;defeated_count+=1
 if steering_indices113.has(enemy): steering_alive113[int(steering_indices113[enemy])]=0
 if target114==enemy: target114=null;aim_tick114=-1
 if defeated_count==BALANCE120.TOTAL: ending119=1.4;drops120.force_collect120=true
func defeat_drop120(actor: CharacterBody3D) -> void:
 if not active114 or not actor.dead or dropped120.has(actor.get_instance_id()): return
 # Exactly one roll per defeated actor, independent of weapon and hit count.
 dropped120[actor.get_instance_id()]=true
 if rng120.randf()>=BALANCE120.ACTOR_DROP_CHANCE: return
 drops120.spawn120(actor.global_position+Vector3.UP*.6,Vector3(rng120.randf_range(-1.5,1.5),3.,rng120.randf_range(-1.5,1.5)))
func collect_gel120() -> bool:
 memory_kit116.gel119+=1
 if memory_kit116.save_to(memory_save116)==OK: return true
 memory_kit116.gel119-=1;return false
func _step_outing119(delta: float) -> void:
 var alive := 0
 for actor in enemies:
  if is_instance_valid(actor) and not actor.dead: alive+=1
 if created120<BALANCE120.TOTAL and group_left120==0 and elapsed114>=next_join120 and alive<=2:
  var occupied: Array[Vector2]=[]
  for actor in enemies:
   if is_instance_valid(actor): occupied.append(Vector2(actor.position.x,actor.position.z))
  for i in BALANCE120.GROUP:
   var at := _pick_spawn114(meadow.landmarks.grove+Vector2(-6. if i%2==0 else 6.,-4.),occupied);occupied.append(at)
   standby119.append(make_actor119(created120+i,at))
  group_left120=BALANCE120.GROUP;notice119=1.2;encounter_hud.announce("“这里好热闹！”","又有团团跑来一起玩。",1.8)
 if group_left120>0:
  notice119-=delta
  if notice119<=0. and alive<BALANCE120.MAX_ACTIVE:
   var actor: CharacterBody3D=standby119.pop_front();enemies.append(actor);created120+=1;joined119+=1;group_left120-=1
   actor.join119(meadow.landmarks.grove+Vector2(-2. if created120%2==0 else 2.,-.6));rebuild_cells110();notice119=.65
   if group_left120==0: notice119=-1.;next_join120=elapsed114+BALANCE120.JOIN_GAP
 if ending119>=0.:
  ending119=maxf(0.,ending119-delta)
  if ending119<=0. and drops120.items120.is_empty(): won119=true;finish114()
func retry_reward119() -> bool:
 if not won119: return false
 if memory_kit116.last_reward119>=event119: return true
 var previous: int=memory_kit116.last_reward119;memory_kit116.last_reward119=event119
 if memory_kit116.save_to(memory_save116)==OK: return true
 memory_kit116.last_reward119=previous;return false
func reward_text119() -> String: return "本场材料来自团团退场时的概率掉落，没有额外结算礼包。"
func _leave_encounter() -> void:
 if is_instance_valid(drops120): drops120.clear120()
 super._leave_encounter()
