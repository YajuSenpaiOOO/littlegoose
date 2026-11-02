extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world263.gd"
 func _init() -> void:
  super._init();memory_save116="user://beam263-validation-preview.cfg"
 func test_config_path226() -> String:return "user://beam263-validation.cfg"
 func export_stats226() -> Error:return OK
var old263: Node2D
func seed263(count: int=44) -> void:
 w._clear_combat_shots();w.stream_generation110+=1;w.stream_last110=w.combat_clock33;w.beam_left110=1.
 var origins=w.skills110.origins110();var direction=Vector3(-.8,0,-.6).normalized()
 for i in count:
  w.emit_stream110(origins[0]+direction*10.)
  var emitters=origins.size()
  for j in emitters:
   var s: Dictionary=w.shots[w.shots.size()-emitters+j]
   s.node.position=origins[j]+direction*(.18+float(count-1-i)*.16);s.node.reset_physics_interpolation();s.velocity=direction*12.5
func compare263() -> Dictionary:
 var old_values=[];var new_values=[]
 for i in 20:
  old263.build_chains110();w.skills110.build_chains110()
  old_values.append(old263.chains110[0].pixel);new_values.append(w.skills110.chains110[0].pixel)
  var s=w.shots.pop_front();w.pool110.retire(s)
 return {"old_min":old_values.min(),"old_max":old_values.max(),"new_min":new_values.min(),"new_max":new_values.max()}
func bench263(renderer: Node2D) -> Dictionary:
 old263.hide();old263.ribbon110.hide();w.skills110.hide();w.skills110.ribbon110.hide()
 renderer.show();renderer.ribbon110.show()
 var micros=[];var draw_calls=[];var frame_us=[];var previous=Time.get_ticks_usec()
 for i in 90:
  var started=Time.get_ticks_usec();renderer._process(1./60.);micros.append(Time.get_ticks_usec()-started)
  await process_frame
  if i>=20:
   draw_calls.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME));frame_us.append(Time.get_ticks_usec()-previous)
  previous=Time.get_ticks_usec()
 micros.sort();frame_us.sort();draw_calls.sort()
 return {"script_us_median":micros[int(micros.size()/2)],"script_us_p95":micros[int(micros.size()*.95)],"whole_scene_draw_calls_median":draw_calls[int(draw_calls.size()/2)],"wall_frame_ms_median":float(frame_us[int(frame_us.size()/2)])/1000.,"wall_frame_ms_p95":float(frame_us[int(frame_us.size()*.95)])/1000.}
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while w.entry_navigation261==null or not is_instance_valid(w.red_beacon263):await process_frame
 w.set_physics_process(false);w.hero.set_physics_process(false);w.hero.controls_enabled=false;w.boss247.set_physics_process(false);w.auto114=false
 w.skills110.set_process(false)
 old263=preload("res://scripts/combat/battle_skills168.gd").new();old263.battle=w;w.skills110.get_parent().add_child(old263);old263.set_process(false);old263.hide();old263.ribbon110.hide()
 w.levels226={"flashlight":1,"eye_exercise":1};w.apply_levels226();w.player_hp=12.
 seed263();var data_before=[]
 for s in w.shots:data_before.append([s.node.position,s.velocity,s.life,w.damage_for_shot(s)])
 w.skills110._process(.016);await settle(2)
 var unchanged=true
 for i in w.shots.size():
  var s=w.shots[i];unchanged=unchanged and data_before[i]==[s.node.position,s.velocity,s.life,w.damage_for_shot(s)]
 check(unchanged,"visual rebuild leaves native projectile positions, lifetime and damage unchanged")
 check(w.skills110.submitted263==w.skills110.chains110.size() and w.skills110.vertices263<=2*27*w.skills110.chains110.size(),"one bounded triangle submission per beam chain")
 metrics.width=compare263()
 check(metrics.width.old_max-metrics.width.old_min>.001,"old far-particle expiration reproduces width variation")
 check(is_equal_approx(metrics.width.new_max,metrics.width.new_min),"new beam width is stable as oldest particles expire")
 seed263();var baseline=w.flashlight_damage_gain110();w.player_hp=3.
 check(baseline==.7 and w.flashlight_damage_gain110()==1.4 and w.flashlight_rate_gain110()==1.,"262 normal red damage and fire cadence retained")
 w._process(.07);w.skills110._process(.07);w.red_beacon263._process(0.);w.encounter_hud.timer229._process(0.)
 check(w.encounter_hud.timer229.visible and w.red_beacon263.visible,"red state enables health warning and world-space beacon")
 check(is_equal_approx(w.encounter_hud.timer229.pulse263,w.red_pulse263()),"HUD and hero share one pulse clock")
 var clock=w.red_clock263;var flow=w.skills110.beam_clock263
 w.combat_paused=true;w._process(.4);w.skills110._process(.4)
 check(w.red_clock263==clock and w.skills110.beam_clock263==flow,"pause freezes both danger rhythm and beam flow")
 await shot("beam263-red")
 w.combat_paused=false;w.player_hp=4.;w._process(0.);w.red_beacon263._process(0.);w.encounter_hud.timer229._process(0.)
 check(not w.red_beacon263.visible and not w.encounter_hud.timer229.visible,"healing to exact third clears warning and beacon")
 w.player_hp=12.;seed263();w.skills110._process(.016);await shot("beam263-normal")
 # Discontinuous native fragments must not join across missing projectile ranges.
 for i in 5:var s=w.shots.pop_at(12);w.pool110.retire(s)
 w.skills110.build_chains110();check(w.skills110.chains110.size()>=2,"sequence gaps retain separate beam segments")
 w._clear_combat_shots();w.skills110._process(0.);await settle(2)
 check(w.skills110.chains110.is_empty() and w.skills110.submitted263==0,"release and clear leave no phantom ribbon")
 metrics.performance=[]
 for stress in [false,true]:
  w.levels226={"flashlight":1,"three_player":1,"forest_fireboy":1,"eye_exercise":1} if stress else {"flashlight":1,"eye_exercise":1}
  w.apply_levels226();seed263();var shots=w.shots.size()
  var old=await bench263(old263);var current=await bench263(w.skills110)
  metrics.performance.append({"stress_only_over_four_slots":stress,"shots":shots,"old":old,"current":current,"ribbon_submissions":w.skills110.submitted263,"ribbon_vertices":w.skills110.vertices263})
 check(metrics.performance.all(func(m):return m.current.script_us_median<m.old.script_us_median),"same-shot comparison reduces median ribbon script work in single and four-emitter stress cases")
 old263.hide();old263.ribbon110.hide();w.skills110.show();w.skills110.ribbon110.show()
 w.levels226={"flashlight":1,"eye_exercise":1};w.apply_levels226();w.player_hp=3.;w._process(.07)
 w.finish251(false);w.red_beacon263._process(0.);w.encounter_hud.timer229._process(0.)
 check(not w.red_beacon263.visible and not w.encounter_hud.timer229.visible and w.shots.is_empty(),"ending removes warning and shots")
 w.begin251();w.boss247.set_physics_process(false);w.hero.set_physics_process(false)
 check(w.red_clock263==0. and w.player_hp==12.,"restart resets danger clock and full determination")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/beam263-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks,"metrics":metrics},"  "));f.close()
 print("BEAM263_VALIDATION ",ok," checks=",checks.size()," metrics=",metrics);quit(0 if ok else 1)
