extends SceneTree
func _initialize() -> void: run.call_deferred()
func shot(tag: String) -> void:
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/forest182_"+tag+"_final.png")
func run() -> void:
 root.size=Vector2i(1600,1000);var s := preload("res://scripts/world/woodland_world182.gd").new();s.memory_save116="user://forest182_capture_tmp.cfg";root.add_child(s)
 while not s.forest_ready182: await physics_frame
 for i in 30: await physics_frame
 await shot("sample")
 s._teleport15(Vector2(-48.,15.5))
 for i in 30: await physics_frame
 await shot("south")
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("FOREST182_CAPTURE_DONE");quit()
