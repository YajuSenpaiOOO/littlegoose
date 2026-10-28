extends "res://scripts/world/paper_hill145_probe.gd"
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Current145.new();s.memory_save116="user://hill145_coast_tmp.cfg";root.add_child(s)
 while not s.hill_ready145: await physics_frame
 s.hill_visited136=true;disable_enemies(s)
 var g: Vector2=s.meadow.landmarks.grove
 for hour in [16.,18.]:
  s.time55.preview_at(hour);s.time55.visual_hour=hour;s.time55.apply_look()
  await shot145(s,g+Vector2(-31.,-17.),"coast_afternoon" if hour==16. else "coast_dusk")
 print("COAST145_VISUAL_DONE")
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));quit()
