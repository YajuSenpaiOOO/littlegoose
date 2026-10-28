extends SceneTree
func _initialize() -> void:
 for entry in ClassDB.class_get_method_list("RenderingServer"):
  if str(entry.name).contains("render_time") or str(entry.name).contains("rendering_info"):
   print(JSON.stringify(entry))
 quit()
