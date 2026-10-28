extends "res://scripts/world/pillow_hut160_probe.gd"
class Trial161:
 extends "res://scripts/world/woodland_world161.gd"
 func _hero_script() -> Script: return Walker160
 func fire_input_held() -> bool: return false
func capture161(tag: String) -> void:
 var image := await snapshot();image.save_png("res://docs/captures/world_restart/hero_moment161_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial161.new();s.memory_save116="user://hero161_probe_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.moment161): await physics_frame
 s.hill_visited136=true;s.trial152=true;s.paper_trial129=false;s.start_combat();disable_enemies(s);s.clear_standby119();s.hero.controls_enabled=true
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(0.,4.));await settle72(10)
 for e in s.enemies: e.hide();e.hit_area.collision_layer=0
 var m: Node=s.moment161
 verify(s.memory_kit116.owned.hero_moment==1 and s.memory_kit116.valid(["hero_moment","paper_plane","balloon_sword","pillow_hut"]),"free active fragment supports four-slot sword-airplane-fort build")
 verify(not s.memory_kit116.valid(["hero_moment","homework"]),"one active slot rejects simultaneous notebook and hero moment")
 verify(s.buffs.eligible().all(func(c: Dictionary) -> bool: return c.id!="homework"),"random acquisition also respects active exclusion")
 s.set_physics_process(false);s.hero.set_physics_process(false)
 var aim: Vector3=s.projectile_origin()+Vector3(0.,0.,-4.)
 s.fire_at(aim)
 var old_shot: Dictionary=s.shots[-1];var base: float=s.damage_for_shot(old_shot)
 var interval: float=s.attack_cooldown();var charge: float=s.charge_time()
 await key153(KEY_Q)
 verify(m.running161() and m.activations161==1,"physical Q starts hero moment")
 verify(is_equal_approx(s.attack_cooldown(),interval/1.4) and is_equal_approx(s.charge_time(),charge/1.4),"fire cadence and slingshot charge use shared forty-percent rate bonus")
 verify(is_equal_approx(s.damage_for_shot(old_shot),base),"existing bullets are not retroactively empowered")
 s.fire_at(aim);var boosted: Dictionary=s.shots[-1]
 verify(is_equal_approx(s.damage_for_shot(boosted),base*1.3),"new native shot receives exactly thirty-percent damage")
 await key153(KEY_Q);verify(m.activations161==1,"repeated Q cannot restart duration")
 m.step161(.12);await capture161("entrance")
 var target: CharacterBody3D=s.enemies[0];target.show();target.hit_area.collision_layer=8;target.hp=10000.;target.max_hp110=10000.
 target.position=s.hero.position+Vector3(0.,0.,-4.);target.position.y=s.floor_height(Vector2(target.position.x,target.position.z))+.06
 var hp: float=target.hp
 s._apply_shot_hit(boosted,{"collider":target.hit_area,"position":target.hit_area.global_position,"normal":Vector3.BACK})
 verify(is_equal_approx(hp-target.hp,base*1.3),"native enemy takes empowered damage through real hit handler")
 s.combat_paused=true;var remaining: float=m.left161;m.step161(2.)
 verify(m.left161==remaining,"pause freezes active timer")
 s.combat_paused=false
 for i in 12: s.hero.position.x+=.15;m.step161(.08)
 verify(m.ghosts161.size()<=4 and not m.ghosts161.is_empty(),"movement trails remain bounded to four short ghosts")
 s.time55.preview_at(22.);s.time55.visual_hour=22.;s.time55.apply_look();await process_frame
 var clock: float=s.time55.visual_hour
 await capture161("night")
 verify(is_equal_approx(s.time55.visual_hour,clock),"imaginary warm spotlight leaves actual night clock unchanged")
 m.step161(8.)
 verify(not m.running161() and m.cooldown161==20. and s.buffs.moment_rate161==1.,"expiration restores rate and starts full twenty-second cooldown")
 verify(is_equal_approx(s.damage_for_shot(boosted),base*1.3),"launched shot keeps its damage after stage expires")
 verify(not m.request161(),"cannot reactivate during cooldown")
 m.step161(.25);await capture161("paper_stars_exit")
 m.step161(20.);verify(m.request161(),"active is available after cooldown")
 s._clear_combat_shots();verify(not m.running161() and m.cooldown161==0. and m.ghosts161.is_empty() and s.buffs.moment_rate161==1.,"clear removes temporary stats, trails and timers")
 s.build161=1;s.apply_paper_build129()
 var packet_base: Dictionary=s.snapshot_packet146(aim,false,0.,true)
 m.request161();var packet: Dictionary=s.snapshot_packet146(aim,false,0.,true)
 verify(is_equal_approx(packet.specs[0].damage,packet_base.specs[0].damage*1.3),"plane packet includes damage once without canceling rate benefit")
 m.finish161();s.emit_packet146(packet,s.projectile_origin(),aim,1.)
 verify(is_equal_approx(s.damage_for_shot(s.shots[-1]),packet.specs[0].damage),"deferred plane payload keeps snapshot bonus without double multiplication")
 s.build161=2;s.apply_paper_build129();m.request161();var sword_packet: Dictionary=s.snapshot_packet146(aim,false,0.,true)
 verify(sword_packet.specs[0].sword153,"airborne sword identity survives stage snapshot")
 s.emit_packet146(sword_packet,s.projectile_origin(),aim,1.)
 verify(is_equal_approx(s.damage_for_shot(s.shots[-1]),sword_packet.specs[0].damage),"sword damage budget and stage bonus are each applied once")
 var split: Dictionary=s.data_shot110(s.projectile_origin(),Vector3.FORWARD,1.)
 split.fixed_damage110=17.;split.split_depth110=1
 s.inherit_split153(split,{"sword153":true})
 verify(is_equal_approx(s.damage_for_shot(split),17.),"fixed split damage is not empowered a second time")
 s.build161=3;s.apply_paper_build129();m.request161();s.hero.guarding109=true;s.hero.velocity=Vector3.ZERO;s.pillow160.step160(.46)
 verify(m.running161() and s.pillow160.protects160(),"pillow protection and hero offense coexist")
 s.hero.guarding109=false;s.time55.preview_at(12.);s.time55.visual_hour=12.;s.time55.apply_look();m.step161(1.2);s.pillow160.step160(.25);await capture161("fort_day")
 s.build161=0;s.apply_paper_build129();m.request161();s.player_hp=100.;s.invulnerability=0.;s.hero.dodge_invulnerability=0.;s.wave_state="fighting";s.hurt_player(15.,Vector2.ZERO)
 verify(s.player_hp==85.,"hero moment itself provides no invulnerability")
 s.hero.set_physics_process(true);s.set_physics_process(true)
 await key153(KEY_F4);await settle72(4);disable_enemies(s);s.clear_standby119();await key153(KEY_5)
 verify(s.paper_trial129 and s.build161==4 and s.buffs.level("hero_moment")==1,"paper encounter and fort-sword-rain preset keys work")
 await key153(KEY_F5);await settle72(3);disable_enemies(s);await key153(KEY_6)
 verify(not s.paper_trial129 and s.buffs.level("homework")==1 and s.buffs.level("hero_moment")==0,"Tuantuan notebook comparison retains original active")
 s.fire_at(aim);await key153(KEY_Q)
 verify(s.paper_memories146.writing146 and not m.running161(),"Q still opens notebook when it is the equipped active")
 var report := {"checks":checks,"failures":failures,"note":"Targeted actual input, damage, snapshot, lifecycle and rendered stage checks; numerical balance awaits playtesting."}
 FileAccess.open("res://docs/hero-moment161-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("HERO161_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
