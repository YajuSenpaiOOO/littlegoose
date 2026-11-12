extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world271.gd"
 func _init() -> void:
  super._init();memory_save116="user://mixed271-validation-preview.cfg"
 func test_config_path226() -> String:return "user://mixed271-validation.cfg"
 func export_stats226() -> Error:return OK
 func hurt_player(_damage: float,_from: Vector2) -> void:pass
func place271(m: Node,offset: Vector2) -> void:
 m.set_physics_process(false);var at=w.meadow.landmarks.grove+offset
 m.position=Vector3(at.x,w.floor_height(at)+.03,at.y);m.velocity=Vector3.ZERO;m.impulse=Vector2.ZERO;m.bump_left271=0.;m.reset_physics_interpolation()
func until271(predicate: Callable) -> void:
 var deadline=Time.get_ticks_msec()+1800
 while not predicate.call() and Time.get_ticks_msec()<deadline:await physics_frame
func roll271(m: Node,direction: Vector2) -> void:
 m.enter269("charge");m.direction269=direction;m.enter269("rolling");m.set_physics_process(true)
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.ready264:await process_frame
 w.auto114=false;w.ordinary264();w.hero.set_physics_process(false)
 var actors=w.live_minions260();var a=actors[0];var b=actors[1];var c=actors[2];var d=actors[3]
 check(actors.size()==4 and a.has_method("enter269") and b.has_method("enter269") and not c.has_method("enter269") and not d.has_method("enter269"),"two rollers and two ordinary actors")
 for i in actors.size():place271(actors[i],Vector2(-5.+i*3.,-5.))
 place271(a,Vector2(-1.5,0));place271(c,Vector2.ZERO);await settle(3);roll271(a,Vector2.RIGHT)
 await until271(func():return w.mixed_stats271.ordinary_bumps>0)
 check(w.mixed_stats271.ordinary_bumps==1 and c.bump_left271>0. and a.direction269.x<0.,"real actor contact bumps ordinary and reflects roller")
 check(c.hp==6. and a.hp==6.,"peer collision does not deal enemy health damage")
 var count=w.mixed_stats271.ordinary_bumps;w.actor_collision271(a,c,Vector2.LEFT)
 check(w.mixed_stats271.ordinary_bumps==count,"same pair contact is debounced")
 c.set_physics_process(true);var start=c.position;await create_timer(.2).timeout
 check(c.position.distance_to(start)>.1,"ordinary knockback actually moves through native physics")
 w.combat_paused=true;var clock=c.bump_left271;await create_timer(.15).timeout
 check(c.bump_left271==clock,"pause freezes collision stun")
 w.combat_paused=false
 for i in actors.size():place271(actors[i],Vector2(-5.+i*3.,-5.))
 w.pair_until271.clear();place271(a,Vector2(-1.2,0));place271(b,Vector2(1.2,0));await settle(3)
 roll271(a,Vector2.RIGHT);roll271(b,Vector2.LEFT)
 await until271(func():return w.mixed_stats271.head_ons>0)
 check(w.mixed_stats271.head_ons==1 and a.roll_state269=="dizzy" and b.roll_state269=="dizzy","native opposing rollers stop and both become dizzy")
 await create_timer(.15).timeout
 check(a.position.distance_to(b.position)>1.,"head-on rollers physically separate")
 w.combat_paused=true;w.hero.position=a.position+Vector3(2.,0,3.);w._update_camera(0.,true);await shot("mixed271-head-on");w.combat_paused=false
 for i in actors.size():place271(actors[i],Vector2(-5.+i*3.,-5.))
 w.pair_until271.clear();place271(a,Vector2(-1.2,0));place271(b,Vector2(0,1.2));await settle(3)
 roll271(a,Vector2.RIGHT);roll271(b,Vector2.UP)
 await until271(func():return w.mixed_stats271.glances>0)
 check(w.mixed_stats271.glances==1 and a.roll_state269=="rolling" and b.roll_state269=="rolling","perpendicular rolling contact redirects both without head-on stun")
 check(a.direction269!=Vector2.RIGHT and b.direction269!=Vector2.UP,"both rolling directions change on glancing impact")
 check(w.roller_stats269.bounces==0,"peer bounces are recorded separately from scenery")
 var report=w.report_stats226();check(report.mixed271.head_ons==1 and report.encounter265.total==4,"capture distinguishes mixed trial and collision types")
 for actor in actors:actor.receive_hit(100.,Vector3.RIGHT)
 await settle(5)
 check(w.mode264=="ready" and w.roster264.defeated==4,"four real defeats finish the mixed trial")
 w.yard264();check(w.live_minions260().size()==4 and w.actor_slot271==4,"retry restores exactly four actors and clears pair state")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/mixed271-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks},"  "));f.close()
 print("MIXED271_VALIDATION ",ok);quit(0 if ok else 1)
