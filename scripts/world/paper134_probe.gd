extends "res://scripts/world/combat111_probe.gd"
class Sample:
 extends "res://scripts/world/woodland_world134.gd"
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Sample.new();s.memory_save116="user://paper134_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not is_instance_valid(s.drops120): await physics_frame
 s.paper_trial129=true;s.start_combat();disable_enemies(s);s.hero.set_physics_process(false)
 var a: CharacterBody3D=s.enemies[0]
 for other in s.enemies:
  if other!=a: other.hide();other.collision_layer=0;other.hit_area.collision_layer=0
 verify(a.art134.size()==9,"selected C base, four flutter keys and four attack keys load")
 var keys := {}
 a.paper_state129="drift"
 for i in 6:
  a.age=float(i)*.341;a._render_legacy(.8);keys[a.pose_key134]=true
 verify(keys.size()==4,"gentle flutter cycles through all four authored key poses")
 a.paper_state129="warning";a.paper_clock129=.2;a._render_legacy(.8)
 var size: float=a.visual.pixel_size
 verify(a.pose_key134=="attack0","warning starts with the happy closed-eye face")
 a.paper_clock129=.5;a._render_legacy(.8)
 verify(a.pose_key134=="attack1","late warning begins filling the paper with wind")
 a.paper_state129="gust";a._render_legacy(.8)
 verify(a.pose_key134=="attack2" and absf(a.visual.pixel_size-size)<.00001,"gust uses the drawn domed canopy without scaling the sprite pixels larger")
 verify(float(a.animation134.attack[2].visible_width)>float(a.animation134.attack[0].visible_width),"canopy expansion is in the authored paper silhouette")
 verify(a.soft_ink.get_shader_parameter("art")==a.visual.texture,"soft-body and lighting sample the current animated frame")
 verify(absf(a.hit_area.position.y-1.52)<.001 and (a.collision_mask&16)==0,"animation preserves floating hit alignment and peer pass-through")
 a.paper_state129="coast";a.paper_clock129=.2;a._render_legacy(.8)
 verify(a.pose_key134=="attack3","coasting unfolds back to the normal expression")
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(0.,3.));await settle72(10)
 a.position=Vector3(s.hero.position.x,s.floor_height(Vector2(s.hero.position.x,s.hero.position.z-3.))+.05,s.hero.position.z-3.);a.paper_state129="gust";a.paper_clock129=.3;a.paper_lift129=.7;a._render_legacy(.7);a.velocity=Vector3.ZERO;a.hp=100.;a.max_hp110=100.
 var hp: float=a.hp;s.paper_build129=0;s.apply_paper_build129();s.fire_at(a.hit_area.global_position);await settle72(45)
 verify(a.hp<hp,"native projectile still hits the bulging attack pose")
 a.hit_left=0.;a.flash=0.;a._render_legacy(.7);a.visual.reset_physics_interpolation()
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/paper134_canopy.png")
 a.play119();a.gust_wait130=0.;a.position=Vector3(g.x-2.5,s.floor_height(g+Vector2(-2.5,0))+.05,g.y);a.set_physics_process(true)
 var seen := {}
 for i in 180:
  await physics_frame;seen[a.pose_key134]=true
 verify(seen.has("attack0") and seen.has("attack1") and seen.has("attack2") and seen.has("attack3"),"real AI automatically plays preparation, filling, canopy and release")
 a.set_physics_process(false);a.paper_state129="drift";a.hit_left=0.;a._render_legacy(1.);a.visual.reset_physics_interpolation()
 picture=await snapshot();picture.save_png("res://docs/captures/world_restart/paper134_flutter.png")
 s.home116();await settle72(2)
 var data := {"checks":checks,"failures":failures,"poses":seen.keys()}
 FileAccess.open("res://docs/paper134-validation.json",FileAccess.WRITE).store_string(JSON.stringify(data,"\t"))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("PAPER134_DONE ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
