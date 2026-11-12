extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var scene=load("res://scenes/world/world280.tscn").instantiate();root.add_child(scene);current_scene=scene
 for i in 4:await process_frame
 scene.show_stand280();await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://docs/pose280-stand.png")
 scene.show_raise280();await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://docs/pose280-raise.png")
 var before=scene.sprites280[1].position;scene.choose_c280();scene.show_stand280();scene.show_raise280()
 var foot=before==scene.sprites280[1].position and before.y==745.
 var file=FileAccess.open("res://docs/pose280-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify({"root_foot_stable":foot,"visual_acceptance":false,"reason":"local edit; common canvas/anchor/scale; pixel identity not guaranteed; user review pending"},"  "));file.close()
 print("POSE280_FOOT_STABLE ",foot);quit(0 if foot else 1)
