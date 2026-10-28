extends "res://scripts/world/combat111_probe.gd"
class Sample:
 extends "res://scripts/world/woodland_world135.gd"
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Sample.new();s.memory_save116="user://paper135_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not is_instance_valid(s.drops120): await physics_frame
 s.paper_trial129=true;s.start_combat();disable_enemies(s);s.hero.set_physics_process(false)
 var a: CharacterBody3D=s.enemies[0]
 for other in s.enemies:
  if other!=a: other.hide();other.collision_layer=0;other.hit_area.collision_layer=0
 verify(a.right_art135.size()==4,"four authored rightward attack frames load")
 var screen: Vector3=s.camera.global_basis.x;screen.y=0.;screen=screen.normalized()
 a.paper_direction129=Vector2(screen.x,screen.z);a.paper_state129="warning";a.paper_clock129=.5;a._render_legacy(.8)
 verify(a.face_right135 and a.visual.texture==a.right_art135[1],"camera projected rightward warning uses rightward filling")
 a.paper_state129="gust";a.paper_direction129=-a.paper_direction129;a._render_legacy(.8)
 verify(a.face_right135 and a.visual.texture==a.right_art135[2],"curved gust retains its locked facing")
 a.paper_state129="coast";a._render_legacy(.8);a.paper_state129="warning";a._render_legacy(.8)
 verify(not a.face_right135 and a.visual.texture==a.left_art135[1],"next leftward attack selects the original art")
 a.paper_state129="drift";a._render_legacy(.8)
 verify(a.pose_key134.begins_with("drift") and not a.visual.flip_h,"idle flutter retains the original C identity")
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(0.,3.));await settle72(10)
 a.position=Vector3(s.hero.position.x,s.floor_height(Vector2(s.hero.position.x,s.hero.position.z-3.))+.05,s.hero.position.z-3.)
 a.paper_direction129=Vector2(screen.x,screen.z);a.paper_state129="warning";a._render_legacy(.8);a.paper_state129="gust";a._render_legacy(.8)
 a.visual.reset_physics_interpolation()
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/paper135_right.png")
 a.paper_lift129=.8;a.receive_hit(10000.,Vector3.RIGHT)
 verify(a.dead and a.visual.texture.resource_path=="res://assets/paper135/defeat.png","lethal hit selects the authored flat defeated paper")
 a.set_physics_process(false);a.set_process(false)
 a.defeat_age=.1;a._render_legacy(.55);var high: float=a.visual.position.y
 a.defeat_age=.6;a._render_legacy(0.)
 verify(high>.4 and absf(a.visual.position.y)<.001 and a.visual.scale==Vector3.ONE,"defeated paper settles at ground anchor without balloon squash")
 verify(a.soft_ink.get_shader_parameter("art")==a.visual.texture,"death silhouette and shader follow the flat paper")
 a.visual.reset_physics_interpolation();picture=await snapshot();picture.save_png("res://docs/captures/world_restart/paper135_defeat.png")
 a.corpse_time=3.2;a._process(0.)
 var tint: Color=a.soft_ink.get_shader_parameter("tint")
 verify(tint.a<1. and tint.a>0.,"flat paper inherits gradual corpse fade")
 a.corpse_time=4.1;a._process(0.);await process_frame
 verify(not is_instance_valid(a),"faded paper removes itself from the encounter")
 s.home116();await settle72(2)
 FileAccess.open("res://docs/paper135-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("PAPER135_DONE ",JSON.stringify({"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
