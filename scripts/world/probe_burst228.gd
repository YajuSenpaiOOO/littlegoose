extends "res://scripts/world/validate_rhythm228.gd"
func run() -> void:
 w=TestWorld.new();root.add_child(w);current_scene=w
 while not w.ready228:await process_frame
 w.levels226={"three_player":1,"eye_exercise":1,"hero_moment":1};w.start_battle225(false);w.auto114=false;w.pigs_enabled220=false;w.invulnerability=10000.;w.cat220.set_physics_process(false);w.hero.set_physics_process(false)
 w.cat220.receive_hit(1000.,Vector3.ZERO);await create_timer(1.5).timeout
 var activated=w.moment161.request161();w.auto114=true
 for i in 9:
  await create_timer(1.).timeout
  print("BURST228 ",i," active=",w.active114," phase=",w.battle_phase220," hp=",w.bats220[0].hp,"/",w.bats220[1].hp," stage=",w.moment161.left161," rate=",w.buffs.rate()," selected=",w.target114," auto=",w.auto114)
  if not w.active114:break
 metrics.burst={"activated":activated,"result":w.stats226.result,"windows":w.stats226.windows.duplicate(true),"current_window":w.window226.duplicate(true),"phase":w.battle_phase220,"bat_hp":[w.bats220[0].hp,w.bats220[1].hp]}
 FileAccess.open("res://docs/burst228-probe.json",FileAccess.WRITE).store_string(JSON.stringify(metrics,"\t"))
 quit()
