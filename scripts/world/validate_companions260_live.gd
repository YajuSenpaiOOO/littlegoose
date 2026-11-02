extends "res://scripts/world/validate_plush220.gd"
class Live:
 extends "res://scripts/world/woodland_world260.gd"
 func _init() -> void:
  super._init();memory_save116="user://companions260-live-preview.cfg"
 func test_config_path226() -> String:return "user://companions260-live.cfg"
 func export_stats226() -> Error:return OK
func run() -> void:
 w=Live.new();root.add_child(w);current_scene=w
 while not w.ready251 or not w.console226.has_method("draft_level257"):await process_frame
 w.hero.set_physics_process(false);w.hero.controls_enabled=false;w.auto114=false;w.invulnerability=1000.
 var pictured=false;var capped=true;var deadline=Time.get_ticks_msec()+45000
 while w.telemetry260.data.physics_seconds<30. and Time.get_ticks_msec()<deadline:
  await process_frame
  capped=capped and w.live_minions260().size()<=3
  if not pictured and w.live_minions260().any(func(m):return m.state260=="air"):
   w.combat_paused=true
   w.time55.preview_at(12.);w.time55.visual_hour=12.;w.time55.apply_look();await shot("companions260-live-day")
   check(w.live_minions260().all(func(m):return is_instance_valid(m.projection260) and not m.shadow.visible),"natural companions retain one world silhouette shadow")
   w.time55.preview_at(22.);w.time55.visual_hour=22.;w.time55.apply_look();await shot("companions260-live-night")
   w.time55.preview_at(12.);w.time55.visual_hour=12.;w.time55.apply_look();w.combat_paused=false;pictured=true
  if pictured and w.telemetry260.data.boss.chains>=2 and w.telemetry260.data.minions.thrown>=2:break
 check(w.telemetry260.data.minions.spawned>=2,"real running fight spawns companions without manual phase changes")
 check(w.telemetry260.data.boss.chains>=2 and w.telemetry260.data.minions.thrown>=1,"ordinary live AI naturally reaches boss landing launch interaction")
 check(pictured and capped,"day/night live snapshots captured with at most three companions")
 var data=w.telemetry260.snapshot(w)
 metrics={"seconds":data.physics_seconds,"boss_chains":data.boss.chains,"minions":data.minions,"parries":data.parries}
 w.finish251(false)
 check(w.minions260.is_empty() and w.echoes256.is_empty() and w.pending260==0,"natural encounter shutdown clears all participants")
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/companions260-live-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks,"metrics":metrics},"  "));f.close()
 print("COMPANIONS260_LIVE ",ok," checks=",checks.size()," metrics=",metrics);quit(0 if ok else 1)
