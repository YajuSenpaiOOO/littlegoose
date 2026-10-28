extends "res://scripts/world/paper_memories146_probe.gd"
class Trial152:
 extends "res://scripts/world/woodland_world152.gd"
 var aim152 := Vector3.ZERO
 func _hero_script() -> Script: return Walker146
 func fire_input_held() -> bool: return false
 func paper_aim146() -> Vector3: return aim152
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func key152(key: Key) -> void:
 var event := InputEventKey.new();event.physical_keycode=key;event.pressed=true;Input.parse_input_event(event)
func capture152(tag: String) -> void:
 if "--capture152" in OS.get_cmdline_user_args():
  var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/paper_scatter152_"+tag+".png")
func steady152(s: Node3D) -> void:
 for actor in s.enemies:
  actor.impulse=Vector2.ZERO;actor.velocity=Vector3.ZERO;actor._render_legacy(.05)
func bench152(s: Node3D,label: String,index: int,scatter: bool,mark: Vector3) -> Dictionary:
 s.scatter152=scatter;s.build152=index;s.apply_paper_build129();s.paper_memories146.flight_rng146.seed=152;s.weapon_rng.seed=152
 for actor in s.enemies: actor.hp=1000.;actor.max_hp110=1000.;actor.dead=false
 var before: int=s.fired_count
 for frame in 420:
  if frame<216:
   if index<6 and frame%72==0: s.fire_at(mark)
   if index>=6 and frame%20==0: s.fire_at(s.enemies[4].hit_area.global_position)
  steady152(s);await settle72(1)
 var result := {"label":label,"damage":s.damage152,"hits":s.hits152,"projectiles":s.fired_count-before,"kills":s.kills152,"note":"Static six-Tuantuan fixture; 3.6s firing window plus travel tail, no notebook replay. Not a live-combat balance verdict."}
 print("BENCH152 ",JSON.stringify(result));return result
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial152.new();s.memory_save116="user://scatter152_probe_tmp.cfg";root.add_child(s)
 while not s.hill_ready146: await physics_frame
 s.trial152=true;s.paper_trial129=true;s.start_combat();disable_enemies(s);s.hero.controls_enabled=true
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(-24,-17));await settle72(10)
 for enemy in s.enemies: enemy.hide();enemy.hit_area.collision_layer=0
 var mark := s.hero.position+Vector3(0,0,-4);mark.y=s.floor_height(Vector2(mark.x,mark.z))+.05;s.aim152=mark
 var m: Node3D=s.paper_memories146;m.flight_rng146.seed=152;s.build152=0;s.apply_paper_build129()
 s.fire_at(mark);var packet: Dictionary=m.planes149[0].packet;var wait := 0
 while m.history149.size()<9 and wait<180: await settle72(1);wait+=1
 var valid := true;var points := {};var min_time := INF;var max_time := 0.
 for event in m.history149:
  valid=valid and event.target_id==0 and Vector2(event.aim.x-mark.x,event.aim.z-mark.z).length()<=2.401
  points[str(event.aim)]=true;min_time=minf(min_time,event.age);max_time=maxf(max_time,event.age)
 verify(valid and points.size()==9 and is_equal_approx(min_time,max_time),"random mode releases nine simultaneous independent ground samples inside the disk")
 verify(m.assigned151==0 and m.pages146.size()==1,"random scatter does not query enemy assignment or record nine notebook pages")
 verify(not s.shots.is_empty() and is_equal_approx(s.damage_for_shot(s.shots[-1]),float(packet.specs[0].damage)/9.),"nine projectiles share the same total payload budget")
 await capture152("paper_scatter")
 var identities: Array=s.enemies.map(func(e): return e.get_instance_id());key152(KEY_F8);await settle72(2)
 verify(not s.scatter152 and m.planes149.is_empty() and s.enemies.map(func(e): return e.get_instance_id())==identities,"physical F8 switches to six-shot assist, clears transient fire and preserves the current encounter")
 s.fire_at(mark);wait=0
 while m.history149.size()<15 and wait<180: await settle72(1);wait+=1
 verify(m.drops149>=15 and m.delivery_count150()==6,"assist comparison retains the six-delivery pattern")
 var progress: int=s.memory_kit116.next_event119;key152(KEY_F5);await settle72(4)
 verify(not s.paper_trial129 and s.enemies.size()>=6 and s.enemies[0].get_script().resource_path.ends_with("tuantuan128.gd"),"physical F5 starts the real Tuantuan encounter and its current behavior script")
 verify(s.memory_kit116.next_event119==progress and s.buffs.level("paper_plane")==1,"Tuantuan practice preserves the selected plane build without advancing saved progression")
 # Prove absence of actual native homing, even with the rate/tracking fragment equipped.
 s._clear_combat_shots();s.buffs.levels={"paper_plane":1,"eye_exercise":2};s._apply_owned_buffs();s.scatter152=true
 var origin: Vector3=s.enemies[0].hit_area.global_position+Vector3(0,2.,1.5);var velocity := Vector3(.1,-1.,-4.)
 var shot: Dictionary=s.data_shot110(origin,velocity,3.)
 for i in 8: s._step_shots(.016)
 verify(shot.velocity.is_equal_approx(velocity) and s.buffs.level("eye_exercise")==2 and s.buffs.rate()>1.,"random-mode native projectiles do not bend while attack-speed bonuses remain intact")
 s._clear_combat_shots();s.scatter152=false;shot=s.data_shot110(origin,velocity,3.)
 for i in 8: s._step_shots(.016)
 verify(not shot.velocity.is_equal_approx(velocity),"assist mode restores the original native tracking behavior")
 s._clear_combat_shots();s.build152=0;s.apply_paper_build129();s.scatter152=true
 for enemy in s.enemies: enemy.active_ai=false;enemy.set_physics_process(false);enemy.hit_area.collision_layer=8;enemy.show()
 s.clear_standby119()
 var center: Vector2=Vector2(s.meadow.landmarks.grove)+Vector2(0,-2.5)
 for i in s.enemies.size():
  var at := center+Vector2(float(i%3-1)*.95,float(i/3)*1.1-.55)
  s.enemies[i].position=Vector3(at.x,s.floor_height(at)+.06,at.y);s.enemies[i].home=at
 s._teleport15(center+Vector2(0,4.));s.rebuild_cells110();mark=Vector3(center.x,s.floor_height(center)+.05,center.y);s.aim152=mark
 await settle72(20);await capture152("tuantuan_group")
 var reports: Array=[]
 reports.append(await bench152(s,"normal_random9",0,true,mark))
 await capture152("tuantuan_scatter")
 reports.append(await bench152(s,"normal_assisted6",0,false,mark))
 reports.append(await bench152(s,"normal_direct",6,false,mark))
 reports.append(await bench152(s,"split_random9",2,true,mark))
 reports.append(await bench152(s,"split_assisted6",2,false,mark))
 reports.append(await bench152(s,"split_direct",7,false,mark))
 verify(reports[0].damage>0. and reports[1].damage>0. and reports[2].damage>0.,"random, assisted and direct builds all damage the clustered Tuantuan fixture")
 key152(KEY_7);await settle72(2)
 verify(s.build152==6 and s.buffs.level("paper_plane")==0,"direct-shot comparison preset works in Tuantuan practice")
 key152(KEY_F4);await settle72(3)
 verify(s.paper_trial129 and s.build152==6 and s.buffs.level("paper_plane")==0,"F4 returns to paper practice while retaining the selected comparison build")
 var report := {"checks":checks,"failures":failures,"group_comparisons":reports}
 FileAccess.open("res://docs/paper-scatter152-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("PAPER_SCATTER152_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
