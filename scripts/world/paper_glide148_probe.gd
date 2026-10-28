extends "res://scripts/world/paper_memories146_probe.gd"
class Trial148:
 extends "res://scripts/world/woodland_world148.gd"
 var aim148 := Vector3.ZERO
 func _hero_script() -> Script: return Walker146
 func fire_input_held() -> bool: return false
 func paper_aim146() -> Vector3: return aim148
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func capture148(tag: String) -> void:
 if "--capture148" in OS.get_cmdline_user_args():
  var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/paper_glide148_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial148.new();s.memory_save116="user://glide148_probe_tmp.cfg";root.add_child(s)
 while not s.hill_ready146: await physics_frame
 s.hill_visited136=true;s.paper_trial129=true;s.start_combat();disable_enemies(s)
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(-24,-17));await settle72(5)
 for enemy in s.enemies: enemy.hide();enemy.hit_area.collision_layer=0
 var target: CharacterBody3D=s.enemies[0];target.show();target.hit_area.collision_layer=8;target.hp=10000.;target.max_hp110=10000.
 target.position=s.hero.position+Vector3(0,0,-4);target.position.y=s.floor_height(Vector2(target.position.x,target.position.z))+.06;s.rebuild_cells110()
 s.aim148=target.hit_area.global_position
 var m: Node3D=s.paper_memories146;m.flight_rng146.seed=148
 set146(s,{"paper_plane":1,"homework":1});var hp: float=target.hp;s.fire_at(s.aim148)
 verify(s.shots.is_empty() and m.gliders148.size()==1,"throw launches a harmless plane with no duplicate direct projectile")
 var steps := 0
 while m.emissions148.is_empty() and steps<90: await settle72(1);steps+=1
 verify(not m.emissions148.is_empty() and target.hp==hp and not s.shots.is_empty(),"payload becomes a real visible projectile before causing any enemy damage")
 var distance: float=m.emissions148[0].distance
 verify(distance>=m.CLEARANCE148,"first release has a measurable air gap to the target")
 await capture148("release")
 var plane_pos: Vector3=m.gliders148[0].node.position
 await settle72(12)
 verify(not m.gliders148.is_empty() and m.gliders148[0].node.position.distance_to(plane_pos)>.2,"plane continues gliding independently after releasing its payload")
 await capture148("payload")
 await settle72(100)
 verify(target.hp<hp and m.emissions148.size()==3 and m.pages146.size()==1,"three ordinary releases hit through native collision without recording extra notes")
 await settle72(70);verify(m.gliders148.is_empty(),"glide, descent and fade free the plane slot")
 # Retain a single target while it changes position during the flight.
 set146(s,{"paper_plane":1,"homework":1});m.emissions148.clear();hp=target.hp;s.fire_at(target.hit_area.global_position)
 target.position.x+=1.1;s.rebuild_cells110()
 await settle72(100)
 verify(target.hp<hp and m.emissions148[0].target.distance_to(target.hit_area.global_position)<=.401 and m.emissions148[0].target.distance_to(s.aim148)>.5,"the last remaining target is re-aimed after moving during flight, with bounded motion lead")
 set146(s,{"paper_plane":1,"homework":1});m.emissions148.clear();hp=target.hp
 target.active_ai=true;target.set_physics_process(true)
 for i in 4:
  s.fire_at(target.hit_area.global_position);await settle72(65)
 verify(target.hp<hp,"ordinary airborne payloads can hit the final paper enemy with its actual drifting AI running")
 await capture148("moving_target")
 target.active_ai=false;target.set_physics_process(false)
 # Close target: no impact-only detonation or emission inside its hurtbox.
 set146(s,{"paper_plane":1,"homework":1});m.emissions148.clear()
 target.position=s.hero.position+Vector3(0,0,-.8);target.position.y=s.floor_height(Vector2(target.position.x,target.position.z))+.06;s.rebuild_cells110()
 s.fire_at(target.hit_area.global_position);await settle72(100)
 var clear: bool=not m.emissions148.is_empty()
 for emission in m.emissions148: clear=clear and float(emission.distance)>=m.CLEARANCE148
 verify(clear,"nearby targets still get a lateral flyby and no point-blank payload spawn")
 set146(s,{"paper_plane":1,"homework":1,"slingshot":1});m.emissions148.clear();s._release_charged(target.hit_area.global_position,1.)
 verify(m.gliders148[0].count==1 and m.gliders148[0].packet.specs[0].charged,"charged plane carries one heavy payload instead of three full charged copies")
 await settle72(100);verify(m.emissions148.size()==1,"charged flight releases its heavy payload once")
 set146(s,{"paper_plane":1,"homework":1,"flashlight":1});m.emissions148.clear();s.fire_at(target.hit_area.global_position);await settle72(100)
 verify(m.emissions148.size()>1 and m.emissions148.size()<=10,"water payload is a bounded short airborne sweep")
 set146(s,{"paper_plane":1,"homework":1})
 for i in 8: s.fire_at(target.hit_area.global_position)
 verify(m.gliders148.size()==3 and m.pages146.size()==3,"direct launches respect three slots and only successful launches are recorded")
 m.request146();await settle72(45)
 verify(m.pending146.size()==3 and m.gliders148.size()==3,"notebook copies wait for slots rather than replacing or losing planes")
 var age: float=m.gliders148[0].age;s.combat_paused=true;await settle72(10)
 verify(is_equal_approx(m.gliders148[0].age,age),"pause freezes gliding and payload releases")
 s.combat_paused=false;s._clear_combat_shots()
 verify(m.gliders148.is_empty() and m.pages146.is_empty() and m.pending146.is_empty(),"reset clears glide planes, notes and queued replays")
 var report := {"checks":checks,"failures":failures,"first_release_gap_m":distance,"note":"Native hit tests isolate enemy movement for repeatability; flight visuals captured separately."}
 FileAccess.open("res://docs/paper-glide148-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("PAPER_GLIDE148_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
