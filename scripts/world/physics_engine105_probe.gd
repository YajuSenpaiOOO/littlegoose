extends SceneTree
func _initialize() -> void:
 print("PHYSICS105 setting=",ProjectSettings.get_setting("physics/3d/physics_engine")," active=",PhysicsServer3D.get_class())
 for name in ClassDB.get_class_list():
  if "Jolt" in name: print("AVAILABLE105 ",name)
 quit()
