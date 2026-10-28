extends SceneTree
func _initialize() -> void: run.call_deferred()
func run() -> void:
 root.size=Vector2i(1600,1000);var s := preload("res://scripts/world/woodland_world181.gd").new();s.memory_save116="user://forest181_capture_tmp.cfg";root.add_child(s)
 while not s.forest_ready181: await physics_frame
 for i in 30: await physics_frame
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/forest181_sample_final.png")
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("FOREST181_FINAL_CAPTURE");quit()
