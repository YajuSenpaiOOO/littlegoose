extends "res://scripts/world/paper_hill144_probe.gd"
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Current144.new();s.memory_save116="user://hill144_visual_tmp.cfg";root.add_child(s)
 while not s.hill_ready144: await physics_frame
 s.hill_visited136=true;disable_enemies(s)
 var g: Vector2=s.meadow.landmarks.grove;s.camera_distance=11.
 s.time55.preview_at(12.);s.time55.visual_hour=12.;s.time55.apply_look()
 await shot144(s,g+s.picnic144.PICNIC144+Vector2(-1.8,1.45),"picnic_day")
 s.time55.preview_at(20.);s.time55.visual_hour=20.;s.time55.apply_look()
 await shot144(s,g+s.picnic144.PICNIC144+Vector2(-1.8,1.45),"picnic_night")
 print("PICNIC144_FINAL_VISUAL_DONE")
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));quit()
