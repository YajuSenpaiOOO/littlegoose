extends "res://scripts/world/paper_memories146_probe.gd"
class Trial147:
 extends "res://scripts/world/woodland_world147.gd"
 var aim147 := Vector3.ZERO
 func _hero_script() -> Script: return Walker146
 func fire_input_held() -> bool: return false
 func paper_aim146() -> Vector3: return aim147
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial147.new();s.memory_save116="user://patrol147_probe_tmp.cfg";root.add_child(s)
 while not s.hill_ready146: await physics_frame
 s.hill_visited136=true;s.paper_trial129=true;s.start_combat();disable_enemies(s)
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(-24,-17));await settle72(5)
 for enemy in s.enemies: enemy.hide();enemy.hit_area.collision_layer=0
 s.aim147=s.projectile_origin()+Vector3(0,0,-4)
 var m: Node3D=s.paper_memories146;m.flight_rng146.seed=147
 set146(s,{"paper_plane":1,"homework":1})
 for i in 10: s.fire_at(s.aim147)
 verify(m.patrol147.size()==3 and s.shots.is_empty() and m.pages146.size()==3,"ten launch attempts create only three planes and three notes without immediate projectiles")
 await settle72(48)
 if "--capture147" in OS.get_cmdline_user_args():
  var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/paper_patrol147_flight.png")
 verify(m.drops147>0 and not s.shots.is_empty(),"planes emit real downward payloads while gliding")
 var down := true
 for shot in s.shots: down=down and shot.velocity.y<0.
 verify(down,"random payloads point down from the plane rather than toward nearby enemies")
 var normal: float=s.patrol_interval147(false);s.buffs.levels.eye_exercise=2
 verify(s.patrol_interval147(false)<normal and is_equal_approx(s.attack_cooldown(),1.1),"attack speed accelerates bombing without increasing launch rate or plane cap")
 var age: float=m.patrol147[0].age;var drops: int=m.drops147;s.combat_paused=true;await settle72(12)
 verify(is_equal_approx(m.patrol147[0].age,age) and m.drops147==drops,"pause freezes flights and bombing")
 s.combat_paused=false
 for plane in m.patrol147: plane.life=float(plane.age)+.01
 await settle72(12)
 verify(not m.patrol147.is_empty() and Vector3(m.patrol147[0].land).is_finite(),"expired planes enter an unpowered descent toward the ground")
 if "--capture147" in OS.get_cmdline_user_args():
  var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/paper_patrol147_descent.png")
 await settle72(45)
 verify(m.patrol147.is_empty(),"landed planes fade and release their three-plane slots")
 # Isolate native collision from random patrol coverage.
 var target: CharacterBody3D=s.enemies[0];target.show();target.hit_area.collision_layer=8;target.hp=10000.;target.max_hp110=10000.
 target.position=s.hero.position+Vector3(0,0,-3);target.position.y=s.floor_height(Vector2(target.position.x,target.position.z))+.06;s.rebuild_cells110()
 var hp: float=target.hp;var centre: Vector3=target.hit_area.global_position
 var pages: int=m.pages146.size();s.drop_patrol147(centre+Vector3.UP*2.,centre-Vector3.UP*1.,1./3.,false,0.);await settle72(25)
 verify(target.hp<hp and m.pages146.size()==pages,"downward payload hits a native enemy without recursively recording notes")
 set146(s,{"paper_plane":1,"homework":1,"flashlight":1,"snack":2,"distract":2,"eye_exercise":2})
 for i in 3: s.fire_at(s.aim147)
 var samples: Array=[];var peak := 0
 for frame in 360:
  if frame%66==0: s.fire_at(s.aim147)
  var begin := Time.get_ticks_usec();await settle72(1);samples.append((Time.get_ticks_usec()-begin)/1000.);peak=maxi(peak,s.shots.size())
 samples.sort()
 verify(peak<=s.MAX_SHOTS147 and m.patrol147.size()<=3,"high-rate water/split/multilane combination stays inside live-shot and plane limits")
 set146(s,{"paper_plane":1,"homework":1})
 for i in 3: s.fire_at(s.aim147)
 m.request146();await settle72(44)
 verify(m.pending146.size()==3 and m.patrol147.size()==3,"notebook replay waits for a free plane slot without losing stored copies")
 s._clear_combat_shots();verify(m.patrol147.is_empty() and m.pending146.is_empty() and m.pages146.is_empty(),"retry or switching builds clears planes and queued notebook copies")
 set146(s,{"paper_plane":1,"homework":1});s.random_planes147=false;s.fire_at(s.aim147)
 verify(m.flights146.size()==1 and m.patrol147.is_empty(),"comparison mode keeps the original aimed-delivery flight")
 var report := {"checks":checks,"failures":failures,"peak_live_shots":peak,"sample_frame_ms_p50":samples[samples.size()/2],"sample_frame_ms_p95":samples[int(samples.size()*.95)],"note":"Wall frame samples include pacing and scene cost; not a hardware performance benchmark."}
 FileAccess.open("res://docs/paper-patrol147-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("PAPER_PATROL147_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
