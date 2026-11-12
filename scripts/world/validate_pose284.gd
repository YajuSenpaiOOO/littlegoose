extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var scene=load("res://scenes/world/world284.tscn").instantiate();root.add_child(scene);current_scene=scene
 for i in 4:await process_frame
 scene.show_stand284();await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://docs/pose284-stand.png")
 scene.show_raise284();await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://docs/pose284-raise.png")
 var before=scene.sprites284[1].position;scene.choose_c284();scene.show_stand284();scene.show_raise284()
 var foot=before==scene.sprites284[1].position and before.y==745.
 var file=FileAccess.open("res://docs/pose284-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify({"root_foot_stable":foot,"visual_acceptance":false,"reason":"local edit; common canvas/anchor/scale; pixel identity not guaranteed; user review pending"},"  "));file.close()
 print("POSE284_FOOT_STABLE ",foot);quit(0 if foot else 1)
