extends "res://scripts/world/forest184_probe.gd"
func run() -> void:
 root.size=Vector2i(1600,1000);var s := Trial184.new();s.memory_save116="user://forest184_capture_tmp.cfg";root.add_child(s)
 while not s.forest_ready184: await physics_frame
 s._teleport15(P.CENTER+Vector2(-10.4,-7.5));await settle(45)
 await shadow_comparison184(s,s.forest184,"cottage")
 s._teleport15(P.CENTER+Vector2(4.,3.));await settle(45)
 await shadow_comparison184(s,s.forest184,"central")
 FileAccess.open("res://docs/forest184-final-visual.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures}," "))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116))
 print("FOREST184_FINAL_CAPTURE_DONE ",JSON.stringify({"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
