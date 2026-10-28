extends "res://scripts/world/paper_bomb149_probe.gd"
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial149.new();s.memory_save116="user://bomb149_input_tmp.cfg";root.add_child(s)
 while not s.hill_ready146: await physics_frame
 s.hill_visited136=true;s.paper_trial129=true;s.start_combat();disable_enemies(s);s.hero.controls_enabled=true
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(-24,-17));await settle72(30)
 for enemy in s.enemies: enemy.hide();enemy.hit_area.collision_layer=0
 var mark := s.hero.position+Vector3(0,0,-4);mark.y=s.floor_height(Vector2(mark.x,mark.z))+.05
 var m: Node3D=s.paper_memories146
 set146(s,{"paper_plane":1,"homework":1});s.cooldown=.35;s.fire_needs_release=false
 var click := InputEventMouseButton.new();click.button_index=MOUSE_BUTTON_LEFT;click.position=s.camera.unproject_position(mark);click.pressed=true
 Input.parse_input_event(click);await settle72(2)
 verify(m.pending_mark149.is_finite() and m.planes149.is_empty(),"physical ground click immediately shows a waiting marker during cooldown")
 var accepted: Vector3=m.pending_mark149
 var release := InputEventMouseButton.new();release.button_index=MOUSE_BUTTON_LEFT;release.position=click.position;release.pressed=false;Input.parse_input_event(release)
 await settle72(28)
 verify(m.planes149.size()==1 and Vector3(m.planes149[0].mark).distance_to(accepted)<.001 and not m.pending_mark149.is_finite(),"buffered click launches at the accepted ground mark even after mouse release")
 var waits := 0
 while m.history149.is_empty() and waits<120: await settle72(1);waits+=1
 await capture149("flyover")
 await settle72(23);await capture149("falling")
 while m.impacts149==0 and waits<180: await settle72(1);waits+=1
 await capture149("impact")
 verify(m.drops149==3,"one buffered click still produces the three-bomb flyover")
 var f: Dictionary=m.planes149[0];var above: Vector3=m.point149(f,float(f.approach)+float(f.pass_time)*.5)
 var projected: Vector2=s.camera.unproject_position(above)
 verify(not s.camera.is_position_behind(above) and s.camera.is_position_in_frustum(above) and projected.y>30. and projected.y<970.,"wider and raised combat framing keeps the high flyover clear of the image edge")
 FileAccess.open("res://docs/paper-bomb149-input-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"))
 print("PAPER_BOMB149_INPUT_DONE ",JSON.stringify({"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
