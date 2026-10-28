extends "res://scripts/world/hero_moment161_probe.gd"
class Trial168:
 extends "res://scripts/world/woodland_world168.gd"
 func _hero_script() -> Script: return Walker160
 func fire_input_held() -> bool: return false
 func hitstop(_duration: float,_force := false) -> void: pass
func capture168(tag: String) -> void:
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/goose_train168_"+tag+".png")
func total168(packet: Dictionary) -> float:
 var total := 0.
 for spec in packet.specs: total+=float(spec.damage)
 return total
func equip168(s: Node3D,levels: Dictionary) -> void:
 s._clear_combat_shots();s.buffs.levels=levels.duplicate();s._apply_owned_buffs()
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial168.new();s.memory_save116="user://train168_probe_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.arc_shadows167): await physics_frame
 s.hill_visited136=true;s.trial152=true;s.paper_trial129=false;s.start_combat();disable_enemies(s);s.clear_standby119();s.hero.controls_enabled=true
 var grove: Vector2=s.meadow.landmarks.grove;s._teleport15(grove+Vector2(0.,4.));await settle72(8)
 for enemy in s.enemies: enemy.hide();enemy.hit_area.collision_layer=0
 s.set_physics_process(false);s.hero.set_physics_process(false)
 var skill: Node2D=s.skills110
 verify(s.memory_kit116.COSTS.forest_fireboy==1 and s.memory_kit116.COSTS.three_player==2 and s.memory_kit116.COSTS.boarding_school==3,"extra-one/two/three cards occupy one/two/three slots")
 verify(s.memory_kit116.owned.boarding_school==1 and s.memory_kit116.valid(["boarding_school","homework"]),"boarding prototype is available and fits four-slot notebook")
 var aim: Vector3=s.projectile_origin()+Vector3.FORWARD*4.
 equip168(s,{"homework":1});var base: Dictionary=s.snapshot_packet146(aim,false,0.,true);var interval: float=s.attack_cooldown()
 var results := []
 for id in ["forest_fireboy","three_player","boarding_school"]:
  equip168(s,{id:1,"homework":1})
  var packet: Dictionary=s.snapshot_packet146(aim,false,0.,true);var ratio := total168(packet)/total168(base);results.append(ratio)
  var count := int(s.memory_kit116.COSTS[id])
  verify(skill.geese110.size()==count and packet.specs.size()==count+1,"copy count and emitted lanes match "+id)
  verify(is_equal_approx(packet.specs[0].damage,base.specs[0].damage) and is_equal_approx(ratio,1.+.4*count),"main stays full damage and copies add forty percent for "+id)
  verify(is_equal_approx(s.attack_cooldown(),interval),"no global cadence penalty for "+id)
  for i in range(1,packet.specs.size()): verify(packet.specs[i].goose_source168==i,"packet preserves emitter identity "+id+str(i))
 equip168(s,{"three_player":1,"slingshot":1})
 var charged: Dictionary=s.snapshot_packet146(aim,true,1.,true)
 verify(is_equal_approx(charged.specs[1].damage,charged.specs[0].damage*.4) and is_equal_approx(charged.specs[2].damage,charged.specs[0].damage*.4),"charged payload scales copies once")
 equip168(s,{"paper_plane":1});var plane0: Dictionary=s.snapshot_packet146(aim,false,0.,true)
 equip168(s,{"three_player":1,"paper_plane":1});var plane: Dictionary=s.snapshot_packet146(aim,false,0.,true)
 verify(is_equal_approx(total168(plane),total168(plane0)*1.8) and is_equal_approx(plane.specs[1].damage,plane.specs[0].damage*.4),"plane uses corrected rate normalization and weighted loadout")
 s.emit_packet146(plane,s.projectile_origin(),aim,1.)
 verify(is_equal_approx(s.damage_for_shot(s.shots[-1]),plane.specs[-1].damage),"delayed plane emitter does not apply copy gain twice")
 equip168(s,{"three_player":1,"flashlight":1});var stream: Dictionary=s.snapshot_packet146(aim,false,0.,true)
 verify(is_equal_approx(stream.specs[1].damage,stream.specs[0].damage*.4) and stream.specs[1].goose_source168==1,"stream snapshot detects each source despite legacy emitter loop")
 equip168(s,{"forest_fireboy":1,"flashlight":1});s.emit_stream110(aim)
 verify(s.shots.size()==2 and is_equal_approx(s.damage_for_shot(s.shots[1]),s.damage_for_shot(s.shots[0])*.4),"direct continuous stream copies also deal forty percent")
 equip168(s,{"three_player":1,"balloon_sword":1});var sword: Dictionary=s.snapshot_packet146(aim,false,0.,true)
 verify(sword.specs[0].sword153 and is_equal_approx(sword.specs[1].damage,sword.specs[0].damage*.4),"sword shape and weighted damage coexist")
 s.emit_packet146(sword,s.projectile_origin(),aim,1.)
 verify(is_equal_approx(s.damage_for_shot(s.shots[-1]),sword.specs[-1].damage),"sword budget is not multiplied twice on packet delivery")
 s.build168=6;s.apply_paper_build129()
 var start: Vector3=s.goose.position;var head := start
 # Move the actual leader along an L; followers must sample its route, not a side formation.
 for i in 60:
  head=start+Vector3(float(i)*.05,0.,0.);s.goose.position=head;skill.step110(1./60.)
 for i in 60:
  head=start+Vector3(3.,0.,-float(i)*.05);s.goose.position=head;skill.step110(1./60.)
 var p0: Vector3=skill.position_for168(0);var p2: Vector3=skill.position_for168(2)
 verify(p0.z<head.z+.85 and p2.z>p0.z+.8 and absf(p0.x-head.x)<.15,"train preserves ordered arc-length spacing through a corner")
 for i in 30: skill.step110(1./60.)
 verify(skill.geese110[0].position.distance_to(skill.geese110[2].position)>1.,"visible followers settle in a line rather than piling up")
 await capture168("train_turn")
 var path_size: int=skill.path168.size();var frozen: Vector3=skill.geese110[0].position;s.combat_paused=true;skill.step110(.5)
 verify(skill.path168.size()==path_size and skill.geese110[0].position==frozen,"pause freezes trail and goose motion")
 s.combat_paused=false;s.goose.position+=Vector3(20.,0.,0.);skill.step110(.016)
 verify(skill.geese110[0].position.distance_to(s.goose.position)<1.5,"teleport resets the trail and brings followers along")
 s.goose.position=start;s.build168=2;s.apply_paper_build129();skill.step110(.016)
 verify(skill.cluster168 and skill.geese110.size()==3,"boarding changes mode to three extra clustered geese")
 for i in 3: verify(skill.position_for168(i).distance_to(s.goose.position)<.65,"boarding target stays clustered "+str(i))
 await capture168("boarding_cluster")
 var shadows: int=s.actor_shadows.size()
 for index in [0,2,1,6,2]: s.build168=index;s.apply_paper_build129()
 verify(s.actor_shadows.size()==shadows and skill.pool168.size()==3,"switching presets reuses goose actors and their shadows")
 verify(s.buffs.math_scope168==0,"nested snapshot and skill math restores legacy-penalty scope")
 s.hero.set_physics_process(true);s.set_physics_process(true)
 await key153(KEY_F4);await settle72(3);disable_enemies(s);await key153(KEY_5)
 verify(s.paper_trial129 and s.build168==4 and s.buffs.level("paper_plane")==1,"paper encounter and goose-plane comparison keys work")
 await key153(KEY_F5);await settle72(3);disable_enemies(s);await key153(KEY_9)
 verify(not s.paper_trial129 and skill.geese110.is_empty(),"main-only native Tuantuan comparison hides extra geese")
 var report := {"checks":checks,"failures":failures,"damage_ratios":results,"note":"Targeted count/slots, source damage snapshots, train route, cluster, pause/teleport and reuse; status proc strength remains existing behavior."}
 FileAccess.open("res://docs/goose-train168-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("GEESE168_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
