extends "res://scripts/world/silk171_probe.gd"
func capture172(tag: String) -> void:
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/web172_"+tag+".png")
func restart172(s: Node3D) -> void:
 s.start_spider170();freeze171(s);s.set_physics_process(true);s.hero.set_physics_process(false);s.hero.controls_enabled=false;Engine.time_scale=1.
 # Let the normal 0.8-second spawn protection expire; do not override immunity.
 await settle(65)
 s.set_physics_process(false);s.hero.controls_enabled=true
func ball172(s: Node3D,offset: Vector2,direction: Vector2) -> CharacterBody3D:
 s.release_silk171(s.enemies[0],direction)
 var b: CharacterBody3D=s.silk171[-1];b.set_physics_process(false)
 b.position=s.hero.position+Vector3(offset.x,0.,offset.y);b.previous172=b.position;b.reset_physics_interpolation();return b
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := preload("res://scripts/world/woodland_world172.gd").new();s.memory_save116="user://web172_probe_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.arc_shadows167): await physics_frame
 s.start_spider170();await settle(6)
 verify(s.paper_memories146.plane_texture146.get_width()>0 and s.paper_memories146.book_texture146.get_width()>0,"imported plane and notebook images load")
 verify(s.swords153.texture153.get_width()>0 and s.swords153.pad_texture158.get_width()>0 and s.pillow160.visual160.texture.get_width()>0,"imported sword, gel and pillow images load")
 verify(s.hero.has_method("clear_web172"),"latest hero injection includes terrain slow and ball dodge")
 var seen := {};var peak := 0;var captured := false
 for i in 660:
  for actor in s.enemies:
   seen[actor.state170]=true
   if actor.state170=="happy" and not captured: await capture172("natural_happy");captured=true
  peak=maxi(peak,s.pads172.size());await physics_frame
 verify(seen.has("weave") and seen.has("happy") and seen.has("winding"),"natural AI alternates weaving, celebration and silk balls")
 verify(peak>0 and peak<=2,"natural live pad budget stays at two")
 await restart172(s);s.build170=8;s.apply_paper_build129()
 var g: Vector2=s.meadow.landmarks.grove;var e: CharacterBody3D=s.enemies[0]
 s._teleport15(g+Vector2(0.,5.));e.position=Vector3(g.x,s.floor_height(g)+.06,g.y);e.reset_physics_interpolation();e.impulse=Vector2.ZERO
 var p: CharacterBody3D=s.place_pad172(e);p.set_physics_process(false)
 verify(is_instance_valid(p) and Vector2(p.position.x-s.hero.position.x,p.position.z-s.hero.position.z).length()>=3.19,"pad warns away from player feet")
 verify(not p.covers172(p.position),"unfinished weaving cannot slow the player")
 e.pad172=p;e.enter170("weave");e.clock170=.8;p.build172=.45;e._render_legacy(0.);p._render_legacy(0.)
 await settle(8);await capture172("weaving")
 e._physics_process(1.01);p._render_legacy(0.)
 verify(p.live172 and e.state170=="happy","finished weave activates pad and celebration")
 var lifts: Array[float]=[]
 for i in 4: e._physics_process(.212);lifts.append(e.lift170)
 verify(lifts[0]>.25 and lifts[1]<.02 and lifts[2]>.25 and lifts[3]<.03,"celebration contains two small hops")
 e.enter170("happy");e.clock170=.21;e.lift170=.28;e._render_legacy(.28)
 await capture172("happy_mat")
 verify(p.covers172(p.position+Vector3(2.35,0.,0.)) and not p.covers172(p.position+Vector3(2.45,0.,0.)),"large pad radius is 2.4m")
 s.hero.clear_web172();var base: float=s.hero.movement_speed();var rate: float=s.buffs.rate();var hp: float=s.player_hp
 s._teleport15(Vector2(p.position.x,p.position.z));s.hero._physics_process(.016)
 verify(is_equal_approx(s.hero.movement_speed(),base*.75) and s.buffs.rate()==rate and s.player_hp==hp,"pad only slows movement by 25 percent without damage or attack slow")
 s._teleport15(Vector2(p.position.x+4.,p.position.z));s.hero._physics_process(.31)
 verify(is_equal_approx(s.hero.movement_speed(),base),"leaving pad clears slow after 0.3 seconds")
 s.hero.clear_web172();s.hero.dash_cd=0.;s.hero.request_dash(Vector2.RIGHT)
 verify(is_equal_approx(s.hero.dash_speed(),260./s.hero.motion_pixels_per_m),"web does not change dash speed")
 s.hero.reset_actions()
 var age: float=p.clock171;s.combat_paused=true;p._physics_process(.5);verify(p.clock171==age,"pause freezes pad lifetime");s.combat_paused=false
 s._teleport15(Vector2(p.position.x,p.position.z+3.));await settle(3)
 var aim_cursor: Vector2=s.camera.unproject_position(p.hit_area.global_position);s.aim_tick114=-1;s._refresh_aim114(aim_cursor)
 verify(s.target114==p and s.enemies.size()==3,"web knot receives aim assistance without changing actor count")
 var count: int=s.defeated_count;s.fire_at(p.hit_area.global_position)
 for i in 90: s._step_shots(1./60.)
 verify(p.retired171 and not s.on_web172(p.position) and s.defeated_count==count,"real native bullet removes web slow without spider kill")
 s._clear_combat_shots();e.position=Vector3(g.x,s.floor_height(g)+.06,g.y);s._teleport15(g+Vector2(0.,5.));p=s.place_pad172(e);p.set_physics_process(false);p.commit172();p.clock171=5.99;p._physics_process(.02)
 verify(p.retired171 and p.reason171=="timeout","pad lasts six seconds and expires")
 await restart172(s)
 var b: CharacterBody3D=ball172(s,Vector2(0.,1.2),Vector2.UP)
 var parries: int=s.parry_count;hp=s.player_hp
 verify(s.hero.request_parry(),"real fresh guard opens parry window")
 b._physics_process(.016)
 verify(b.reason171=="parry" and s.parry_count==parries+1 and s.hero.parried and s.player_hp==hp,"ball parry consumes window, counts success and preserves HP")
 var b2 := ball172(s,Vector2(0.,1.2),Vector2.UP);b2._physics_process(.016)
 verify(s.parry_count==parries+1,"same held parry cannot farm more successes")
 await capture172("parry")
 await restart172(s);b=ball172(s,Vector2(.7,0.),Vector2.LEFT);var dodges: int=s.perfect_dodges;hp=s.player_hp
 verify(s.hero.request_dash(Vector2.RIGHT),"real dash request accepted")
 s.hero._physics_process(.016)
 verify(s.perfect_dodges==dodges+1 and s.hero.dodge_invulnerability>=.49 and s.player_hp==hp,"near-ball dash gets standard perfect-dodge reward")
 s.hero._physics_process(.016);verify(s.perfect_dodges==dodges+1,"perfect dodge rewards once per dash")
 await capture172("perfect_dodge")
 await restart172(s);dodges=s.perfect_dodges;e=s.enemies[0];e.position=s.hero.position+Vector3(.4,0.,0.);e.enter170("weave")
 s.hero.request_dash(Vector2.RIGHT);s.hero._physics_process(.016)
 verify(s.perfect_dodges==dodges,"harmless weaving body cannot farm perfect dodge")
 await restart172(s);b=ball172(s,Vector2(0.,.5),Vector2.UP);hp=s.player_hp;b._physics_process(.016)
 verify(s.player_hp==hp-10. and b.retired171,"unprotected contact still takes real ten damage")
 var after: float=s.player_hp;b._physics_process(.016);verify(s.player_hp==after,"same ball cannot deal a second hit")
 await restart172(s);e=s.enemies[0];s._teleport15(g+Vector2(0.,5.));e.position=Vector3(g.x,s.floor_height(g)+.06,g.y);p=s.place_pad172(e);p.set_physics_process(false);e.receive_hit(999.,Vector3.RIGHT);p._physics_process(.016)
 verify(not s.pads172.has(p),"defeated weaver cancels unfinished pad")
 s._clear_combat_shots();verify(s.pads172.is_empty() and s.silk171.is_empty() and s.hero.web_left172==0.,"reset clears all hostile props and terrain slow")
 var report := {"checks":checks,"failures":failures,"note":"Imported runtime textures, natural weaving, large terrain mat, real native knot destruction, slow/dash boundary, parry and perfect dodge through real action requests."}
 FileAccess.open("res://docs/web172-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report," "))
 DirAccess.remove_absolute(ProjectSettings.globalize_path("user://web172_probe_tmp.cfg"));Engine.time_scale=1.;print("WEB172_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
