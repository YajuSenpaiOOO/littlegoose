extends "res://scripts/world/paper_memories146_probe.gd"
class Trial149:
 extends "res://scripts/world/woodland_world149.gd"
 var aim149 := Vector3.ZERO
 var held149 := false
 func _hero_script() -> Script: return Walker146
 func fire_input_held() -> bool: return held149
 func paper_aim146() -> Vector3: return aim149
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func capture149(tag: String) -> void:
 if "--capture149" in OS.get_cmdline_user_args():
  var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/paper_bomb149_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial149.new();s.memory_save116="user://bomb149_probe_tmp.cfg";root.add_child(s)
 while not s.hill_ready146: await physics_frame
 s.hill_visited136=true;s.paper_trial129=true;s.start_combat();disable_enemies(s);s.hero.controls_enabled=true
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(-24,-17));await settle72(5)
 for enemy in s.enemies: enemy.hide();enemy.hit_area.collision_layer=0
 var target: CharacterBody3D=s.enemies[0];target.show();target.hit_area.collision_layer=8;target.hp=10000.;target.max_hp110=10000.
 target.position=s.hero.position+Vector3(0,0,-4);target.position.y=s.floor_height(Vector2(target.position.x,target.position.z))+.06;s.rebuild_cells110()
 # Keep pose timers running while AI stays disabled; repeated frozen hit poses
 # otherwise accumulate temporary art lift and invalidate later height checks.
 target.set_physics_process(true)
 var mark := target.position;mark.y=s.floor_height(Vector2(mark.x,mark.z))+.05;s.aim149=mark
 var m: Node3D=s.paper_memories146;m.flight_rng146.seed=149
 set146(s,{"paper_plane":1,"homework":1})
 var picked: Vector3=s.ground_aim149(s.camera.unproject_position(mark))
 verify(picked.distance_to(mark)<.2,"ground ray selects the clicked terrain point rather than an enemy aim-assist target")
 var hp: float=target.hp;s.fire_at(mark)
 verify(m.planes149.size()==1 and m.planes149[0].mark.distance_to(mark)<.01 and s.shots.is_empty(),"throw immediately creates a fixed ground mark and plane without direct projectile damage")
 var f: Dictionary=m.planes149[0]
 var overhead: Vector3=m.point149(f,float(f.approach)+float(f.pass_time)*.5)
 verify(Vector2(overhead.x-mark.x,overhead.z-mark.z).length()<.001 and overhead.y-mark.y>4.,"random approach is guaranteed to pass directly over the mark at high altitude")
 var wait := 0
 while m.history149.is_empty() and wait<120: await settle72(1);wait+=1
 await capture149("flyover")
 verify(target.hp==hp and not m.history149.is_empty(),"visible airborne bombs fall before any ground-impact damage")
 await settle72(95);await capture149("impact")
 var locked: bool=m.history149.size()==3
 for event in m.history149: locked=locked and Vector3(event.mark).distance_to(mark)<.001
 verify(locked and m.impacts149==3 and target.hp<hp,"one plane delivers exactly three delayed area hits at its original mark")
 verify(m.pages146.size()==1,"all three impacts remain one recorded classroom-note attack")
 await settle72(45);verify(m.planes149.is_empty() and m.bombs149.is_empty(),"planes and markers retire after their finite air time")
 set146(s,{"paper_plane":1,"homework":1});m.history149.clear()
 for i in 8: s.fire_at(mark+Vector3(i*.2,0,0))
 verify(m.planes149.size()==8 and m.pages146.size()==3,"eight requested planes coexist without a three-plane cap")
 var variants := {}
 for plane in m.planes149: variants[str(plane.c1)+str(plane.approach)]=true
 verify(variants.size()==8,"different orders vary the natural approach while retaining their own marks")
 var normal: float=s.attack_cooldown();s.buffs.levels.eye_exercise=2
 verify(is_equal_approx(normal,1.2) and s.attack_cooldown()<normal and is_equal_approx(normal*3.,m.AIRTIME149),"base air time is divided by three to set launch cadence; attack speed increases fleet size")
 m.request146();await settle72(75)
 verify(m.pending146.is_empty() and m.planes149.size()>=11,"notebook copies launch on top of the fleet without waiting for plane slots")
 var age: float=m.planes149[0].age;s.combat_paused=true;await settle72(10)
 verify(is_equal_approx(m.planes149[0].age,age),"pause freezes high flights and bomb timers")
 s.combat_paused=false;s._clear_combat_shots()
 verify(m.planes149.is_empty() and m.bombs149.is_empty() and not m.pending_mark149.is_finite(),"reset clears planes, bombs, fixed markers and buffered marker feedback")
 # Held-fire integration: compare steady state, not direct test calls.
 set146(s,{"paper_plane":1,"homework":1});s.cooldown=0.;s.fire_needs_release=false;s.held149=true
 var base_peak := 0
 for i in 300: await settle72(1);base_peak=maxi(base_peak,m.planes149.size())
 s.held149=false
 verify(base_peak>=3 and base_peak<=4,"holding fire at the initial rate sustains roughly three planes")
 set146(s,{"paper_plane":1,"homework":1,"eye_exercise":2});s.cooldown=0.;s.held149=true
 var fast_peak := 0
 for i in 300: await settle72(1);fast_peak=maxi(fast_peak,m.planes149.size())
 s.held149=false;await capture149("fleet")
 verify(fast_peak>base_peak,"higher attack speed really creates a larger airborne bombing fleet")
 set146(s,{"paper_plane":1,"homework":1,"slingshot":1});var charge_hp: float=target.hp
 s._release_charged(mark,1.);var packet: Dictionary=m.planes149[0].packet
 verify(packet.specs[0].charged and packet.specs[0].damage>1.,"charged bomb retains native heavy-attack damage in its three-way budget")
 var prior_impacts: int=m.impacts149
 await settle72(200)
 if target.hp>=charge_hp: print("CHARGE149_DIAGNOSTIC ",JSON.stringify({"hp":target.hp,"before":charge_hp,"centre":str(target.hit_area.global_position),"mark":str(mark),"impact_count":m.impacts149-prior_impacts,"planes":m.planes149.size(),"ages":m.planes149.map(func(p): return p.age),"paused":s.combat_paused,"scale":Engine.time_scale}))
 verify(target.hp<charge_hp,"charged area impacts use the existing enemy hit pipeline")
 set146(s,{"paper_plane":1,"homework":1,"snack":2});s.fire_at(mark);await settle72(200)
 verify(s.pending_splits110.is_empty() and s.shots.size()<=512,"split payloads resolve with a bounded secondary-projectile budget")
 var report := {"checks":checks,"failures":failures,"base_peak_planes":base_peak,"fast_peak_planes":fast_peak,"note":"Target AI frozen for repeatable fixed-ground area-impact checks; this mode intentionally does not chase targets."}
 FileAccess.open("res://docs/paper-bomb149-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("PAPER_BOMB149_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
