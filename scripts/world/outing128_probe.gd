extends "res://scripts/world/combat111_probe.gd"
class Sample:
 extends "res://scripts/world/woodland_world128.gd"
 var shooting128 := false
 func fire_input_held() -> bool: return shooting128
func run() -> void:
 var s := Sample.new();s.memory_save116="user://outing128_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not is_instance_valid(s.drops120): await physics_frame
 s.start_combat();disable_enemies(s);s.hero.set_physics_process(false)
 var a: CharacterBody3D=s.enemies[0];var b: CharacterBody3D=s.enemies[1]
 a.play119();b.play119();a.set_physics_process(false);b.set_physics_process(false)
 verify(a.phase_clock!=b.phase_clock,"actors begin on distinct local timings")
 s.next_attack33=INF
 verify(s.reserve_attack(a) and s.reserve_attack(b),"timing variation does not restore shared attack limits")
 var target := b.position
 a.position=target+Vector3(-.5,0,0);b.velocity=Vector3.ZERO
 verify(not a.peer_contact123(target+Vector3(-.52,0,0)),"already overlapping actors do not start a quarrel")
 a.position=target+Vector3(-.5,0,.6)
 verify(not a.peer_contact123(target+Vector3(-.9,0,.6)),"side brushes do not start a quarrel")
 a.position=target+Vector3(-.5,0,0)
 b.velocity=Vector3(.4/a.get_physics_process_delta_time(),0,0)
 verify(not a.peer_contact123(target+Vector3(-.9,0,0)),"actors travelling together do not quarrel from mere proximity")
 b.velocity=Vector3.ZERO
 verify(a.peer_contact123(target+Vector3(-.9,0,0)) and a.play_state123=="cheer" and b.play_state123=="cheer","a fast direct body impact still initiates the shared quarrel")
 a.clear_play123();b.clear_play123()
 verify(a.peer_cooldown123>=5. and a.peer_cooldown123<=7.,"post-quarrel calm period prevents immediate chains")
 a.peer_cooldown123=0.;b.peer_cooldown123=0.;a.begin_quarrel123(b);b.begin_quarrel123(a)
 a.play_state123="shove";a.play_clock123=2.08;a._step_play123(.03)
 verify(a.play_state123=="","shorter quarrels return an actor to player pressure")
 var hero: CharacterBody3D=s.hero
 s.buffs.levels.clear();s.buffs.apply("slingshot")
 verify(absf(s.charge_time()-1.1)<.001,"base slingshot now requires 1.1 seconds")
 s.charge_active=false;var normal: float=hero.movement_speed()
 s.charge_active=true;s.charge_age=.8
 verify(absf(hero.movement_speed()/normal-.6)<.001,"charging reduces walking speed to sixty percent")
 hero.controls_enabled=true;hero.dash_cd=0.;hero.dash_left=0.;hero.guarding109=false
 var accepted: bool=hero.request_dash(Vector2.RIGHT)
 verify(accepted and not s.charge_active and s.charge_age==0.,"successful dodge remains available but cancels charge")
 s.shooting128=true;s._step_fire_input(.2)
 verify(not s.charge_active,"holding fire cannot recharge during a dodge")
 hero.dash_left=0.;s.cooldown=0.;s._step_fire_input(.1)
 verify(s.charge_active and s.charge_age<=.101,"held fire restarts a fresh charge after the dodge")
 s._cancel_charge();s.shooting128=false
 verify(absf(hero.movement_speed()-normal)<.001,"normal walking returns after charge cancellation")
 var data := {"checks":checks,"failures":failures}
 FileAccess.open("res://docs/outing128-validation.json",FileAccess.WRITE).store_string(JSON.stringify(data,"\t"))
 s.home116();await settle72(2);DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116))
 print("OUTING128_DONE ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
