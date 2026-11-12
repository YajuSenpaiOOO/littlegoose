extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var scene=load("res://scenes/world/world283.tscn").instantiate();root.add_child(scene);current_scene=scene
 for i in 4:await process_frame
 scene.show_stand283();await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://docs/pose283-stand.png")
 scene.show_raise283();await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://docs/pose283-raise.png")
 var before=scene.sprites283[1].position;scene.choose_c283();scene.show_stand283();scene.show_raise283()
 var foot=before==scene.sprites283[1].position and before.y==745.
 var file=FileAccess.open("res://docs/pose283-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify({"root_foot_stable":foot,"visual_acceptance":false,"reason":"local edit; common canvas/anchor/scale; pixel identity not guaranteed; user review pending"},"  "));file.close()
 print("POSE283_FOOT_STABLE ",foot);quit(0 if foot else 1)
