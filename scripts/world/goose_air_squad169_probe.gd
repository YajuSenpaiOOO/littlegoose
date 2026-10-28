extends "res://scripts/world/goose_train168_probe.gd"
class Trial169:
 extends "res://scripts/world/woodland_world169.gd"
 func _hero_script() -> Script: return Walker160
 func fire_input_held() -> bool: return false
 func hitstop(_duration: float,_force := false) -> void: pass
func capture169(tag: String) -> void:
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/goose_air_squad169_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial169.new();s.memory_save116="user://squad169_probe_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.arc_shadows167): await physics_frame
 s.hill_visited136=true;s.trial152=true;s.paper_trial129=false;s.start_combat();disable_enemies(s);s.clear_standby119();s.hero.controls_enabled=true
 var grove: Vector2=s.meadow.landmarks.grove;s._teleport15(grove+Vector2(0.,4.));await settle72(8)
 for enemy in s.enemies: enemy.hide();enemy.hit_area.collision_layer=0
 s.set_physics_process(false);s.hero.set_physics_process(false)
 s.build169=1;s.apply_paper_build129()
 var aim: Vector3=s.hero.position+Vector3(-1.,0.,-4.);aim.y=s.floor_height(Vector2(aim.x,aim.z))+.05
 var manager: Node3D=s.paper_memories146;var origins: Array[Vector3]=s.skills110.origins110()
 s.fire_at(aim)
 verify(manager.planes149.size()==3,"one ordinary attack launches one aircraft from each of three geese")
 verify(manager.pages146.size()==1,"notebook records one attack round rather than three aircraft")
 var budget: float=total168(manager.pages146[0]);var sum := 0.
 for i in manager.planes149.size():
  var flight: Dictionary=manager.planes149[i];sum+=total168(flight.packet)
  verify(flight.goose_source169==i and flight.route.get_point_position(0).distance_to(origins[i])<.001,"aircraft starts at owning goose muzzle "+str(i))
  verify(flight.packet.specs.all(func(spec: Dictionary) -> bool: return spec.goose_source168==i),"aircraft carries only its own goose payload "+str(i))
  verify(is_equal_approx(flight.source_interval169,s.attack_cooldown()),"aircraft cadence metadata follows owner rate "+str(i))
 verify(is_equal_approx(sum,budget),"splitting aircraft does not duplicate the combined payload budget")
 var main: Dictionary=manager.planes149[0];var copy: Dictionary=manager.planes149[1]
 verify(is_equal_approx(total168(copy.packet),total168(main.packet)*.4),"copy aircraft payload is forty percent of main aircraft")
 verify(absf(copy.packet.specs[0].angle)<.01,"separate carrier removes emitter-position angle without removing real spread")
 manager.step146(.35);await capture169("three_departures")
 for flight in manager.planes149: manager.drop150(flight,0)
 verify(s.shots.size()==3,"first pass releases one current projectile from each aircraft")
 verify(is_equal_approx(s.damage_for_shot(s.shots[1]),s.damage_for_shot(s.shots[0])*.4),"actual dropped projectiles retain owner scaling exactly once")
 s._clear_combat_shots();s.build169=4;s.apply_paper_build129();s.fire_at(aim)
 verify(manager.planes149.size()==3 and manager.planes149.all(func(f: Dictionary) -> bool: return f.packet.specs[0].sword153),"three independent aircraft retain balloon-sword payload")
 manager.step146(1.2);await capture169("sword_squad")
 s._clear_combat_shots();s.build169=3;s.apply_paper_build129();s.capture146(aim,true,1.)
 verify(manager.planes149.size()==2 and manager.planes149[0].packet.specs[0].charged and is_equal_approx(total168(manager.planes149[1].packet),total168(manager.planes149[0].packet)*.4),"charged aircraft also separate and preserve forty-percent payload")
 s._clear_combat_shots();s.build169=1;s.apply_paper_build129();var interval: float=s.attack_cooldown()
 s.build169=7;s.apply_paper_build129();s.fire_at(aim)
 verify(is_equal_approx(s.attack_cooldown(),interval/1.5) and manager.planes149.all(func(f: Dictionary) -> bool: return is_equal_approx(f.source_interval169,s.attack_cooldown())),"fire-rate buff accelerates each goose aircraft cadence normally")
 verify(manager.planes149.all(func(f: Dictionary) -> bool: return is_equal_approx(f.source_rate169,1.5) and f.spacing*1.5>=.0449 and f.spacing*1.5<=.0601),"owner fire rate also speeds six-drop spacing while preserving six-shot budget")
 var before: int=manager.planes149.size();var records: int=manager.records146
 var saved: Dictionary=manager.pages146[0].duplicate(true)
 manager.launch146(saved,s.projectile_origin(),aim,.45,true)
 verify(manager.planes149.size()==before*2 and manager.records146==records,"notebook replay launches the whole saved squad without recursive recording")
 verify(is_equal_approx(total168(manager.planes149[-1].packet),total168(saved)*(.4/1.4)),"replay retains copy payload before its separate forty-five-percent replay gain")
 s._clear_combat_shots();s.build169=2;s.apply_paper_build129();s.fire_at(aim)
 verify(manager.planes149.size()==4,"boarding launches four aircraft for four geese")
 manager.step146(.4);await capture169("boarding_four")
 s.combat_paused=true;var age: float=manager.planes149[0].age;manager.step146(.5)
 verify(manager.planes149[0].age==age,"pause freezes every aircraft")
 s.combat_paused=false;s._clear_combat_shots();verify(manager.planes149.is_empty(),"cleanup removes entire squad")
 s.hero.set_physics_process(true);s.set_physics_process(true)
 await key153(KEY_F4);await settle72(3);disable_enemies(s);await key153(KEY_7)
 verify(s.paper_trial129 and s.build169==6 and s.skills110.geese110.size()==3,"paper encounter and four-goose train squad preset keys work")
 await key153(KEY_F5);await settle72(3);disable_enemies(s);await key153(KEY_9)
 verify(not s.paper_trial129 and s.skills110.geese110.is_empty(),"single-goose native comparison remains available")
 var report := {"checks":checks,"failures":failures,"note":"Per-emitter departure, payload conservation, real drops, charge/sword/notes/rate and lifecycle; current copy rate equals main rate."}
 FileAccess.open("res://docs/goose-air-squad169-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("SQUAD169_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
