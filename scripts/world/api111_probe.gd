extends SceneTree
func _initialize() -> void:
 for entry in ClassDB.class_get_method_list("RenderingServer"):
  if entry.name=="canvas_item_add_triangle_array": print(JSON.stringify(entry))
 quit()
