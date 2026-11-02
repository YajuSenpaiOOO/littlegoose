extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world261.gd"
 func _init() -> void:
  super._init();memory_save116="user://entry261-validation-preview.cfg"
 func test_config_path226() -> String:return "user://entry261-validation.cfg"
 func export_stats226() -> Error:return OK
 func reset_stats226(partial: bool) -> void:
  super.reset_stats226(partial);recording226.folder="user://entry261-validation-records"
 func hurt_player(_damage: float,_from: Vector2) -> void:pass
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while w.entry_navigation261==null or not w.console226.has_method("draft_level257"):await process_frame
 w.auto114=false;w.hero.set_physics_process(false);w.hero.controls_enabled=false
 var b=w.boss247;b.set_physics_process(false);w.set_physics_process(false)
 check(b.hp==90. and w.player_hp==12. and w.capacity257()==4,"accepted boss and initial progression unchanged")
 var old_minion=load("res://scripts/combat/tuantuan_minion260.gd").new();old_minion.battle=w
 b.enter247("flat")
 check(old_minion.rest_with_boss260(),"old260 retains its global rest rule for comparison");old_minion.free()
 var m=w.spawn_minion260()
 check(is_instance_valid(m),"real static clearance and navigation produce an authored entry route")
 if not is_instance_valid(m):print("ENTRY261_PLAN_FAILED");quit(1);return
 var origin=m.position;metrics.entry_name=m.entry_name261;metrics.entry_length=m.entry_length261
 check(m.entry_length261>=2.5 and Vector2(origin.x,origin.z).distance_to(w.meadow.landmarks.grove)>=7.,"entry begins at perimeter with real travel instead of center pop-in")
 await settle(3)
 check(m.state260=="rustle" and not m.visual.visible and m not in w.enemies,"leaf cue precedes hidden noncombat entry body")
 var clock=m.clock260;w.combat_paused=true;await create_timer(.2).timeout
 check(m.clock260==clock,"pause freezes rustle cue and arrival");w.combat_paused=false
 var deadline=Time.get_ticks_msec()+10000;var pictured=false;var metres=0.;var previous=Vector2(origin.x,origin.z)
 while is_instance_valid(m) and m.state260 not in ["ground","dazed"] and Time.get_ticks_msec()<deadline:
  await process_frame
  if not is_instance_valid(m):break
  var at=Vector2(m.position.x,m.position.z);metres+=at.distance_to(previous);previous=at
  if not pictured and m.state260=="arrive" and metres>.8:
   w.combat_paused=true;await shot("entry261-route");w.combat_paused=false;pictured=true
 check(is_instance_valid(m) and m.state260=="ground","minion completes visible hop route without teleporting")
 if not is_instance_valid(m):quit(1);return
 metrics.entry_travel=metres
 check(metres>=2. and pictured,"actual entrance animation covers world-space distance")
 check(not m.rest_with_boss260() and w.minion_attack_allowed260(),"boss recovery no longer freezes or forbids companion attacks")
 # The boss is deliberately held flat to reproduce the old immobility window.
 var start=m.position;var attacks=m.attacks_started;deadline=Time.get_ticks_msec()+4500
 while Time.get_ticks_msec()<deadline and m.attacks_started==attacks:await process_frame
 metrics.recovery_travel=m.position.distance_to(start);metrics.recovery_attacks=m.attacks_started-attacks
 check(m.position.distance_to(start)>.7,"ordinary minion moves naturally while boss remains flat")
 check(m.attacks_started>attacks,"ordinary minion can begin a native attack during boss recovery")
 check(m.projection260.visible and not m.shadow.visible,"moving entry and grounded actor keep a single world shadow")
 w.combat_paused=true;await shot("entry261-grounded");w.combat_paused=false
 # Reset keeps the normal first-chain solo policy; then natural AI drives both entries.
 w.begin251();w.hero.set_physics_process(false);w.hero.controls_enabled=false;w.auto114=false;w.set_physics_process(true)
 b=w.boss247;var capped=true;var deadline2=Time.get_ticks_msec()+45000
 while w.telemetry260.data.physics_seconds<30. and Time.get_ticks_msec()<deadline2:
  await process_frame;capped=capped and w.live_minions260().size()<=3
  var completed=w.telemetry260.data.events.filter(func(e):return e.kind=="entry_complete").size()
  if completed>=2 and w.telemetry260.data.minions.thrown>=1:break
 var events=w.telemetry260.data.events
 check(events.any(func(e):return e.kind=="entry_rustle") and events.filter(func(e):return e.kind=="entry_complete").size()>=2,"natural encounter uses reusable perimeter entries for both companions")
 check(capped and w.telemetry260.data.minions.thrown>=1,"live movement preserves three-member cap and natural boss launch interaction")
 metrics.natural={"seconds":w.telemetry260.data.physics_seconds,"minions":w.telemetry260.data.minions,"entries":events.filter(func(e):return e.kind.begins_with("entry_"))}
 w.combat_paused=true;await shot("entry261-natural");w.combat_paused=false
 w.finish251(false)
 check(w.minions260.is_empty() and w.pending260==0 and w.echoes256.is_empty(),"ending clears cues, route actors and queued entries")
 w.begin251();b=w.boss247;b.set_physics_process(false);w.set_physics_process(false)
 check(w.minions260.is_empty() and w.telemetry260.data.minions.spawned==0,"restart preserves solo opening and clean recording")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/entry261-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks,"metrics":metrics},"  "));f.close()
 print("ENTRY261_VALIDATION ",ok," checks=",checks.size()," metrics=",metrics);quit(0 if ok else 1)
