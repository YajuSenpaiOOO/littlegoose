extends "res://scripts/world/forest186_probe.gd"
func run() -> void:
 root.size=Vector2i(1600,1000);var s := Trial186.new();s.memory_save116="user://forest186_capture_tmp.cfg";root.add_child(s)
 while not s.forest_ready186: await physics_frame
 s._teleport15(P.CENTER+Vector2(-10.4,-7.5));await settle(100);await compare186(s,"cottage")
 s._teleport15(P.CENTER+Vector2(4.,3.));await settle(100);await compare186(s,"central")
 s.forest186.set_grounding184(false);await settle(3);await shot("central_shadow_off")
 s.forest186.set_grounding184(true);await settle(3);await shot("central_shadow_on")
 s._teleport15(P.CENTER+P.PATH[2]);await settle(150);await shot("stairs_transition")
 s._teleport15(Vector2(-4.7,-2.6));await settle(180);await shot("home")
 verify(s.forest_mood186.amount<.001,"home resets forest grade after soft foreground fade")
 FileAccess.open("res://docs/forest186-final-visual.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures}," "))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("FOREST186_FINAL_DONE ",JSON.stringify({"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
