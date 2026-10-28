extends "res://scripts/world/guard109_probe.gd"
class Fighter:
 extends "res://scripts/combat/hero110.gd"
 var button := false
 var wish := Vector2.ZERO
 func parry_key_down() -> bool: return button and controls_enabled
 func movement_input() -> Vector2: return Vector2.ZERO if guarding109 else wish
 func dash_key_down() -> bool: return false
class Battle110:
 extends "res://scripts/world/woodland_world110.gd"
 var permit := false
 var immortal := true
 var shooting := false
 func _hero_script() -> Script: return Fighter
 func fire_input_held() -> bool: return shooting
 func start_combat(reposition := true) -> void:
  if permit: super.start_combat(reposition)
 func hurt_player(damage: float,at: Vector2) -> void:
  super.hurt_player(damage,at)
  if immortal and player_hp>0.: player_hp=100.
func disable_enemies(sample: Node3D) -> void:
 for enemy in sample.enemies:
  if is_instance_valid(enemy): enemy.active_ai=false;enemy.set_physics_process(false)
func one_enemy(sample: Node3D,rank: int,at: Vector2) -> CharacterBody3D:
 var enemy: CharacterBody3D=sample._enemy_script().new();enemy.battle=sample;enemy.poses=sample.combat_poses;enemy.textures=sample.combat_textures
 enemy.rank110=rank;enemy.body_scale110=1. if rank==0 else (1.7 if rank==1 else 2.6);enemy.max_hp110=1000.;enemy.hp=1000.;enemy.home=sample.meadow.landmarks.grove
 enemy.position=Vector3(at.x,sample.floor_height(at)+.06,at.y);sample.add_child(enemy);sample.enemies.append(enemy);sample._add_actor_shadow(enemy,enemy.visual);return enemy
func create_sample110() -> Node3D: return Battle110.new()
func run() -> void:
 var sample := create_sample110();root.add_child(sample)
 while not sample.woodland_ready110: await physics_frame
 sample.permit=true;sample.start_combat();await settle72(15);disable_enemies(sample)
 var g: Vector2=sample.meadow.landmarks.grove
 verify(sample.enemies.size()==3 and sample.total_enemies==34,"first full encounter has three ordinary enemies and 34 total across six acts")
 verify(sample.DATA110.ACT_TABLE.size()==13 and sample.buffs.eligible().size()==14,"all thirteen legacy act rows and fourteen childhood cards are available")
 sample.hero.controls_enabled=true;sample._teleport15(g+Vector2(0,2));await settle72(10)
 # Native parry uses the new held guard, not a substitute invulnerability switch.
 sample.hero.set_physics_process(false);sample.hero.button=true;sample.hero.reset_actions();sample.hero.parry_previous=false;sample.invulnerability=0.;sample.hero._physics_process(1./60.)
 var foe := one_enemy(sample,0,g+Vector2(0,.4));foe.set_physics_process(false);foe.attack_phase="lunge";foe.phase_clock=0.;foe.attack_distance=3.;foe.attack_direction=Vector2.DOWN;foe.attack_connected=false;foe.active_ai=true
 var parries: int=sample.parry_count;foe._physics_process(1./60.)
 verify(sample.parry_count==parries+1 and foe.parried_count==1,"native ordinary lunge is perfectly parried only on the fresh press")
 sample.hero._physics_process(.3);sample.invulnerability=0.;sample.immortal=false;sample.player_hp=100.;sample.hurt_player(20.,g)
 verify(sample.player_hp==88. and sample.hero.guarding109,"the same held input later becomes ordinary 40-percent damage reduction")
 await settle72(18);sample.hero.visual.modulate=Color.WHITE;sample.hero.render_pose()
 var guard_frame := await snapshot();guard_frame.save_png("res://docs/captures/world_restart/combat110_held_guard.png")
 sample.immortal=true;sample.player_hp=100.;sample.hero.button=false;sample.hero.reset_actions();sample.hero.set_physics_process(true)
 # All data/art/dictionary lifecycles are exercised without waiting for timeout.
 sample.buffs.levels.clear();sample._apply_owned_buffs();sample._clear_combat_shots();sample.result_open=false;sample.between_left=0.
 var ids := {}
 for i in 48: sample.fire_at(sample.projectile_origin()+Vector3(3,0,-5))
 for shot in sample.shots: ids[shot.node.get_instance_id()]=true;shot.charged=true;shot.note110=true;shot.damage_multiplier=99.
 sample._clear_combat_shots();var allocated: int=sample.pool110.births
 for i in 48: sample.fire_at(sample.projectile_origin()+Vector3(3,0,-5))
 var reused := 0;var clean := true
 for shot in sample.shots:
  if ids.has(shot.node.get_instance_id()): reused+=1
  clean=clean and not shot.get("charged",false) and not shot.get("note110",false) and float(shot.get("damage_multiplier",1.))==1.
 verify(reused==48 and clean and sample.pool110.births==allocated,"48 projectile states/art/data are reused with charged/note/damage state cleared")
 verify(not sample.shots[0].node is Node and not sample.shots[0].art is Node,"pooled bullets and drawing records allocate no scene nodes")
 sample._clear_combat_shots()
 # Native rank AI, with real ground motion and original timing.
 sample.hero.controls_enabled=true;sample._teleport15(g+Vector2(0,2));sample.invulnerability=0.;sample.player_hp=100.
 foe.queue_free();await settle72(2)
 var elite := one_enemy(sample,1,g+Vector2(-5,1));elite.force_strike110="dash";elite.estate110="rage";elite.timer110=0.
 await settle72(1);var from: Vector3=elite.position;await settle72(25)
 verify(elite.strikes110.dash==1 and elite.position.distance_to(from)>2.,"elite long dash traverses real 3D ground")
 elite.set_physics_process(false);sample._teleport15(g+Vector2(0,2));elite.position=Vector3(g.x+1,sample.floor_height(g+Vector2(1,0))+.06,g.y);elite.force_strike110="slam";elite.estate110="rage";elite.timer110=0.;elite.set_physics_process(true)
 await settle72(370)
 verify(elite.strikes110.slam>=3,"elite performs three separately timed slams before recovery")
 elite.active_ai=false;elite.set_physics_process(false)
 var boss := one_enemy(sample,2,g+Vector2(3,-1));boss.force_strike110="slam";boss.estate110="rage";boss.timer110=0.
 var saw_wave := false
 for i in 300:
  await physics_frame
  if not sample.skills110.waves110.is_empty(): saw_wave=true
 verify(boss.strikes110.slam>=1 and saw_wave,"king giant slam emits its expanding native gameplay shockwave")
 boss.set_physics_process(false);boss.force_strike110="charge";boss.position=Vector3(g.x-6,sample.floor_height(g+Vector2(-6,1))+.06,g.y+1);boss.estate110="rage";boss.timer110=0.;sample._teleport15(g+Vector2(3,1));boss.set_physics_process(true)
 await settle72(70)
 verify(boss.strikes110.charge>=1,"king uses its distinct leaning straight charge")
 boss.set_physics_process(false);elite.queue_free();boss.queue_free();await settle72(2)
 # Verify card mechanics with actual enemies and shots.
 sample.buffs.levels.clear();sample.buffs.apply("music_class");sample.buffs.apply("music_class");sample.buffs.apply("music_class")
 verify(not sample.buffs.apply("flashlight"),"legacy music/flashlight conflict is enforced")
 sample._clear_combat_shots();sample.fire_at(sample.projectile_origin()+Vector3(0,0,-7));verify(sample.shots.size()==1 and sample.shots[0].get("note110",false),"third music card always creates a real 1.5x note projectile")
 sample._clear_combat_shots();sample.buffs.levels.clear();sample.buffs.apply("forest_fireboy");sample.buffs.apply("three_player");sample.buffs.apply("distract");sample.buffs.apply("distract");sample._apply_owned_buffs();await settle72(10)
 sample.fire_at(sample.projectile_origin()+Vector3(0,0,-7));verify(sample.skills110.geese110.size()==3 and sample.shots.size()==12,"four geese times three lanes create twelve physical shots")
 sample._clear_combat_shots();sample.buffs.levels.clear();sample.buffs.apply("snack");sample.buffs.apply("snack");sample._apply_owned_buffs()
 var target := one_enemy(sample,0,g+Vector2(0,-1));target.set_physics_process(false);sample._teleport15(g+Vector2(0,3));await settle72(8)
 sample.fire_at(target.position+Vector3.UP*.8);await settle72(70)
 verify(target.hit_count>0 and sample.pool110.reused>50,"split-card projectile collision and pooled fragment lifecycle run in the native battle")
 sample._clear_combat_shots();sample.buffs.levels.clear();sample.buffs.apply("flashlight");sample._apply_owned_buffs();sample.beam_left110=.3
 root.warp_mouse(sample.camera.unproject_position(target.position+Vector3.UP*.8));var hits: int=sample.skills110.beam_hits110;await settle72(40)
 verify(sample.skills110.beam_hits110>hits,"flashlight pierces a real native enemy on the aimed line")
 sample.buffs.apply("slingshot");sample._release_charged(target.position+Vector3.UP*.8,1.);verify(sample.beam_left110>1.0,"flashlight plus slingshot produces the original 1.1-second sweeping particle jet")
 await settle72(8);var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/combat110_beam.png")
 await extra_cards110(sample,target,g)
 target.queue_free();await settle72(2)
 # Clear all six acts through the actual kill -> delayed draft -> choose route.
 sample.buffs.levels.clear();sample._apply_owned_buffs();sample.start_combat();await settle72(10)
 for act in 6:
  disable_enemies(sample);var alive := []
  for enemy in sample.enemies:
   if is_instance_valid(enemy) and not enemy.dead: alive.append(enemy)
  verify(alive.size()==sample.count_for110(act),"act %d has the legacy ordinary/elite/king population"%(act+1))
  var reachable := true
  for enemy in alive:
   var path: PackedVector2Array=sample.navigation.path(Vector2(enemy.position.x,enemy.position.z),Vector2(sample.hero.position.x,sample.hero.position.z))
   reachable=reachable and not path.is_empty() and path[-1].distance_to(Vector2(sample.hero.position.x,sample.hero.position.z))<1.1
  verify(reachable,"act %d spawns on the connected playable floor"%(act+1))
  if act==5:
   sample.label.get_parent().hide();sample.frames66.panel.hide();var frame2 := await snapshot();frame2.save_png("res://docs/captures/world_restart/combat110_king.png")
  for enemy in alive: enemy.receive_hit(9999.,Vector3.RIGHT)
  for i in 220:
   await physics_frame
   if sample.draft_open: break
  await settle72(20)
  verify(sample.draft_open and sample.choose_buff(0),"act %d reward selection works"%(act+1))
  await settle72(5)
 verify(sample.wave_state=="cleared" and sample.defeated_count==34 and sample.result_open,"king clear ends the six-act battle without silently restarting")
 sample.continue_exploring();verify(sample.result_dismissed and sample.hero.controls_enabled,"victory returns to exploration")
 var data := {"checks":checks,"failures":failures,"pooled_reuses":sample.pool110.reused,"projectile_births":sample.pool110.births,"six_act_kills":sample.defeated_count}
 var file := FileAccess.open("res://docs/combat110-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));print("COMBAT110 ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)

func extra_cards110(sample: Node3D,target: CharacterBody3D,g: Vector2) -> void:
 sample._clear_combat_shots();sample.buffs.levels.clear();sample._apply_owned_buffs();sample.hero.button=false;sample.hero.reset_actions()
 var speed: float=sample.hero.movement_speed();sample.buffs.apply("paper_racer")
 verify(absf(sample.hero.movement_speed()/speed-1.3)<.0001,"first paper racer grants its 30 percent movement gain")
 sample.buffs.apply("paper_racer");verify(absf(sample.hero.movement_speed()/speed-1.56)<.0001,"second paper racer multiplies the first by 1.2")
 sample.buffs.levels.clear();sample.combo=0;var damage: float=sample.damage_for_shot({});sample.buffs.apply("red_banner");sample.combo=9
 verify(sample.damage_for_shot({})==damage,"red banner waits for ten combo")
 sample.combo=10;verify(absf(sample.damage_for_shot({})/damage-1.4)<.0001,"first red banner activates at ten combo")
 sample.buffs.apply("red_banner");sample.combo=5;verify(absf(sample.damage_for_shot({})/damage-1.4)<.0001,"second red banner lowers the threshold to five")
 var book := preload("res://scripts/combat/buff_book110.gd").new();book.rng110.seed=110
 book.apply("east_west");var gained := 0
 for id in book.levels:
  if id!="east_west": gained+=int(book.levels[id])
 verify(gained in [1,2],"east west grants actual eligible bonus cards")
 sample.buffs.levels.clear();sample.buffs.apply("homework");sample._apply_owned_buffs();sample._teleport15(g+Vector2(0,3))
 target.position=sample.hero.position+Vector3(.25,0,0);target.hp=1000.;sample.rebuild_cells110()
 var aura: int=sample.skills110.aura_hits110;sample.skills110.tick110=0.;sample.skills110.step110(.14)
 verify(sample.skills110.aura_hits110>aura and target.hp<1000.,"homework sweat contacts and damages a nearby native enemy")
 sample.buffs.levels.clear();sample.buffs.apply("exercise");sample.skills110.reset110();sample.hero.dash_count+=1;sample.hero.dash_left=.1;sample.hero.dash_direction=Vector2.RIGHT
 var hp: float=target.hp;sample.skills110.step110(.001);var once: float=target.hp;sample.skills110.step110(.001)
 verify(once<hp and target.hp==once,"exercise damages each enemy once per actual dash")
 sample.hero.dash_left=0.;sample.buffs.levels.clear();sample.buffs.apply("forest_fireboy");sample.buffs.apply("three_player");sample.buffs.apply("cup_phone");sample._apply_owned_buffs()
 var phones: bool=sample.goose.cup_phone
 for goose in sample.skills110.geese110: phones=phones and goose.cup_phone
 verify(phones and sample.skills110.geese110.size()==3,"cup phone enables free flight on all four geese")
 var contacts: int=sample.cup_contact_hits;var extra: Node3D=sample.skills110.geese110[0];extra.position=target.position;extra.contact_clock=10.;extra.contact_next.clear();extra.step_contact()
 verify(sample.cup_contact_hits>contacts,"an additional goose causes actual native contact damage")
 sample.buffs.levels.clear();sample._apply_owned_buffs();sample.combo=0
 # A native box checks that fast pooled shots still obey scenery collision.
 var wall := StaticBody3D.new();wall.collision_layer=2;var shape := CollisionShape3D.new();var box := BoxShape3D.new();box.size=Vector3(.3,2.,2.);shape.shape=box;wall.add_child(shape)
 wall.position=sample.hero.position+Vector3(3,1,0);sample.add_child(wall);await settle72(2)
 var start: Vector3=wall.position-Vector3(1,0,0);var shot: Dictionary=sample.data_shot110(start,Vector3.RIGHT*12.,.5)
 var hit: Dictionary=sample._trace_shot(shot,start,start+Vector3.RIGHT*2.)
 verify(not hit.is_empty() and hit.collider==wall,"data-only bullets retain native scenery collision")
 sample._clear_combat_shots();wall.queue_free()
