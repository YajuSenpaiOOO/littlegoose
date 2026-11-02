extends "res://scripts/world/validate_plush220.gd"
class TestWorld:
 extends "res://scripts/world/woodland_world235.gd"
 var aim235 := Vector3.ZERO
 func paper_aim146() -> Vector3:return aim235
 func load_test226() -> void:pass
 func export_stats226() -> Error:return OK
func tap235() -> void:
 var event=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.pressed=true;w._input(event)
func run() -> void:
 var C=preload("res://scripts/combat/music_clock235.gd")
 var c=C.new();c.step(.5,false,true);c.press();c.press()
 check(c.drain().size()==1 and c.perfects==1,"fresh perfect press fires once per beat")
 c.reset();c.step(.1,false,true);c.press();c.step(.4,false,true);c.press();c.step(.081,false,true)
 var events=c.drain();check(events.size()==1 and not events[0].perfect,"early spam locks normal, cannot reroll")
 c.reset();c.step(.581,true,true);check(c.drain().size()==1 and c.perfects==0,"hold creates normal only")
 c.reset();c.step(3.,true,false);check(c.drain().is_empty(),"guard or dodge skips beats")
 c.step(.6,true,true);check(c.drain().size()==1,"hitch never creates catch-up volley")
 var P=preload("res://scripts/combat/balance_profile235.gd")
 check(P.error({"music_class":1,"eye_exercise":1,"three_player":1})=="","music eye geese valid six-slot build")
 check(P.error({"music_class":1,"flashlight":1})!="" and P.error({"music_class":2})!="","unadapted weapons and music stacking rejected")
 check(preload("res://scripts/combat/balance_profile226.gd").error({"music_class":1})!="","old preview still blocks music")
 w=TestWorld.new();root.add_child(w);current_scene=w
 while not w.ready228:await process_frame
 await process_frame
 w.start_battle225(false);w.auto114=false;w.pigs_enabled220=false;w.invulnerability=10000.;w.cat220.set_physics_process(false);w.hero.set_physics_process(false);w.cat220.hp=100000.;w.cat220.max_hp110=100000.
 w.aim235=w.cat220.hit_area.global_position
 var found=false
 for dir in [Vector2.LEFT,Vector2.RIGHT,Vector2.DOWN,Vector2.UP]:
  var at=Vector2(w.aim235.x,w.aim235.z)+dir*3.
  if not w.open_drop225(at):continue
  var start=Vector3(at.x,w.floor_height(at)+.55,at.y)
  if w.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(start,w.aim235,1|2,[w.hero.get_rid()])).is_empty():w._teleport15(at);found=true;break
 check(found,"clear real physics line to cat")
 var rows=[]
 var stamp=w.rhythm235.time;w.combat_paused=true;w.advance_music235();check(w.rhythm235.time==stamp,"real clock frozen on pause");w.combat_paused=false
 for levels in [{"music_class":1},{"music_class":1,"eye_exercise":1},{"music_class":1,"three_player":1},{"music_class":1,"snack":1},{"music_class":1,"homework":1}]:
  w._clear_combat_shots();w.levels226=levels;w.apply_levels226();w.hero.reset_actions();w.fire_needs_release=false
  w.fire_at(w.aim235);var reference=0.
  for s in w.shots:reference+=w.damage_for_shot(s)
  var interval=w.attack_cooldown();w._clear_combat_shots()
  var before=w.cat220.hp
  w.rhythm235.step(.581,true,true);w.flush_music235()
  var normal=w.rhythm_damage235
  if levels.has("homework"):
   var saved_budget=0.
   for spec in w.paper_memories146.pages146[-1].specs:saved_budget+=float(spec.damage)
   check(abs(saved_budget-normal)<.00001,"notebook saves normalized music budget")
  check(abs(normal-reference*.5/interval)<.00001,"hold preserves original DPS budget / "+str(levels))
  check(w.shots.all(func(s):return not s.get("note110",false)),"old random music bonus removed")
  await create_timer(.7).timeout
  var hit=w.cat220.hp
  check(before-hit>0.,"normal music really hits cat")
  w._clear_combat_shots();w.reset_music235();w.rhythm235.time=.5;tap235()
  var perfect=w.rhythm_damage235
  check(abs(perfect-normal*1.4)<.00001,"real mouse Perfect is exactly 1.4x / "+str(levels))
  if levels.has("homework"):
   var saved_perfect=0.
   for spec in w.paper_memories146.pages146[-1].specs:saved_perfect+=float(spec.damage)
   check(abs(saved_perfect-perfect)<.00001,"notebook saves Perfect bonus exactly once")
  var count=w.shots.size();tap235();check(w.shots.size()==count,"duplicate same-beat input cannot add shot")
  rows.append({"levels":levels,"normal":normal,"perfect":perfect,"baseline_dps":reference/interval})
  await create_timer(.7).timeout
 # Console and pause interactions, plus a real screenshot of target-aligned rings.
 w.levels226={"music_class":1};w.apply_levels226();w.hero.reset_actions();w.fire_needs_release=false
 w.target114=w.cat220;w.aim_tick114=Engine.get_physics_frames();w.candy117.previous117=w.cat220.get_instance_id()
 w.rhythm235.time=.35
 w.open_console226() if w.has_method("open_console226") else w.toggle_console226()
 check(w.console226.profile226()==P and not w.console226.rows.music_class.plus.disabled,"console exposes new music card")
 var paused_time=w.rhythm235.time;w._step_fire_input(.2);check(w.rhythm235.time==paused_time,"console pause freezes beat")
 w.close_console226();w.target114=w.cat220;w.auto114=true
 await shot("music235")
 check(w.music_audio235.sounds.size()==12 and w.music_audio235.voices.size()==4,"bounded audio voices and both note timbres loaded")
 metrics={"checks":checks,"budgets":rows}
 FileAccess.open("res://docs/music235-validation.json",FileAccess.WRITE).store_string(JSON.stringify(metrics,"\t"))
 print("MUSIC235_VALIDATION ",JSON.stringify(metrics));w.stop225();quit(1 if checks.any(func(c):return not c["pass"]) else 0)
