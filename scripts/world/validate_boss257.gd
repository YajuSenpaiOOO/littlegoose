extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world257.gd"
 var legacy257 := false
 var suppress_echo257 := false
 func _init() -> void:
  super._init();memory_save116="user://boss257-validation-preview.cfg"
 func test_config_path226() -> String:return "user://boss257-validation.cfg"
 func export_stats226() -> Error:return OK
 func reset_stats226(partial: bool) -> void:
  super.reset_stats226(partial);recording226.folder="user://boss257-validation-records"
 func boss_script251() -> Script:
  return load("res://scripts/combat/tuantuan_boss256.gd") if legacy257 else super.boss_script251()
 func emit_echoes256(at: Vector2,forward: Vector2) -> void:
  if not suppress_echo257:super.emit_echoes256(at,forward)
func benchmark257(legacy: bool,pattern: String) -> Dictionary:
 w.legacy257=legacy;w.suppress_echo257=true;w.begin251()
 var b=w.boss247;b.set_physics_process(false);w.hero.set_physics_process(false);w.auto114=false
 w.player_hp=1000.;w.invulnerability=0.;w.hero.cancel_guard109();w.hero.dodge_invulnerability=0.
 var center=w.meadow.landmarks.grove+Vector2(0.,3.)
 var start=center+Vector2(3.6,0.);var point=start;var direction=1.
 w._teleport15(start);b.enter247("angry")
 var hits=0;var total=0.
 for i in 900:
  var dt=1./60.;var velocity=Vector2.ZERO
  if pattern=="orbit":
   var angle=float(i)*dt*4.1/3.6
   point=center+Vector2(cos(angle),sin(angle))*3.6;velocity=Vector2(-sin(angle),cos(angle))*4.1
  elif pattern=="walk":
   if point.x>center.x+4.:direction=-1.
   elif point.x<center.x-4.:direction=1.
   velocity=Vector2(4.1*direction,0.);point+=velocity*dt
  w.hero.position=Vector3(point.x,w.floor_height(point),point.y);w.hero.velocity=Vector3(velocity.x,0.,velocity.y)
  w.invulnerability=maxf(0.,w.invulnerability-dt);w.reset_impact248()
  var hp=w.player_hp;b._physics_process(dt)
  if w.player_hp<hp:hits+=1;total+=hp-w.player_hp
 return {"hits":hits,"damage":total,"pattern":pattern,"version":256 if legacy else 257}
func run() -> void:
 DirAccess.remove_absolute(ProjectSettings.globalize_path("user://boss257-validation.cfg"))
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.ready251 or not w.console226.has_method("draft_level257"):await process_frame
 w.hero.set_physics_process(false);w.boss247.set_physics_process(false);w.auto114=false
 check(w.determination_level257==1 and w.player_hp==12. and w.capacity257()==4,"fresh first-boss baseline is level1 / 12 determination / 4 slots")
 await settle(3)
 check(w.encounter_hud.gems.gem_count==12,"HUD uses twelve full determination gems")
 for level in [1,2,3,4]:check(w.health_at257(level)==11+level and w.slots_at257(level)==3+level,"each determination level adds one HP and slot %d"%level)
 w.toggle_console226();var console=w.console226
 console.determination257.value=2
 check(w.determination_level257==1 and console.capacity.text.contains("5槽") and console.capacity.text.contains("13"),"level edits are draft-only with live capacity preview")
 await shot("boss257-console")
 w.close_console226();check(w.determination_level257==1 and w.max_player_health()==12.,"cancel preserves actual progression")
 var five={"eye_exercise":1,"hero_moment":1,"exercise":1}
 check(w.loadout_error257(five,1)!="" and w.loadout_error257(five,2)=="","validation enforces dynamic slot capacity")
 check(console.INITIAL257.all(func(p):return w.loadout_error257(p,1)==""),"all beginner presets fit four slots")
 w.player_hp=9.5;var b=w.boss247;var at=b.position;var phase=b.phase247
 var error=w.commit_progress257(five,90.,32.,false,2)
 check(error=="" and w.player_hp==9.5 and w.max_player_health()==13. and w.capacity257()==5,"in-place level application preserves current HP without free healing")
 check(b.position==at and b.phase247==phase,"in-place application preserves boss position and phase")
 error=w.commit_progress257(five,90.,32.,false,1)
 check(error!="" and w.determination_level257==2 and w.levels226==five,"over-capacity downgrade is rejected atomically")
 var seven={"three_player":1,"eye_exercise":1,"hero_moment":1,"exercise":1}
 check(w.balance_profile226().error(seven)!="" and w.loadout_error257(seven,4)=="","legacy six-slot profile unchanged while level4 permits seven")
 error=w.commit_progress257(seven,90.,32.,true,4);b=w.boss247;b.set_physics_process(false)
 check(error=="" and w.player_hp==15. and w.capacity257()==7,"restart applies level and fills the new health maximum")
 w.determination_level257=1;w.levels226={};w.load_test226()
 check(w.determination_level257==4 and w.levels226==seven,"independent test config persists level and legal loadout together")
 w.toggle_console226();console.determination257.value=1;console.draft=seven.duplicate(true);console.refresh226()
 check(console.apply_button.disabled and console.restart_button.disabled,"lower draft level disables over-capacity apply")
 console.adjust226("exercise",-1);console.adjust226("three_player",-1)
 check(w.balance_profile226().cost(console.draft)==4 and not console.apply_button.disabled,"over-capacity drafts can be unloaded step by step")
 w.close_console226();w.player_hp=15.;w.commit_progress257({},90.,32.,false,1)
 check(w.player_hp==12. and w.capacity257()==4,"lowering maximum clamps current HP")
 w.begin251();b=w.boss247;b.set_physics_process(false);w.hero.set_physics_process(false);w.auto114=false;w.invulnerability=0.;w.hero.cancel_guard109()
 var center=Vector2(w.hero.position.x,w.hero.position.z)
 b.enter247("flight");b.jump247=6;b.lift247=.2;b.clock247=.15;b.position=w.hero.position+Vector3(-1.8,0,0);b.from247=Vector2(b.position.x,b.position.z);b.goal247=center+Vector2(2.2,0.)
 var hp=w.player_hp;b.move247(Vector2(240.,0.),1./60.)
 check(w.player_hp==hp-2. and b.sweep_hits257==1,"low bounce crossing deals swept body damage")
 hp=w.player_hp;b.land247()
 check(w.player_hp==hp,"one jump cannot deal body and landing damage twice")
 b.enter247("flight");b.jump247=0;b.lift247=2.;b.position=w.hero.position+Vector3(-1.8,0,0);w.invulnerability=0.
 b.move247(Vector2(240.,0.),1./60.)
 check(w.player_hp==hp,"high airborne body remains harmless before landing")
 b.position=w.hero.position;b.enter247("flight");b.jump247=0;b.lift247=0.;w.invulnerability=0.;hp=w.player_hp;b.land247()
 check(w.player_hp==hp-3.,"heavy landing costs three determination")
 b.enter247("flight");b.jump247=6;b.lift247=.2;w.invulnerability=.6;hp=w.player_hp;b.strike257(2.,center,"tuantuan_sweep")
 check(w.player_hp==hp,"native invulnerability prevents rapid repeated damage")
 check(w.stats226.injuries.any(func(i):return i.source=="tuantuan_sweep") and w.stats226.injuries.any(func(i):return i.source=="tuantuan_slam"),"C stats distinguish body sweep and heavy landing")
 b.enter247("angry");b.enter247("flight");b.hp=1000.;b.from247=Vector2(b.position.x,b.position.z)-Vector2.RIGHT;b.goal247=Vector2(b.position.x,b.position.z)
 w.hero.position=b.position;w.hero.parry_t=.15;w.hero.parried=false;w.hero.dodge_invulnerability=0.;w.invulnerability=0.
 b.strike257(2.,Vector2(b.position.x,b.position.z),"tuantuan_sweep")
 check(b.phase247=="deflected" and b.reverse_pending249 and b.total248==9,"new body contact supports actual parry and single reverse/add-two rule")
 w.reset_impact248();w.hero.cancel_guard109()
 metrics.benchmarks=[]
 for pattern in ["stand","walk","orbit"]:
  metrics.benchmarks.append(benchmark257(true,pattern));metrics.benchmarks.append(benchmark257(false,pattern))
 var old=metrics.benchmarks.filter(func(m):return m.version==256 and m.pattern!="stand")
 var fresh=metrics.benchmarks.filter(func(m):return m.version==257 and m.pattern!="stand")
 check(fresh[0].hits+fresh[1].hits>old[0].hits+old[1].hits,"scripted walking and circling receive more real hits than256")
 w.legacy257=false;w.suppress_echo257=false
 w.recording226.folder="user://boss257-validation-records"
 w.toggle_console226();console=w.console226;console.determination257.value=2;console.draft={"eye_exercise":1};console.record226()
 check(w.recording226.active and w.determination_level257==2 and w.player_hp==13.,"record button applies drafted determination level before restarting")
 w.recording226.finish(w,"validation")
 check(w.report_stats226().get("determination_level",0)==2,"recording report retains determination progression snapshot")
 w.commit_progress257({},90.,32.,true,1);b=w.boss247;b.set_physics_process(false)
 check(w.player_hp==12. and w.capacity257()==4 and w.echoes256.is_empty(),"restart restores first-boss baseline and clears projectiles")
 await shot("boss257-hud")
 check(w.stats226.determination_level==1 and w.stats226.capacity==4 and w.stats226.max_determination==12.,"recorded stats snapshot level, health maximum and capacity")
 check(w.console226.has_method("record226") and w.projection250.visible and not b.marker247.visible,"recording console and silhouette/circle defaults retained")
 b.receive_hit(10000.,Vector3.RIGHT);await create_timer(.2).timeout
 check(not w.active114 and w.echoes256.is_empty(),"victory still clears encounter")
 DirAccess.remove_absolute(ProjectSettings.globalize_path("user://boss257-validation.cfg"))
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/boss257-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks,"metrics":metrics},"  "));f.close()
 print("BOSS257_VALIDATION ",ok," checks=",checks.size()," benchmarks=",metrics.benchmarks);quit(0 if ok else 1)
