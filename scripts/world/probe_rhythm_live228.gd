extends "res://scripts/world/validate_rhythm228.gd"
func run() -> void:
 w=TestWorld.new();root.add_child(w);current_scene=w
 while not w.ready228:await process_frame
 w.levels226={};w.start_battle225(false);w.auto114=false;w.pigs_enabled220=true;w.invulnerability=10000.;w.hero.set_physics_process(false)
 w.cat220.receive_hit(1000.,Vector3.ZERO);await create_timer(1.5).timeout
 w.phase_age220=6.1;await settle(3);w.phase_age220=1.3;await settle(3)
 var wall_start=Time.get_ticks_msec()
 while Time.get_ticks_msec()-wall_start<20000:
  await process_frame
 var web=w.events228.filter(func(e):return e.event=="web_start")
 var pigs=w.events228.filter(func(e):return e.event=="pig_drop")
 check(w.active114 and not web.is_empty(),"live second round with pig enabled still gives spider a weaving beat")
 check(not pigs.is_empty(),"live second round retains pig delivery after weaving")
 check(w.pads172.size()<=2,"live overlapping phases stay within two ground webs")
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://docs/rhythm228-live-second.png")
 var failed=checks.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/rhythm228-live.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failed.size(),"events":w.events228.duplicate(true),"rolls":w.cat220.roll_count220,"pig_drops":w.dropped220},"\t"))
 print("RHYTHM228_LIVE ",failed.size()," ",w.events228);w.stop225();quit(0 if failed.is_empty() else 1)
