extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world272.gd"
 func _init() -> void:
  super._init();memory_save116="user://batches272-validation-preview.cfg"
 func test_config_path226() -> String:return "user://batches272-validation.cfg"
 func export_stats226() -> Error:return OK
 func hurt_player(_damage: float,_from: Vector2) -> void:pass
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.ready264:await process_frame
 w.auto114=false;w.ordinary264();w.hero.set_physics_process(false)
 check(w.live_minions260().size()==3 and w.roster264.TOTAL==24,"three ordinary opening actors and twenty-four total")
 var max_live=0;var max_rollers=0;var max_predictors=0;var typed=true;var teaching=true;var pictured=false;var last=Time.get_ticks_msec();var deadline=last+65000
 while w.mode264=="ordinary" and Time.get_ticks_msec()<deadline:
  await physics_frame
  var live=w.live_minions260();max_live=maxi(max_live,live.size())
  var rollers=live.filter(func(m):return m.has_method("enter269"));var predictors=live.filter(func(m):return m.get_meta("kind272","normal")=="predict")
  max_rollers=maxi(max_rollers,rollers.size());max_predictors=maxi(max_predictors,predictors.size())
  if w.roster264.wave==3 and not rollers.is_empty() and not predictors.is_empty():teaching=false
  for m in predictors:
   if not m.flower268 or not m.has_method("bump271"):typed=false
  if w.roster264.wave==5 and rollers.size()==3 and not pictured:
   w.combat_paused=true;await shot("batches272-finale");w.combat_paused=false;pictured=true
  if Time.get_ticks_msec()-last>800:
   var targets=live.filter(func(m):return m.targetable260())
   # Let the final three rollers coexist rather than killing the special entry instantly.
   if w.roster264.wave==5 and rollers.size()<3 and w.roster264.spawned<24:targets=targets.filter(func(m):return not m.has_method("enter269"))
   if not targets.is_empty():targets[0].receive_hit(100.,Vector3.RIGHT);last=Time.get_ticks_msec()
 check(w.mode264=="ready" and w.roster264.defeated==24,"all six batches finish after twenty-four real defeats")
 check(max_live<=5 and max_predictors==1 and max_rollers==3,"population stays bounded while finale admits three rollers")
 check(typed and teaching,"predictor uses real prediction and collision stun; first roller is not mixed with old predictor")
 var actual=[[],[],[],[],[],[]];actual[0]=["normal","normal","normal"]
 for entry in w.admissions272:actual[entry.wave].append(entry.kind)
 check(actual==w.roster264.BATCHES,"every batch admits its exact authored enemy composition")
 var report=w.report_stats226();check(report.encounter265.total==24 and report.encounter272.admissions.size()==21,"capture records six-batch roster and all twenty-one reinforcements")
 w.hero.position=w.boss247.position+Vector3(2.5,0,0);w.boss_unlocked264=true;w.boss264();w.boss247.set_physics_process(false)
 var m=w.spawn_minion260();check(w.mode264=="boss" and m!=null and not m.has_method("enter269") and w.minion_cap261()==3,"Boss challenge remains separate with original ordinary companions")
 w.finish251(false);w.cancel_dialog264();w.yard264()
 check(w.live_minions260().size()==3 and w.pair_until271.is_empty(),"return restores original playground and clears collision pairs")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/batches272-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks,"batches":actual,"max_live":max_live},"  "));f.close()
 print("BATCHES272_VALIDATION ",ok);quit(0 if ok else 1)
