extends "res://scripts/world/silk171_probe.gd"
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := preload("res://scripts/world/woodland_world171.gd").new();s.memory_save116="user://silk171_visual_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.arc_shadows167): await physics_frame
 s.spider_count170=1;s.build170=8;s.start_spider170();freeze171(s);s.set_physics_process(false);s.hero.set_physics_process(false);s.hero.controls_enabled=false
 var g: Vector2=s.meadow.landmarks.grove;var e: CharacterBody3D=s.enemies[0]
 s._teleport15(g+Vector2(2.,3.));e.position=Vector3(g.x,s.floor_height(g)+.06,g.y);e.reset_physics_interpolation();e.impulse=Vector2.ZERO
 e.prepare170(g+Vector2(0.,4.));e.clock170=.6;e._render_legacy(0.)
 await settle(24);await capture171("winding")
 e.enter170("push");e.clock170=.13;e._render_legacy(0.);s.release_silk171(e,e.attack_direction)
 var ball: CharacterBody3D=s.silk171[0];ball.set_physics_process(false);ball.position.z+=1.;ball.reset_physics_interpolation();ball.travelled171=1.;ball._render_legacy(0.)
 await settle(3);await capture171("push")
 e.enter170("sit");e.clock170=.4;e._render_legacy(0.)
 await settle(3);await capture171("sit")
 ball.retire171("shot");ball.fade171=.23;ball._render_legacy(0.)
 await settle(3);await capture171("unravel")
 s.clear_silk171();DirAccess.remove_absolute(ProjectSettings.globalize_path("user://silk171_visual_tmp.cfg"));print("SILK171_VISUAL_DONE");quit()
