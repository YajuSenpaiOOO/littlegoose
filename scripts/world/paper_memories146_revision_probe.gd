extends "res://scripts/world/paper_memories146_probe.gd"
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Current146.new();s.memory_save116="user://notes146_revision_tmp.cfg";root.add_child(s)
 while not s.hill_ready146: await physics_frame
 s.hill_visited136=true;s.paper_trial129=true;s.start_combat();disable_enemies(s)
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(-24.,-17.));await settle72(5)
 for enemy in s.enemies: enemy.hit_area.collision_layer=0;enemy.hide()
 var target: CharacterBody3D=s.enemies[0]
 target.show();target.hit_area.collision_layer=8;target.hp=10000.;target.max_hp110=10000.
 target.position=s.hero.position+Vector3(0,0,-4.);target.position.y=s.floor_height(Vector2(target.position.x,target.position.z))+.06
 s.aim146=target.hit_area.global_position;s.rebuild_cells110()
 set146(s,{"paper_plane":1,"homework":1});s.paper_memories146.flight_rng146.seed=20261024
 for i in 8: s.fire_at(s.aim146)
 var manager: Node3D=s.paper_memories146;var signatures := {};var sides := {}
 var bounded := true;var endpoints := true
 for flight in manager.flights146:
  signatures[str(flight.height)+str(flight.pace)]=true
  bounded=bounded and absf(flight.bend)>=.45 and absf(flight.bend)<=1.45
  sides[signf(float(flight.bend))]=true
  endpoints=endpoints and manager.flight_point146(flight,0.).is_equal_approx(flight.start) and manager.flight_point146(flight,1.).is_equal_approx(flight.arrival)
 verify(signatures.size()==8 and bounded and sides.size()==2,"successive flights vary height, pacing and turn side inside bounded arcs")
 verify(endpoints,"varied curves still begin at the goose and finish exactly at delivery")
 var f: Dictionary=manager.flights146[0];var old_lock: Vector3=f.lock
 target.position.x+=1.;s.rebuild_cells110();await settle72(2)
 var adjusted: Vector3=manager.delivery_target146(f.arrival,old_lock)
 verify(adjusted.is_equal_approx(target.hit_area.global_position),"delivery corrects for an enemy drifting away from the old aim point")
 target.position.x+=5.;s.rebuild_cells110();await settle72(2)
 verify(manager.delivery_target146(f.arrival,old_lock).is_equal_approx(old_lock),"delivery does not retarget enemies outside the local 2.4m area")
 s._clear_combat_shots();target.position.x-=6.;s.aim146=target.hit_area.global_position;s.rebuild_cells110()
 var hp: float=target.hp;s.fire_at(s.aim146);await settle72(12);target.position.x+=.8;s.rebuild_cells110();await settle72(95)
 verify(target.hp<hp,"corrected payload hits a real native target after it has moved during flight")
 verify(manager.pages146.size()==1,"delivery correction does not create additional recorded notes")
 verify(s.memory_kit116.card("homework").name=="我的课堂笔记" and s.memory_kit116.owned.homework>=1,"new classroom-note name preserves existing ownership and save identity")
 s._clear_combat_shots();s.home116()
 FileAccess.open("res://docs/paper-memories146-revision-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"))
 print("NOTES146_REVISION_DONE ",JSON.stringify({"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
