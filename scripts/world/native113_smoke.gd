extends SceneTree
func _initialize() -> void:
 var library=load("res://native/combat113/combat113.gdextension")
 print("NATIVE113_LOAD ",library!=null," class=",ClassDB.class_exists("NativeCombat113"))
 var helper=ClassDB.instantiate("NativeCombat113")
 print("NATIVE113_INSTANCE ",helper!=null)
 quit(0 if helper!=null else 1)
