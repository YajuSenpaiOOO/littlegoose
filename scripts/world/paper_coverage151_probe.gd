extends "res://scripts/world/paper_memories146_probe.gd"
class Trial151:
 extends "res://scripts/world/woodland_world151.gd"
 var aim151 := Vector3.ZERO
 func _hero_script() -> Script: return Walker146
 func fire_input_held() -> bool: return false
 func paper_aim146() -> Vector3: return aim151
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func capture151(tag: String) -> void:
 if "--capture151" in OS.get_cmdline_user_args():
  var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/paper_coverage151_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial151.new();s.memory_save116="user://coverage151_probe_tmp.cfg";root.add_child(s)
 while not s.hill_ready146: await physics_frame
 s.hill_visited136=true;s.paper_trial129=true;s.start_combat();disable_enemies(s);s.hero.controls_enabled=true
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(-24,-17));await settle72(10)
 for enemy in s.enemies: enemy.hide();enemy.hit_area.collision_layer=0
 var mark := s.hero.position+Vector3(0,0,-4);mark.y=s.floor_height(Vector2(mark.x,mark.z))+.05;s.aim151=mark
 var m: Node3D=s.paper_memories146;m.flight_rng146.seed=151
 set146(s,{"paper_plane":1,"homework":1});s.fire_at(mark)
 verify(is_equal_approx(m.marker_radius150(),2.4) and m.planes149[0].coverage151.size()==6,"larger target region provides six separated coverage samples")
 var wait := 0
 while m.history149.size()<6 and wait<180: await settle72(1);wait+=1
 var aims := {};var empty := true
 for event in m.history149: aims[str(event.aim)]=true;empty=empty and event.target_id==0
 verify(m.history149.size()==6 and aims.size()==6 and empty,"empty region gets six actual spread trajectories without inventing targets")
 verify(float(m.history149[-1].age)-float(m.history149[0].age)<=.301,"six releases complete in a short rhythmic flyby")
 verify(m.pages146.size()==1,"six deliveries record only one classroom-note page")
 await capture151("empty_spread")
 var targets: Array[CharacterBody3D]=[s.enemies[0],s.enemies[1]]
 for i in 2:
  var enemy: CharacterBody3D=targets[i];enemy.show();enemy.hit_area.collision_layer=8;enemy.hp=10000.;enemy.max_hp110=10000.
  enemy.position=mark+Vector3(-.9 if i==0 else .9,.06,0);enemy.set_physics_process(true)
 s.rebuild_cells110()
 set146(s,{"paper_plane":1,"homework":1});m.history149.clear();s.fire_at(mark);wait=0
 var hp: float=targets[0].hp+targets[1].hp
 while m.history149.size()<6 and wait<180: await settle72(1);wait+=1
 var ids := {};var elevated := true
 for event in m.history149: ids[event.target_id]=true;elevated=elevated and event.aim.y>mark.y+.5
 verify(ids.size()==2 and not ids.has(0) and elevated,"salvo distributes shots between region enemies at their actual airborne height")
 await capture151("assigned_salvo");await settle72(60)
 verify(targets[0].hp+targets[1].hp<hp,"region-assigned payloads deal damage through actual native projectile collisions")
 targets[1].position=mark+Vector3(4.,.06,0);s.rebuild_cells110()
 verify(not m.in_area151(targets[1],mark),"enemies outside the marked area are excluded from compensation")
 targets[1].hide();targets[1].hit_area.collision_layer=0
 # Use the actual paper drift, gust attack and wind-reaction AI for the key regression.
 var actor: CharacterBody3D=targets[0];actor.position=mark+Vector3(0,.06,0);actor.active_ai=true;actor.set_physics_process(true);s.rebuild_cells110()
 set146(s,{"paper_plane":1,"homework":1});var moving_hp: float=actor.hp;var hits: int=s.landed_hits
 for i in 4:
  var aim := actor.position;aim.y=s.floor_height(Vector2(aim.x,aim.z))+.05;s.fire_at(aim);await settle72(72)
 await settle72(100);await capture151("moving_paper")
 var actual_hits: int=s.landed_hits-hits
 var moving_damage: float=moving_hp-actor.hp
 verify(actor.hp<moving_hp and actual_hits>=2,"default payload can hit the last paper with real drift, gust and airflow-avoidance AI enabled")
 actor.active_ai=false
 set146(s,{"paper_plane":1,"homework":1,"slingshot":1});m.history149.clear();s._release_charged(actor.position,1.)
 var packet: Dictionary=m.planes149[0].packet;wait=0
 while m.history149.is_empty() and wait<180: await settle72(1);wait+=1
 verify(not s.shots.is_empty() and s.shots[-1].charged and is_equal_approx(s.damage_for_shot(s.shots[-1]),float(packet.specs[0].damage)/6.),"six heavy payloads share one charge budget and preserve charged behavior")
 set146(s,{"paper_plane":1,"homework":1,"flashlight":1,"distract":1});m.history149.clear();s.fire_at(actor.position);wait=0
 while m.history149.size()<3 and wait<180: await settle72(1);wait+=1
 await settle72(5);await capture151("water")
 var lanes := {};var following := false
 for shot in s.shots:
  if shot.get("stream110",false): lanes[int(shot.stream_lane110)]=true
 for burst in m.bursts146:
  if burst.has("target151") and burst.has("flight150"): following=true
 verify(lanes.size()==2 and following,"water keeps moving aircraft muzzles, separate lanes and region-height aiming")
 set146(s,{"paper_plane":1,"homework":1})
 for i in 8: s.fire_at(mark)
 verify(m.planes149.size()==8,"six-shot coverage does not reintroduce a plane-count cap")
 m.request146();await settle72(75)
 verify(m.pending146.is_empty() and m.planes149.size()>=11,"notebook replay joins the fleet without recording the six subshots")
 s._clear_combat_shots();verify(m.planes149.is_empty() and m.bursts146.is_empty(),"reset clears fleet and regional water emitters")
 var report := {"checks":checks,"failures":failures,"moving_paper_hits":actual_hits,"moving_paper_damage":moving_damage,"region_radius":2.4,"deliveries_per_plane":6}
 FileAccess.open("res://docs/paper-coverage151-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("PAPER_COVERAGE151_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
