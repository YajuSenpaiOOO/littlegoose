extends "res://scripts/world/web172_probe.gd"
func capture173(tag: String) -> void:
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/web173_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := preload("res://scripts/world/woodland_world173.gd").new();s.memory_save116="user://web173_probe_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.arc_shadows167): await physics_frame
 s.start_spider170();await settle(6)
 var peak := 0;var captured := false
 for i in 960:
  peak=maxi(peak,s.pads172.size())
  if s.pads172.size()==3 and not captured: await capture173("three_regions");captured=true
  await physics_frame
 verify(peak==3,"natural AI can reach the three-pad cap within ten-second lifetimes")
 await restart172(s);s.build170=8;s.apply_paper_build129()
 var g: Vector2=s.meadow.landmarks.grove
 var points := [g,g+Vector2(3.,0.),g+Vector2(0.,-3.)]
 for i in 3:
  var actor: CharacterBody3D=s.enemies[i];var at: Vector2=points[i]
  actor.position=Vector3(at.x,s.floor_height(at)+.06,at.y);actor.reset_physics_interpolation();actor.impulse=Vector2.ZERO;actor.enter170("watch");actor._render_legacy(0.)
 s._teleport15(g+Vector2(0.,5.))
 var e: CharacterBody3D=s.enemies[0];var p: CharacterBody3D=s.place_pad172(e);p.set_physics_process(false)
 verify(Vector2(p.position.x,p.position.z)==Vector2(e.position.x,e.position.z),"web expands exactly around the weaver")
 verify(not p.covers172(p.position),"unfinished web has no slow")
 e.pad172=p;e.enter170("weave");e.clock170=.8;p.build172=.45;e._render_legacy(0.);p.render173()
 await settle(8);await capture173("weaving_center")
 e._physics_process(1.01)
 verify(p.live172 and e.state170=="happy","weaving still activates web then celebrates")
 verify(p.find_children("*","Sprite3D",true,false).is_empty() and p.find_children("*","Area3D",true,false).is_empty() and p.collision_layer==0,"web has no yarn-ball sprite or shootable hit area")
 var pad_center: Vector3=p.position;e.position.x+=.5;verify(p.position==pad_center,"finished web stays in place when spider moves")
 e.position.x-=.5;e.reset_physics_interpolation()
 for i in range(1,3):
  var next: CharacterBody3D=s.place_pad172(s.enemies[i]);next.set_physics_process(false);next.commit172()
 verify(s.pads172.size()==3 and s.place_pad172(e)==null,"manual placement also enforces three-pad cap")
 p.commit172();s.hero.clear_web172();var base: float=s.hero.movement_speed();var rate: float=s.buffs.rate();var hp: float=s.player_hp
 s._teleport15(g+Vector2(1.5,0.));s.hero._physics_process(.016)
 verify(s.pads172[0].covers172(s.hero.position) and s.pads172[1].covers172(s.hero.position),"test point lies inside two overlapping webs")
 verify(is_equal_approx(s.hero.movement_speed(),base*.55) and s.buffs.rate()==rate and s.player_hp==hp,"overlap applies one 45-percent movement slow without HP or attack penalty")
 await settle(4);s.hero.position.x+=.25;await settle(3)
 await capture173("foot_silk")
 verify(s.hero.feet173.visible and s.hero.feet173.threads173.get_surface_count()>0,"web contact draws foot silk feedback")
 var clock: float=p.clock171;var anchor: Vector3=s.hero.feet173.anchor173
 s.combat_paused=true;p._physics_process(.5);s.hero.feet173._process(.5)
 verify(p.clock171==clock and s.hero.feet173.anchor173==anchor,"pause freezes web timer and foot feedback")
 s.combat_paused=false
 s.hero.dash_cd=0.;verify(s.hero.request_dash(Vector2.RIGHT),"dash remains available while slowed")
 s.hero.feet173._process(.016)
 verify(not s.hero.feet173.visible and is_equal_approx(s.hero.dash_speed(),260./s.hero.motion_pixels_per_m),"dash hides silk feedback and retains normal speed")
 s.hero.reset_actions();s._teleport15(g+Vector2(-4.,-4.));s.hero._physics_process(.31);s.hero.feet173._process(.016)
 verify(is_equal_approx(s.hero.movement_speed(),base) and not s.hero.feet173.visible,"leaving clears slow and foot threads")
 s._teleport15(g+Vector2(0.,3.));await settle(3)
 var cursor: Vector2=s.camera.unproject_position(p.position+Vector3.UP*.36);s.aim_tick114=-1;s._refresh_aim114(cursor)
 verify(s.target114!=p and s.pads172.size()==3,"pad is excluded from aim assist and the region list is restored")
 var count: int=s.defeated_count;var old_hp: float=e.hp;s.fire_at(e.position+Vector3.UP*.65)
 for i in 90: s._step_shots(1./60.)
 verify(p.live172 and not p.retired171 and s.pads172.size()==3 and e.hp<old_hp,"real native bullet passes web and damages spider without removing terrain")
 verify(s.defeated_count==count,"shooting through web does not create a fake kill")
 p.clock171=6.1;p._physics_process(.016);verify(not p.retired171,"web remains active beyond the old six-second lifetime")
 p.clock171=9.99;p._physics_process(.02);verify(p.retired171 and not p.covers172(p.position),"web slow expires at ten seconds")
 p._physics_process(.46);verify(not s.pads172.has(p),"expired web fades and releases a region slot")
 s.release_silk171(e,Vector2.DOWN);var ball: CharacterBody3D=s.silk171[-1];ball.set_physics_process(false)
 verify(ball.has_method("defense171") and ball.get_script().resource_path.ends_with("silk_ball172.gd"),"ball still uses validated perfect-defense implementation")
 s._clear_combat_shots()
 verify(s.pads172.is_empty() and s.silk171.is_empty() and s.hero.web_left172==0. and not s.hero.feet173.visible,"build reset clears webs, balls and foot effect")
 var report := {"checks":checks,"failures":failures,"note":"173 changed self-centered, unshootable three-region ten-second webs, 45-percent nonstacking slow, foot feedback and cleanup. 172 defense mechanics retained."}
 FileAccess.open("res://docs/web173-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report," "))
 DirAccess.remove_absolute(ProjectSettings.globalize_path("user://web173_probe_tmp.cfg"));Engine.time_scale=1.;print("WEB173_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
