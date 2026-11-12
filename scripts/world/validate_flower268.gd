extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world268.gd"
 func _init() -> void:
  super._init();memory_save116="user://flower268-validation-preview.cfg"
 func test_config_path226() -> String:return "user://flower268-validation.cfg"
 func export_stats226() -> Error:return OK
 func hurt_player(_damage: float,_from: Vector2) -> void:pass
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.ready264:await process_frame
 w.auto114=false;w.ordinary264();w.hero.set_physics_process(false)
 check(w.live_minions260().all(func(m):return not m.flower268),"opening actors are ordinary")
 var deadline=Time.get_ticks_msec()+45000;var kill_at=0;var max_flowers=0;var flowers=[];var tested=false
 while w.mode264=="ordinary" and Time.get_ticks_msec()<deadline:
  await physics_frame
  var live=w.live_minions260();var special=live.filter(func(m):return m.flower268);max_flowers=maxi(max_flowers,special.size())
  for m in special:
   if m.role110 not in flowers:flowers.append(m.role110)
   if not tested and m.state260=="ground":
    tested=true;w.combat_paused=true;m.set_physics_process(false)
    w.hero.velocity=Vector3(4,0,0);var target=Vector2(w.hero.position.x,w.hero.position.z)
    m._begin_windup(target);m.phase_clock=.1;m._update_windup_target(target)
    check(m.predicted268.x>target.x and m.predicted268.distance_to(target)<=2.5,"flower predicts a bounded point ahead of real movement")
    var locked=m.predicted268;m.phase_clock=.25;w.hero.velocity=Vector3(-4,0,0);m._update_windup_target(target+Vector2(-1,0))
    check(m.predicted268==locked,"prediction locks before takeoff and ignores a reversal")
    m._render_legacy(0.);check(m.bloom268==null and m.textures.idle!=w.combat_textures.idle and m.rank110==0,"flower component renders without promoting actor to old elite AI")
    await shot("flower268-windup")
    m.phase_clock=m.WINDUP;m._physics_process(.01);var direction=m.attack_direction
    w.combat_paused=false;m._physics_process(.01);w.hero.position.x-=2.;m._physics_process(.01)
    check(m.attack_direction==direction,"airborne lunge stays straight after player moves")
    check(m.hp==6. and m.touch110==1. and m.collision_layer==16,"special keeps ordinary health damage and collision")
    m.attack_phase="recover";m.phase_clock=0.;m.set_physics_process(true)
  if Time.get_ticks_msec()-kill_at>=650:
   var targets=live.filter(func(m):return m.targetable260() and (not m.flower268 or tested or m.state260=="ground"))
   if not targets.is_empty():targets[0].receive_hit(100.,Vector3.RIGHT);kill_at=Time.get_ticks_msec()
 check(tested and max_flowers==1 and flowers.size()==2,"third and fourth batches each introduce one flower with at most one alive")
 check(w.mode264=="ready" and w.roster264.defeated==15,"all fifteen still clear and unlock the resting boss")
 check(w.report_stats226().flower268.predictions>0,"capture includes special attack counters")
 metrics.flowers=flowers;metrics.counts=w.flower_stats268.duplicate(true)
 w.boss264();w.boss247.set_physics_process(false);var m=w.spawn_minion260()
 check(m!=null and not m.flower268 and w.minion_cap261()==3,"Boss companions remain ordinary")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/flower268-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks,"metrics":metrics},"  "));f.close()
 print("FLOWER268_VALIDATION ",ok);quit(0 if ok else 1)
