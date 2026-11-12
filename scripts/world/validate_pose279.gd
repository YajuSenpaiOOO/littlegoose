extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var scene=load("res://scenes/world/world279.tscn").instantiate();root.add_child(scene);current_scene=scene
 for i in 4:await process_frame
 scene.show_stand279();await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://docs/pose279-stand.png")
 scene.show_raise279();await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://docs/pose279-raise.png")
 var before=scene.sprites279[1].position;scene.choose_c279();scene.show_stand279();scene.show_raise279()
 var foot=before==scene.sprites279[1].position and before.y==745.
 var file=FileAccess.open("res://docs/pose279-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify({"root_foot_stable":foot,"visual_acceptance":false,"reason":"hard-cut and overlay review only; independent drawings remain different"},"  "));file.close()
 print("POSE279_FOOT_STABLE ",foot);quit(0 if foot else 1)
