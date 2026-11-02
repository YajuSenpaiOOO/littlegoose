extends "res://scripts/world/woodland_world259.gd"
var minions260: Array[CharacterBody3D]=[]
var pending260 := 0
var spawn_wait260 := 0.
var serial260 := 0
var attack_gate260 := 0.
var parry_kind260 := "other"
var damage_kind260 := "weapon"
var telemetry260=preload("res://scripts/combat/boss_record260.gd").new()
func boss_script251() -> Script:return preload("res://scripts/combat/tuantuan_boss260.gd")
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 260 · 团团Boss / 同伴弹飞")
func reset_stats226(partial: bool) -> void:
 super.reset_stats226(partial);telemetry260=preload("res://scripts/combat/boss_record260.gd").new();telemetry260.begin(self)
func live_minions260() -> Array:
 return minions260.filter(func(m):return is_instance_valid(m) and not m.dead and not m.is_queued_for_deletion())
func clear_minions260() -> void:
 pending260=0
 for m in minions260:
  if not is_instance_valid(m):continue
  if is_instance_valid(m.projection260):actor_shadows.erase(m.projection260)
  enemies.erase(m);m.set_physics_process(false);m.set_process(false);m.collision_layer=0;m.hit_area.collision_layer=0
  if m.is_inside_tree():remove_child(m)
  m.queue_free()
 minions260.clear();_prune_actor_shadows();target114=null;aim_tick114=-1;rebuild_cells110()
func clear251() -> void:
 clear_minions260();super.clear251()
func begin251() -> void:
 pending260=0;spawn_wait260=0.;serial260=0;attack_gate260=0.;parry_kind260="other";damage_kind260="weapon";super.begin251()
func finish251(victory: bool) -> void:
 telemetry260.finish(self,"victory" if victory else "ended");clear_minions260();super.finish251(victory)
func boss_phase260(old: String,next: String) -> void:
 var completed=old=="flat" and next=="rest" and not telemetry260.current.is_empty()
 telemetry260.phase_changed(old,next)
 if completed and active114 and pending260==0:
  pending260=mini(2,3-live_minions260().size());spawn_wait260=.35
func boss_landing260(at: Vector2,index: int) -> void:
 telemetry260.landing(index)
 for m in live_minions260():
  if Vector2(m.position.x,m.position.z).distance_to(at)<=2.3 and absf(m.position.y-floor_height(at))<.65 and m.toss260(at):telemetry260.thrown()
func wall_crash260() -> void:
 if telemetry260.data.is_empty():return
 telemetry260.data.boss.wall_crashes+=1;telemetry260.event("wall_crash")
func spawn_minion260() -> CharacterBody3D:
 if live_minions260().size()>=3:return null
 var occupied: Array[Vector2]=[Vector2(hero.position.x,hero.position.z),Vector2(boss247.position.x,boss247.position.z)]
 for m in live_minions260():occupied.append(Vector2(m.position.x,m.position.z))
 var offsets=[Vector2(-5.5,1.5),Vector2(5.5,1.5),Vector2(-3.,-5.),Vector2(3.,-5.)]
 var at=Vector2.ZERO;var found=false
 for i in offsets.size():
  at=_pick_spawn114(meadow.landmarks.grove+offsets[(serial260+i)%offsets.size()],occupied)
  if at.distance_to(Vector2(hero.position.x,hero.position.z))>=3.2:found=true;break
 if not found:return null
 var m=minion_script260().new()
 m.battle=self;m.poses=combat_poses;m.textures=combat_textures;m.home=meadow.landmarks.grove;m.rank110=0;m.body_scale110=1.;m.max_hp110=6.;m.hp=6.;m.touch110=1.;m.role110=serial260+200;serial260+=1
 m.position=Vector3(at.x,floor_height(at)+.03,at.y);add_child(m);minions260.append(m);m.reset_physics_interpolation()
 _add_actor_shadow(m,m.visual);m.projection260=actor_shadows[-1];time55.apply_look();rebuild_cells110();target114=null;aim_tick114=-1
 telemetry260.data.minions.spawned+=1;telemetry260.event("minion_spawn",{"serial":serial260});return m
func target_minion260(m: CharacterBody3D,enabled: bool) -> void:
 if enabled:
  if m not in enemies:enemies.append(m)
 else:enemies.erase(m)
 target114=null;aim_tick114=-1;rebuild_cells110()
func reserve_attack(enemy: CharacterBody3D) -> bool:
 if enemy in minions260:
  if not active114 or combat_paused or player_hp<=0. or attack_gate260>0. or not minion_attack_allowed260():return false
  for m in live_minions260():
   if m!=enemy and m.attack_phase in ["windup","lunge"]:return false
  attack_gate260=1.3;return true
 return super.reserve_attack(enemy)
func _visible114(enemy: CharacterBody3D,origin: Vector3) -> bool:
 if enemy in minions260 and not enemy.targetable260():return false
 return super._visible114(enemy,origin)
func enemy_defeated(actor: CharacterBody3D) -> void:
 if actor in minions260:
  telemetry260.data.minions.defeated+=1;telemetry260.event("minion_defeated");target114=null;aim_tick114=-1;return
 super.enemy_defeated(actor)
func record_enemy_damage226(actor: Node,damage: float) -> void:
 if actor==boss247:
  super.record_enemy_damage226(actor,damage);telemetry260.damage(self,true,damage,damage_kind260)
 elif actor in minions260:telemetry260.damage(self,false,damage,damage_kind260)
 else:super.record_enemy_damage226(actor,damage)
func _parry_fan34(contact: Vector3) -> void:
 var first=shots.size();super._parry_fan34(contact)
 for i in range(first,shots.size()):shots[i]["damage_source260"]="parry_fan"
func _apply_shot_hit(shot: Dictionary,hit: Dictionary) -> void:
 var source=damage_kind260;damage_kind260=shot.get("damage_source260","weapon");super._apply_shot_hit(shot,hit);damage_kind260=source
func parry_success(contact: Vector3,outward: Vector3) -> void:
 var before=parry_count;super.parry_success(contact,outward)
 if parry_count>before:telemetry260.parry(parry_kind260)
func on_dash_started() -> void:
 super.on_dash_started()
 if active114:telemetry260.dash()
func perfect_dodge() -> void:
 var before=perfect_dodges;super.perfect_dodge()
 if perfect_dodges>before and not telemetry260.data.is_empty():telemetry260.data.inputs.perfect_dodges+=1
func hurt_player(damage: float,from: Vector2) -> void:
 var before=player_hp;var source=damage_source226;super.hurt_player(damage,from)
 if player_hp<before:telemetry260.injury(self,before-player_hp,source)
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 if not ready251 or not active114 or combat_paused:return
 telemetry260.tick(self,delta);attack_gate260=maxf(0.,attack_gate260-delta)
 if pending260>0:
  spawn_wait260-=delta
  if spawn_wait260<=0.:
   if live_minions260().size()<3:spawn_minion260()
   pending260-=1;spawn_wait260=.60
func report_stats226() -> Dictionary:
 var report=super.report_stats226()
 if not report.has("tuantuan260"):report["tuantuan260"]=telemetry260.snapshot(self)
 return report
func summary_stats226() -> String:
 var text=super.summary_stats226()
 if telemetry260.data.is_empty():return text
 var d=telemetry260.data
 return text+"\n弹反 %d（Boss%d / 小团团%d / 其它%d）\n撞墙%d次 · 弹瘪期间伤害 %.1f\n小团团伤害 %.1f · 弹飞%d次"%[d.parries.total,d.parries.boss,d.parries.minion,d.parries.other,d.boss.wall_crashes,d.boss.damage_by_phase.get("recovery",0.),d.minions.damage,d.minions.thrown]
func _process(delta: float) -> void:
 super._process(delta)
 if ready251:guide206.text=guide206.text.replace("259 团团Boss · 闪避路线","260 团团Boss · 同伴弹飞")+"\n小团团 %d / 3"%live_minions260().size()

func minion_script260() -> Script:return preload("res://scripts/combat/tuantuan_minion260.gd")
func minion_attack_allowed260() -> bool:return boss247.phase247 not in ["flat","bumper"]
