extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 await process_frame
 print("VIEWPORT223 size=",root.size," logical=",root.get_visible_rect()," stretch=",root.get_stretch_transform()," final=",root.get_final_transform())
 quit()
