extends "res://scripts/world/balloon_sword153_probe.gd"
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial153.new();s.memory_save116="user://sword153_visual_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.swords153): await physics_frame
 s.hill_visited136=true;s.trial152=true;s.paper_trial129=false;s.start_combat();disable_enemies(s);s.clear_standby119();s.hero.controls_enabled=true
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(0,4));await settle72(15)
 for e in s.enemies: e.hide();e.hit_area.collision_layer=0
 s.build153=1;s.apply_paper_build129()
 var mark: Vector3=s.hero.position+Vector3(0,0,-4.);mark.y=s.floor_height(Vector2(mark.x,mark.z))+.05;s.aim153=mark
 s.fire_at(mark);await settle72(200)
 for entry in s.swords153.resting153:
  print("GROUND153 at=",entry.offset," floor=",s.floor_height(Vector2(entry.offset.x,entry.offset.z))," sprite=",entry.node.position)
 await capture153("ground_empty")
 s._clear_combat_shots()
 for x in [-2.,0.,2.]:
  var at := s.hero.position+Vector3(x,0,-4);at.y=s.floor_height(Vector2(at.x,at.z))+.08
  s.swords153.attach153(null,at,Vector3.DOWN)
 await settle72(20);await capture153("ground_fixture")
 s._clear_combat_shots();var e: CharacterBody3D=s.enemies[0];e.show();e.position=mark;e.hit_area.collision_layer=8;e.hp=10000.;e.max_hp110=10000.;keep153(e);s.rebuild_cells110()
 s.fire_at(mark);await advance153(e,190);await capture153("stuck_fan")
 # Check that the fragment is actually usable through the notebook, not only presets.
 s.home116();await settle72(5);s.open_memory116();await process_frame;s.memory_ui116.select116("balloon_sword");s.memory_ui116.switch118("equip");s.memory_ui116.working.clear();s.memory_ui116.add_one118()
 verify(s.memory_ui116.working.has("balloon_sword") and s.memory_kit116.call("valid",s.memory_ui116.working,s.memory_ui116.working_owned),"new sword can be selected and equipped in the actual notebook")
 await capture153("notebook");s.close_memory116(false)
 print("SWORD153_VISUAL_DONE failures=",failures);quit(0 if failures.is_empty() else 1)
