extends "res://scripts/world/paper_memories146_probe.gd"
class Trial153:
 extends "res://scripts/world/woodland_world153.gd"
 var aim153 := Vector3.ZERO
 func _hero_script() -> Script: return Walker146
 func fire_input_held() -> bool: return false
 func paper_aim146() -> Vector3: return aim153
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func key153(key: Key) -> void:
 await process_frame
 var event := InputEventKey.new();event.physical_keycode=key;event.keycode=key;event.pressed=true;root.push_input(event)
 await process_frame
 event=event.duplicate();event.pressed=false;root.push_input(event)
 await process_frame
func capture153(tag: String) -> void:
 var img := await snapshot();img.save_png("res://docs/captures/world_restart/balloon_sword153_"+tag+".png")
func keep153(target: Node3D) -> void:
 target.impulse=Vector2.ZERO;target.velocity=Vector3.ZERO;target._render_legacy(.05)
func advance153(target: Node3D,frames: int) -> void:
 for i in frames: keep153(target);await settle72(1)
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial153.new();s.memory_save116="user://sword153_probe_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.swords153): await physics_frame
 s.hill_visited136=true;s.trial152=true;s.paper_trial129=false;s.start_combat();disable_enemies(s);s.clear_standby119();s.hero.controls_enabled=true
 var g: Vector2=s.meadow.landmarks.grove
 s._teleport15(g+Vector2(0.,4.));await settle72(10)
 for e in s.enemies: e.hide();e.hit_area.collision_layer=0
 var target: CharacterBody3D=s.enemies[0];target.show();target.hit_area.collision_layer=8;target.hp=10000.;target.max_hp110=10000.
 target.position=s.hero.position+Vector3(0,0,-4.);target.position.y=s.floor_height(Vector2(target.position.x,target.position.z))+.06
 s.aim153=target.hit_area.global_position;keep153(target);s.rebuild_cells110();await settle72(5)
 var m: Node3D=s.swords153
 verify(not s.scatter152 and s.memory_kit116.owned.balloon_sword==1 and s.memory_kit116.valid(["balloon_sword","paper_plane","homework"]),"assisted six-shot default and independent one-slot sword fragment are available")
 var progress: int=s.memory_kit116.next_event119;var gel: int=s.memory_kit116.gel119
 s.build153=0;s.apply_paper_build129();var hp: float=target.hp;s.fire_at(s.aim153)
 await advance153(target,35)
 print("DIRECT153 hp=",hp," after=",target.hp," layers=",m.layers153.get(target.get_instance_id(),[]).size()," shots=",s.shots.size())
 verify(target.hp<hp and m.layers153.get(target.get_instance_id(),[]).size()==1 and is_equal_approx(target.get_meta("locomotion_scale153"),.92),"real native direct sword damages and sticks to the enemy with one slow layer")
 await capture153("direct_stuck")
 s.set_physics_process(false)
 m.reset153();m.attach153(target,target.hit_area.global_position,Vector3.FORWARD);m.step153(1.5)
 m.attach153(target,target.hit_area.global_position,Vector3.FORWARD);m.step153(1.55)
 verify(m.layers153[target.get_instance_id()].size()==1 and is_equal_approx(target.get_meta("locomotion_scale153"),.92),"new hits do not refresh older layers; the oldest sword expires independently")
 for i in 12: m.attach153(target,target.hit_area.global_position,Vector3.FORWARD)
 m.step153(.01)
 verify(m.layers153[target.get_instance_id()].size()==5 and is_equal_approx(target.get_meta("locomotion_scale153"),.6),"rapid hits cap at five swords and forty percent slow")
 # Compare actual AI locomotion with the same hop phase, retaining full attack clocks.
 s.tactical_combat=true;target.active_ai=true;target.mode119="playing";target.roam122=false;target.play_state123=""
 var at: Vector3=target.position;var velocities := []
 for scale153 in [1.,.6]:
  target.position=at;target.impulse=Vector2.ZERO;target.attack_phase="approach";target.phase_clock=.01;target.hopping=true;target.hop_clock=.10;target.hop_direction=Vector2.RIGHT;target.hop_boost110=1.;target.set_meta("locomotion_scale153",scale153)
  target._physics_process(1./60.);velocities.append(Vector2(target.velocity.x,target.velocity.z).length())
 verify(velocities[0]>.1 and absf(velocities[1]/velocities[0]-.6)<.02,"native Tuantuan chase motion is really slowed without slowing its hop clock")
 velocities.clear()
 for scale153 in [1.,.6]:
  target.position=at;target.impulse=Vector2.ZERO;target.play_state123="";target.attack_phase="lunge";target.phase_clock=.1;target.attack_direction=Vector2.RIGHT;target.attack_distance=2.;target.attack_connected=true;target.set_meta("locomotion_scale153",scale153)
  target._physics_process(1./60.);velocities.append(Vector2(target.velocity.x,target.velocity.z).length())
 verify(velocities[0]>.1 and is_equal_approx(velocities[0],velocities[1]),"an already launched Tuantuan pounce keeps its speed")
 target.position=at;target.active_ai=false;m.reset153();s.set_physics_process(true);s.build153=1;s.apply_paper_build129();s.aim153=target.hit_area.global_position
 var before_air: int=m.landed153
 s.fire_at(s.aim153);var packet: Dictionary=s.paper_memories146.planes149[0].packet
 verify(packet.specs[0].sword153 and s.paper_memories146.pages146.size()==1,"airplane and notebook snapshot the sword payload instead of converting it to ordinary bullets")
 await advance153(target,190)
 print("AIR153 landed=",m.landed153-before_air," layers=",m.layers153.get(target.get_instance_id(),[]).size()," history=",s.paper_memories146.history149.size())
 verify(m.landed153>before_air and not m.layers153.get(target.get_instance_id(),[]).is_empty(),"assisted flyover delivers actual adhesive swords to a native enemy")
 await capture153("sword_rain")
 # An empty part of the same arena must produce visible planted swords too.
 s._clear_combat_shots();target.hit_area.collision_layer=0
 var ground: Vector3=s.hero.position+Vector3(-1.,0.,-3.);ground.y=s.floor_height(Vector2(ground.x,ground.z))+.05
 s.fire_at(ground);await advance153(target,200)
 var ground_count := 0
 for entry in m.resting153: if entry.enemy==null: ground_count+=1
 verify(ground_count>0,"missed airborne swords hit real terrain and remain planted briefly")
 await capture153("planted")
 s._clear_combat_shots();target.hit_area.collision_layer=8;s.build153=4;s.apply_paper_build129();s.aim153=target.hit_area.global_position;s.fire_at(s.aim153)
 var split_found := false
 for i in 65:
  keep153(target);await settle72(1)
  for shot in s.shots:
   if shot.get("split_depth110",0)>0 and shot.get("sword153",false): split_found=true
 verify(split_found,"native split children inherit sword visuals and control without applying the damage penalty twice")
 s._clear_combat_shots();s.buffs.levels={};s.emit_packet146(packet,s.projectile_origin(),s.projectile_origin()+Vector3(1,0,0),.45)
 verify(s.shots[-1].sword153 and is_equal_approx(s.damage_for_shot(s.shots[-1]),float(packet.specs[0].damage)*.45),"saved sword packet retains its identity and damage exactly once after equipment changes")
 s._clear_combat_shots();verify(m.resting153.is_empty() and is_equal_approx(target.get_meta("locomotion_scale153",1.),1.),"clearing combat removes every sword and restores locomotion")
 await key153(KEY_F4);await settle72(4);disable_enemies(s);s.clear_standby119();await key153(KEY_3);await settle72(2)
 print("INPUT153 active=",s.active114," paper=",s.paper_trial129," build=",s.build153," sword=",s.buffs.level("balloon_sword"))
 verify(s.paper_trial129 and s.build153==2 and s.buffs.level("balloon_sword")==1,"physical encounter and build keys work for paper enemies")
 var paper: CharacterBody3D=s.enemies[0];paper.active_ai=true;paper.mode119="playing";paper.hp=10000.;paper.max_hp110=10000.
 var paper_at := paper.position;velocities.clear()
 for scale153 in [1.,.6]:
  paper.position=paper_at;paper.impulse=Vector2.ZERO;paper.drift130=Vector2.RIGHT;paper.paper_state129="drift";paper.gust_wait130=999.;paper.air_age131=1.;paper.air_scan131=99.;paper.age=3.;paper.set_meta("locomotion_scale153",scale153)
  paper._physics_process(1./60.);velocities.append(Vector2(paper.velocity.x,paper.velocity.z).length())
 verify(velocities[0]>.1 and absf(velocities[1]/velocities[0]-.6)<.02,"native paper wind drift is genuinely slowed")
 paper.position=paper_at;paper.active_ai=false
 verify(s.memory_kit116.next_event119==progress and s.memory_kit116.gel119==gel,"both prototype encounters preserve material balance and progression")
 var report := {"checks":checks,"failures":failures,"tuantuan_velocity_ratio":.6,"ground_swords":ground_count,"note":"Targeted physics/control/payload checks; not a balance verdict."}
 FileAccess.open("res://docs/balloon-sword153-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("BALLOON_SWORD153_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
