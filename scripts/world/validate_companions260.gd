extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world260.gd"
 func _init() -> void:
  super._init();memory_save116="user://companions260-validation-preview.cfg"
 func test_config_path226() -> String:return "user://companions260-validation.cfg"
 func export_stats226() -> Error:return OK
 func reset_stats226(partial: bool) -> void:
  super.reset_stats226(partial);recording226.folder="user://companions260-validation-records"
 func spawn_minion260() -> CharacterBody3D:
  var m=super.spawn_minion260()
  if is_instance_valid(m):m.set_physics_process(false)
  return m
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.ready251 or not w.console226.has_method("draft_level257"):await process_frame
 w.set_physics_process(false);w.hero.set_physics_process(false);w.auto114=false;w.invulnerability=1000.
 var b=w.boss247;b.set_physics_process(false);var shadows=w.actor_shadows.size()
 check(b.get_script().get_base_script().resource_path.ends_with("tuantuan_boss259.gd") and b.hp==90.,"accepted259 pursuit and ninety boss HP retained")
 check(w.player_hp==12. and w.capacity257()==4,"initial determination and console baseline retained")
 b.enter247("angry")
 for i in 500:
  await physics_frame
  w.reset_impact248();Engine.time_scale=1.;b._physics_process(1./60.);w._physics_process(1./60.)
  if b.phase247=="flat":break
 check(b.landings247.size()==7 and w.live_minions260().is_empty() and w.pending260==0,"entire first chain and start of recovery remain solo")
 b.receive_hit(7.,Vector3.RIGHT)
 check(w.telemetry260.data.boss.damage_by_phase.get("recovery",0.)==7.,"damage during flat recovery is measured separately")
 b._physics_process(2.66)
 check(w.pending260==2 and w.telemetry260.data.rounds.size()==1,"companions queued only after first recovery ends")
 w._physics_process(.36);check(w.live_minions260().size()==1,"entry wave spawns its first member")
 w._physics_process(.61);check(w.live_minions260().size()==2,"second member follows after a visible entry gap")
 var m=w.minions260[0]
 check(m.state260=="enter" and m.hit_area.collision_layer==0 and m not in w.enemies,"arriving minion cannot immediately attack or steal target lock")
 m._physics_process(.86);w.minions260[1]._physics_process(.86)
 check(m.state260=="ground" and m in w.enemies and m.hit_area.collision_layer==8,"ordinary ground actor joins native enemy and hit registry")
 check(is_instance_valid(m.projection260) and not m.shadow.visible,"companion uses shared silhouette without duplicate ellipse")
 var third=w.spawn_minion260();third._physics_process(.86)
 check(w.live_minions260().size()==3 and w.spawn_minion260()==null,"live companion population is capped at three")
 for other in w.live_minions260():
  if other!=m:other.position=b.position+Vector3(5.,0.,float(other.role110%2)*2.)
 m.position=b.position+Vector3(1.1,0,0);m.position.y=w.floor_height(Vector2(m.position.x,m.position.z))+.03;m.reset_physics_interpolation()
 w.hero.position=b.position+Vector3(0.,0.,5.);var hp=w.player_hp
 b.enter247("flight");b.jump247=2;b.land247()
 check(m.state260=="air" and m.collision_layer==0 and m.hit_area.collision_layer==0 and m not in w.enemies,"real boss landing launches nearby minion and removes airborne attack/target collision")
 check(w.telemetry260.data.minions.thrown==1,"launch interaction is recorded once")
 var air_clock=m.clock260;var record_clock=w.telemetry260.data.physics_seconds
 w.combat_paused=true;m._physics_process(.2);w._physics_process(.2)
 check(m.clock260==air_clock and w.telemetry260.data.physics_seconds==record_clock,"pause freezes flying companion and dedicated encounter clock")
 w.combat_paused=false
 var minion_hp=m.hp;m.receive_hit(3.,Vector3.RIGHT)
 check(m.hp==minion_hp,"airborne minion does not absorb player shots")
 for i in 20:
  await physics_frame;m._physics_process(1./60.)
 m.reset_physics_interpolation();await shot("companions260-air")
 check(m.visual.position.y>.4 and is_instance_valid(m.projection260),"launched species body and world shadow separate visibly")
 for i in 20:
  await physics_frame;w.hero.position=m.position;m._physics_process(1./60.)
 check(w.player_hp==hp and m.state260=="dazed" and m in w.enemies,"flying body is harmless and lands in a targetable daze")
 m._physics_process(.91)
 check(m.state260=="ground" and m.collision_layer==16,"dazed minion recovers its ordinary grounded AI")
 b.enter247("flat");m.attack_phase="lunge";w.invulnerability=0.;hp=w.player_hp;m._physics_process(.05)
 check(w.player_hp==hp and m.attack_phase=="recover","boss punish window cancels companion attack")
 await shot("companions260-dazed")
 b.enter247("rest");w.attack_gate260=0.;m.attack_phase="approach"
 check(w.reserve_attack(m) and not w.reserve_attack(w.minions260[1]),"companions share a gentle attack gate")
 w.hero.position=m.position+Vector3(1.2,0,0);w.hero.cancel_guard109();w.hero.dodge_invulnerability=0.;w.invulnerability=0.;hp=w.player_hp
 m._begin_windup(Vector2(w.hero.position.x,w.hero.position.z));m.attack_phase="lunge";m.phase_clock=0.
 for i in 18:
  await physics_frame;m._physics_process(1./60.)
  if w.player_hp<hp:break
 metrics.ground={"before":hp,"after":w.player_hp,"state":m.state260,"phase":m.attack_phase,"clock":m.phase_clock,"play":m.play_state123,"active":m.active_ai,"tactical":w.tactical_combat,"wave":w.wave_state,"grace":w.parry_grace258,"at":str(m.position),"hero":str(w.hero.position)}
 check(w.player_hp==hp-1. and not w.stats226.injuries.is_empty() and w.stats226.injuries[-1].source=="tuantuan_minion","grounded ordinary lunge deals one determination with correct source")
 w.hero.cancel_guard109();w.hero.parry_cd=0.;w.hero.dodge_invulnerability=0.;w.invulnerability=0.;w.hero.request_parry();m.deflect(m.position+Vector3.UP*.65)
 check(w.telemetry260.data.parries.minion==1,"ordinary companion parry is recorded separately from boss parry")
 w.hero.cancel_guard109();w.reset_impact248();w.parry_grace258=0.
 var before=w.stats226.cat_damage;m.receive_hit(100.,Vector3.LEFT)
 check(m.dead and w.active114 and w.stats226.cat_damage==before and w.telemetry260.data.minions.damage==6.,"minion defeat neither wins encounter nor pollutes boss DPS")
 check(w.telemetry260.data.minions.defeated==1,"companion defeat recorded separately")
 # Exercise the actual console recording path, including a fresh telemetry session.
 w.toggle_console226();w.console226.draft={};w.console226.determination257.value=1;w.console226.record226()
 b=w.boss247;b.set_physics_process(false);w.hero.set_physics_process(false);w.auto114=false
 check(w.recording226.active and w.telemetry260.data.boss.damage==0.,"record button begins a clean companion/boss telemetry session")
 b.enter247("angry");w._physics_process(.2);b.receive_hit(4.,Vector3.RIGHT)
 b.enter247("flight");b.jump247=3;w._physics_process(.3)
 b.position=w.hero.position+Vector3(.2,0,0);b.from247=Vector2(b.position.x,b.position.z)-Vector2.RIGHT;b.goal247=Vector2(b.position.x,b.position.z)
 w.hero.cancel_guard109();w.hero.parry_cd=0.;w.hero.dodge_invulnerability=0.;w.invulnerability=0.;w.hero.request_parry()
 b.strike257(2.,Vector2(b.position.x,b.position.z),"tuantuan_sweep");w.reset_impact248();w.telemetry260.poll(w)
 check(w.telemetry260.data.parries.boss==1 and w.telemetry260.data.inputs.parry_attempts==1,"actual boss parry and input attempt counted apart from music Perfect")
 w.hero.cancel_guard109();w.hero.request_dash(Vector2.RIGHT)
 check(w.telemetry260.data.inputs.dashes==1,"real dash event belongs to this recording")
 b.enter247("flight");b.wall_armed256=true;var boss_hp=b.hp;b.crash256();w.reset_impact248()
 check(b.hp==boss_hp-5. and w.telemetry260.data.boss.wall_crashes==1 and w.telemetry260.data.boss.damage_by_source.wall==5.,"actual reflected crash records wall damage and event")
 b.enter247("flat");w._physics_process(.4);b.receive_hit(6.,Vector3.RIGHT);b.enter247("rest")
 check(w.telemetry260.data.rounds.size()==1 and w.telemetry260.data.rounds[0].recovery_damage==6.,"complete chain includes recovery damage and per-round outcome")
 m=w.spawn_minion260();m._physics_process(.86);m.receive_hit(2.,Vector3.RIGHT)
 check(w.telemetry260.data.minions.damage==2. and w.stats226.cat_damage==15.,"boss and companion damage totals remain independent")
 w._parry_fan34(w.hero.position+Vector3.UP*.65)
 check(w.shots.size()>=3 and w.shots[-1].get("damage_source260","")=="parry_fan","native parry fan shots carry an explicit damage source")
 boss_hp=b.hp
 w._apply_shot_hit(w.shots[-1],{"collider":b.hit_area,"position":b.hit_area.global_position,"normal":Vector3.LEFT})
 check(b.hp<boss_hp and w.telemetry260.data.boss.damage_by_source.get("parry_fan",0.)>0.,"native parry fan hit is distinguished from ordinary weapon damage")
 w._clear_combat_shots()
 var report=w.report_stats226()
 check(report.tuantuan260.phase_seconds.get("recovery",0.)>=.4 and report.tuantuan260.parries.boss==1,"C report exposes boss phases and parry counts")
 w.toggle_console226();await process_frame;await shot("companions260-console");w.close_console226()
 var id=w.recording226.id;w.finish251(true)
 var file=FileAccess.open(w.recording226.folder+"/"+id+".json",FileAccess.READ)
 var saved=JSON.parse_string(file.get_as_text());file.close()
 check(saved.has("tuantuan260") and saved.tuantuan260.finalized and saved.tuantuan260.minions.damage==2. and saved.tuantuan260.inputs.parry_attempts==1,"finished JSON persists dedicated encounter telemetry")
 check(w.minions260.is_empty() and w.pending260==0 and w.echoes256.is_empty(),"victory clears grounded/airborne companions and pending spawns")
 var snapshot=w.report_stats226().tuantuan260.duplicate(true);await settle(4)
 check(w.report_stats226().tuantuan260==snapshot,"archived telemetry remains immutable after end")
 w.begin251();b=w.boss247;b.set_physics_process(false)
 check(w.enemies.size()==1 and w.actor_shadows.size()==shadows and w.telemetry260.data.minions.spawned==0,"restart resets roster, shadows and telemetry")
 var ok=checks.all(func(c):return c.pass)
 var out=FileAccess.open("res://docs/companions260-validation.json",FileAccess.WRITE);out.store_string(JSON.stringify({"passed":ok,"checks":checks,"metrics":metrics},"  "));out.close()
 print("COMPANIONS260_VALIDATION ",ok," checks=",checks.size()," metrics=",metrics);quit(0 if ok else 1)
