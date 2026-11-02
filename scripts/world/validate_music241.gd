extends "res://scripts/world/validate_plush220.gd"
class TestWorld:
 extends "res://scripts/world/woodland_world241.gd"
 var aim236 := Vector3.ZERO
 func paper_aim146() -> Vector3:return aim236
 func load_test226() -> void:pass
 func export_stats226() -> Error:return OK
func tap236() -> void:
 var event=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.pressed=true;w._input(event)
func run() -> void:
 var C=preload("res://scripts/combat/music_clock241.gd")
 var c=C.new();c.step(.5,false,true);c.press();c.press()
 check(c.drain().filter(func(e):return e.gain>0.).size()==1,"one immediate Perfect per note")
 c.reset();c.step(.1,false,true);c.press();check(c.drain()[0].kind=="miss_shot","early press immediately emits Miss feedback")
 c.step(.4,false,true);c.press();check(c.drain()[0].kind=="perfect","early press does not reserve or spoil later accurate tap")
 c.reset();c.step(.39,false,true);c.press();check(c.drain()[0].kind=="early","early Good fires immediately")
 c.reset();c.step(.62,false,true);c.press();check(c.drain()[0].kind=="late","late Good fires immediately")
 c.reset();c.step(.661,false,true);check(c.drain()[0].kind=="miss" and c.misses==1,"unplayed note crosses line and becomes Miss")
 c.reset();c.step(.661,true,true);check(c.drain()[0].kind=="auto" and c.perfects==0,"hold distinct auto result")
 c.reset();c.step(3.,true,false);check(c.drain().all(func(e):return e.gain==0. and e.kind=="skip"),"guard skips without shots or Miss penalty")
 c.step(.7,true,true);check(c.drain().filter(func(e):return e.gain>0.).size()==1,"no catch-up volley")
 c.reset();c.time=.39;c.press();check(abs(float(c.drain()[0].gain)-1.2)<.00001,"Great is 1.2x")
 c.reset();c.time=.10
 for i in 12:c.press()
 check(c.last==0 and c.drain().all(func(e):return e.get("ghost239",false) and e.gain==0.),"every early tap is empty shot; no reservation")
 c.time=.5;c.press();check(c.drain()[0].gain==1.4,"Perfect immediately available after missed rapid clicks")
 c.step(.2,true,true);check(c.drain().is_empty(),"manual consumption prevents auto double damage")
 var stats=preload("res://scripts/combat/music_stats240.gd").new()
 for example in [["perfect",-.02],["early",-.11],["late",.12],["miss_shot",-.24],["auto",0.],["miss",0.],["skip",0.]]:
  stats.observe({"kind":example[0],"offset":example[1],"gain":1.,"beat":1},"fight",.5)
 stats.observe({"kind":"miss_shot","offset":0.,"gain":0.,"beat":1,"resolved240":true},"repair",.5)
 var result=stats.report()
 check(result.output_count==6 and result.counts.missed_beat==1 and result.counts.skip==1,"ratio denominator excludes omitted and skipped beats")
 check(result.timing.count==4 and abs(float(result.timing.mean_ms)+62.5)<.001 and result.timing.excluded_resolved_beat_clicks==1,"signed offsets exclude already-resolved spam")
 check(result.by_phase.repair.empty_click==1 and result.timing.histogram.reduce(func(a,b):return a+b,0)==4,"phase counts and histogram are complete")
 check(abs(result.output_ratios.perfect+result.output_ratios.great+result.output_ratios.empty_click+result.output_ratios.auto-1.)<.000001,"output ratios sum to one")
 for i in 2100:stats.observe({"kind":"perfect","offset":0.,"gain":1.4,"beat":i},"fight",.5)
 check(stats.samples.size()==2000 and stats.report().counts.perfect==2101,"raw sample cap preserves aggregate counts")
 c.reset();c.time=.25;c.set_rate241(1.25)
 check(abs(c.period237()-.4)<.00001 and abs(c.time/.4-.5)<.00001,"150 BPM preserves musical phase")
 c.set_rate241(1.5);check(abs(60./c.period237()-180.)<.00001,"second eye level gives 180 BPM")
 var P=preload("res://scripts/combat/balance_profile241.gd")
 check(P.error({"music_class":1,"eye_exercise":1,"three_player":1})=="","music eye geese valid six-slot build")
 check(P.error({"music_class":1,"balloon_sword":1,"paper_plane":1,"eye_exercise":1})=="","six-slot music sword plane eye accepted")
 check(P.error({"music_class":1,"slingshot":1})!="","slingshot explicitly mutually exclusive")
 check(P.error({"music_class":1,"flashlight":1})!="" and P.error({"music_class":2})!="","unadapted weapons and music stacking rejected")
 check(preload("res://scripts/combat/balance_profile226.gd").error({"music_class":1})!="","old preview still blocks music")
 w=TestWorld.new();root.add_child(w);current_scene=w
 while not w.ready228:await process_frame
 await process_frame
 w.start_battle225(false);w.auto114=false;w.pigs_enabled220=false;w.invulnerability=10000.;w.cat220.set_physics_process(false);w.hero.set_physics_process(false);w.cat220.hp=100000.;w.cat220.max_hp110=100000.
 w.aim236=w.cat220.hit_area.global_position
 var found=false
 for dir in [Vector2.LEFT,Vector2.RIGHT,Vector2.DOWN,Vector2.UP]:
  var at=Vector2(w.aim236.x,w.aim236.z)+dir*3.
  if not w.open_drop225(at):continue
  var start=Vector3(at.x,w.floor_height(at)+.55,at.y)
  if w.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(start,w.aim236,1|2,[w.hero.get_rid()])).is_empty():w._teleport15(at);found=true;break
 check(found,"clear real physics line to cat")
 var rows=[]
 var stamp=w.rhythm236.time;w.combat_paused=true;w.advance_music236();check(w.rhythm236.time==stamp,"real clock frozen on pause");w.combat_paused=false
 for levels in [{"music_class":1},{"music_class":1,"eye_exercise":1},{"music_class":1,"three_player":1},{"music_class":1,"snack":1},{"music_class":1,"homework":1}]:
  w._clear_combat_shots();w.levels226=levels;w.apply_levels226();w.hero.reset_actions();w.fire_needs_release=false
  w.fire_at(w.aim236);var reference=0.
  for s in w.shots:reference+=w.damage_for_shot(s)
  var interval=w.attack_cooldown();w._clear_combat_shots()
  var before=w.cat220.hp
  w.rhythm236.step(.661,true,true);w.flush_music236()
  var normal=w.rhythm_damage236
  if levels.has("homework"):
   var saved_budget=0.
   for spec in w.paper_memories146.pages146[-1].specs:saved_budget+=float(spec.damage)
   check(abs(saved_budget-normal)<.00001,"notebook saves normalized music budget")
  check(abs(normal-reference*w.rhythm236.period237()/interval)<.00001,"hold preserves original DPS budget / "+str(levels))
  check(w.shots.all(func(s):return not s.get("note110",false)),"old random music bonus removed")
  await create_timer(.7).timeout
  var hit=w.cat220.hp
  check(before-hit>0.,"normal music really hits cat")
  w._clear_combat_shots();w.reset_music236();w.rhythm236.time=w.rhythm236.period237();tap236()
  var perfect=w.rhythm_damage236
  check(abs(perfect-normal*1.4)<.00001,"real mouse Perfect is exactly 1.4x / "+str(levels))
  if levels.has("homework"):
   var saved_perfect=0.
   for spec in w.paper_memories146.pages146[-1].specs:saved_perfect+=float(spec.damage)
   check(abs(saved_perfect-perfect)<.00001,"notebook saves Perfect bonus exactly once")
  var count=w.shots.size();tap236();check(w.shots.size()==count,"duplicate same-beat input cannot add shot")
  check(w.candy117.text237=="MISS · 此拍已结束","resolved beat feedback does not masquerade as a timing miss")
  w._clear_combat_shots();w.reset_music236();w.rhythm236.time=w.rhythm236.period237()-.11;tap236()
  check(abs(w.rhythm_damage236-normal*1.2)<.00001,"Great actual volley is 1.2x normal")
  rows.append({"levels":levels,"normal":normal,"perfect":perfect,"baseline_dps":reference/interval})
  await create_timer(.7).timeout
 var audio=w.music_audio236
 audio.cursor236=0;audio.note236(20,false);check(audio.cursor236==1,"first emitted attack plays first melody note regardless of beat")
 audio.note236(99,true);check(audio.cursor236==2,"next attack advances one note across idle beat gaps")
 audio.cursor236=7;audio.note236(100,false);check(audio.cursor236==9,"phrase rests do not swallow an emitted note")
 var cursor=audio.cursor236;await create_timer(.6).timeout;check(audio.cursor236==cursor,"idle does not advance melody")
 # Verify empty feedback bypasses physical shots, buffs and damage entirely.
 w._clear_combat_shots();w.reset_music236();w.hero.reset_actions();w.fire_needs_release=false
 w.rhythm236.time=.1
 var hp=w.cat220.hp;var count=w.shots.size();var before_ghost=w.ghosts239
 for i in 8:tap236()
 check(w.ghosts239==before_ghost+8 and w.shots.size()==count and w.cat220.hp==hp,"rapid bad clicks each give feedback without physical damage shots")
 check(w.rhythm236.last==0,"Miss clicks leave next beat unconsumed")
 w.rhythm236.time=w.rhythm236.period237();tap236();check(w.shots.size()>count,"next valid tap fires immediately after Miss spam")
 check(w.candy117.ghosts239.size()<=96,"empty visuals have bounded live storage")
 # Real music sword/plane payloads, immediate note feedback and native damage.
 for levels in [{"music_class":1,"balloon_sword":1},{"music_class":1,"paper_plane":1},{"music_class":1,"paper_plane":1,"balloon_sword":1},{"music_class":1,"paper_plane":1,"balloon_sword":1,"three_player":1}]:
  w._clear_combat_shots();w.levels226=levels;w.apply_levels226();w.hero.reset_actions();w.fire_needs_release=false
  var prior=w.paper_memories146.planes_launched146;var played=w.music_audio236.played236;var hp_before=w.cat220.hp
  w.rhythm236.time=w.rhythm236.period237();tap236()
  check(w.music_audio236.played236==played+1,"one melody note immediately per rhythmic volley / "+str(levels))
  if levels.has("paper_plane"):
   check(w.paper_memories146.planes_launched146>prior and w.rhythm_damage236>0.,"rhythm press launches real planes with damage budget")
   var carried=0.;var swords=true
   for flight in w.paper_memories146.planes149:
    for spec in flight.packet.specs:
     carried+=float(spec.damage)*float(flight.gain)
     if levels.has("balloon_sword"):swords=swords and bool(spec.get("sword153",false))
   check(abs(carried-w.rhythm_damage236)<.00001 and swords,"all plane packets preserve sword identity and resolved budget")
  else:check(w.shots.all(func(s):return s.get("sword153",false)),"direct rhythm sword flags inherited")
  await create_timer(1.6).timeout
  check(w.cat220.hp<hp_before,"adapted combo deals real native damage / "+str(levels))
  if levels.has("balloon_sword"):check(w.swords153.resting153.size()>0,"native sword attachment/control still active")
 w.levels226={"music_class":1};w.apply_levels226()
 # Recording round-trip through the actual 5s checkpoint and final snapshot.
 w.recording226.folder="user://music240_validation_records"
 w.recording226.begin(w,"validation")
 w._clear_combat_shots();w.reset_music236();w.rhythm236.time=w.rhythm236.period237();tap236()
 var sampled=w.report_stats226().music240.recording
 check(sampled.counts.perfect==1 and sampled.counts.empty_click==0,"active recording collects exact events")
 w.recording226.step(w,5.1,"fight")
 var record_path=w.recording226.folder+"/"+w.recording226.id+".json"
 var disk=JSON.parse_string(FileAccess.get_file_as_string(record_path))
 check(disk.music240.recording.counts.perfect==1,"real checkpoint JSON includes rhythm telemetry")
 w.recording226.finish(w,"validation done")
 var frozen=w.report_stats226().music240.recording
 w.rhythm236.time=1.;tap236()
 check(w.report_stats226().music240.recording==frozen,"finished recording keeps rhythm snapshot frozen")
 w.recording226=preload("res://scripts/combat/balance_recording226.gd").new()
 w.reset_music236();check(w.music_stats240.report().output_count==0,"new run clears session telemetry")
 # Console and pause interactions, plus a real screenshot of target-aligned rings.
 w.levels226={"music_class":1};w.apply_levels226();w.hero.reset_actions();w.fire_needs_release=false
 w.target114=w.cat220;w.aim_tick114=Engine.get_physics_frames();w.candy117.previous117=w.cat220.get_instance_id()
 w.rhythm236.time=.35
 w.open_console226() if w.has_method("open_console226") else w.toggle_console226()
 check(w.console226.profile226()==P and not w.console226.rows.music_class.plus.disabled,"console exposes new music card")
 var paused_time=w.rhythm236.time;w._step_fire_input(.2);check(w.rhythm236.time==paused_time,"console pause freezes beat")
 w.close_console226();w.target114=w.cat220;w.auto114=true
 w.last_kind237="perfect";w.last_offset237=0.;w.candy117.hit236(1,true)
 await shot("music241")
 check(w.candy117.note_times237.size()>=2,"multiple future notes visible together")
 check(w.music_audio236.sounds.size()==12 and w.music_audio236.voices.size()==4,"bounded audio voices and both note timbres loaded")
 metrics={"checks":checks,"budgets":rows}
 FileAccess.open("res://docs/music241-validation.json",FileAccess.WRITE).store_string(JSON.stringify(metrics,"\t"))
 print("MUSIC241_VALIDATION ",JSON.stringify(metrics));w.stop225();quit(1 if checks.any(func(c):return not c["pass"]) else 0)
