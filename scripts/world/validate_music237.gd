extends "res://scripts/world/validate_plush220.gd"
class TestWorld:
 extends "res://scripts/world/woodland_world237.gd"
 var aim236 := Vector3.ZERO
 func paper_aim146() -> Vector3:return aim236
 func load_test226() -> void:pass
 func export_stats226() -> Error:return OK
func tap236() -> void:
 var event=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.pressed=true;w._input(event)
func run() -> void:
 var C=preload("res://scripts/combat/music_clock237.gd")
 var c=C.new();c.step(.5,false,true);c.press();c.press()
 check(c.drain().filter(func(e):return e.gain>0.).size()==1,"one immediate Perfect per note")
 c.reset();c.step(.1,false,true);c.press();check(c.drain()[0].kind=="too_early","early press gives immediate error")
 c.step(.4,false,true);c.press();check(c.drain()[0].kind=="perfect","early press does not reserve or spoil later accurate tap")
 c.reset();c.step(.39,false,true);c.press();check(c.drain()[0].kind=="early","early Good fires immediately")
 c.reset();c.step(.62,false,true);c.press();check(c.drain()[0].kind=="late","late Good fires immediately")
 c.reset();c.step(.661,false,true);check(c.drain()[0].kind=="miss" and c.misses==1,"unplayed note crosses line and becomes Miss")
 c.reset();c.step(.661,true,true);check(c.drain()[0].kind=="auto" and c.perfects==0,"hold distinct auto result")
 c.reset();c.step(3.,true,false);check(c.drain().all(func(e):return e.gain==0. and e.kind=="skip"),"guard skips without shots or Miss penalty")
 c.step(.7,true,true);check(c.drain().filter(func(e):return e.gain>0.).size()==1,"no catch-up volley")
 var P=preload("res://scripts/combat/balance_profile235.gd")
 check(P.error({"music_class":1,"eye_exercise":1,"three_player":1})=="","music eye geese valid six-slot build")
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
  check(abs(normal-reference*.5/interval)<.00001,"hold preserves original DPS budget / "+str(levels))
  check(w.shots.all(func(s):return not s.get("note110",false)),"old random music bonus removed")
  await create_timer(.7).timeout
  var hit=w.cat220.hp
  check(before-hit>0.,"normal music really hits cat")
  w._clear_combat_shots();w.reset_music236();w.rhythm236.time=.5;tap236()
  var perfect=w.rhythm_damage236
  check(abs(perfect-normal*1.4)<.00001,"real mouse Perfect is exactly 1.4x / "+str(levels))
  if levels.has("homework"):
   var saved_perfect=0.
   for spec in w.paper_memories146.pages146[-1].specs:saved_perfect+=float(spec.damage)
   check(abs(saved_perfect-perfect)<.00001,"notebook saves Perfect bonus exactly once")
  var count=w.shots.size();tap236();check(w.shots.size()==count,"duplicate same-beat input cannot add shot")
  rows.append({"levels":levels,"normal":normal,"perfect":perfect,"baseline_dps":reference/interval})
  await create_timer(.7).timeout
 var audio=w.music_audio236
 audio.cursor236=0;audio.note236(20,false);check(audio.cursor236==1,"first emitted attack plays first melody note regardless of beat")
 audio.note236(99,true);check(audio.cursor236==2,"next attack advances one note across idle beat gaps")
 audio.cursor236=7;audio.note236(100,false);check(audio.cursor236==9,"phrase rests do not swallow an emitted note")
 var cursor=audio.cursor236;await create_timer(.6).timeout;check(audio.cursor236==cursor,"idle does not advance melody")
 # Console and pause interactions, plus a real screenshot of target-aligned rings.
 w.levels226={"music_class":1};w.apply_levels226();w.hero.reset_actions();w.fire_needs_release=false
 w.target114=w.cat220;w.aim_tick114=Engine.get_physics_frames();w.candy117.previous117=w.cat220.get_instance_id()
 w.rhythm236.time=.35
 w.open_console226() if w.has_method("open_console226") else w.toggle_console226()
 check(w.console226.profile226()==P and not w.console226.rows.music_class.plus.disabled,"console exposes new music card")
 var paused_time=w.rhythm236.time;w._step_fire_input(.2);check(w.rhythm236.time==paused_time,"console pause freezes beat")
 w.close_console226();w.target114=w.cat220;w.auto114=true
 w.last_kind237="perfect";w.last_offset237=0.;w.candy117.hit236(1,true)
 await shot("music237")
 check(w.candy117.note_times237.size()>=2,"multiple future notes visible together")
 check(w.music_audio236.sounds.size()==12 and w.music_audio236.voices.size()==4,"bounded audio voices and both note timbres loaded")
 metrics={"checks":checks,"budgets":rows}
 FileAccess.open("res://docs/music237-validation.json",FileAccess.WRITE).store_string(JSON.stringify(metrics,"\t"))
 print("MUSIC237_VALIDATION ",JSON.stringify(metrics));w.stop225();quit(1 if checks.any(func(c):return not c["pass"]) else 0)
