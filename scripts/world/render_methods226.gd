extends SceneTree
func _initialize() -> void:
 for method in RenderingServer.get_method_list():
  if "profil" in str(method.name) or "time" in str(method.name):print(method.name)
 quit()
