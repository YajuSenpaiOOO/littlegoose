extends "res://scripts/world/paper_hill137_probe.gd"
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Sample.new();s.memory_save116="user://hill137_render_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not s.hill_ready137: await physics_frame
 s.hill_visited137=true;s.hero.controls_enabled=false;s.combat_paused=false;disable_enemies(s)
 var g: Vector2=s.meadow.landmarks.grove
 s._teleport15(g+Vector2(-7.8,1.8));await picture137(s,"entrance")
 s._teleport15(g+Vector2(-40.,-18.));await picture137(s,"headland")
 s.paper_trial129=true;s.start_combat();disable_enemies(s);await picture137(s,"paper")
 s.home116();await settle72(2)
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("PAPER_HILL137_RENDER_DONE");quit()
