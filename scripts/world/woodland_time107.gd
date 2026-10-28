extends "res://scripts/world/woodland_time106.gd"
func update_guide() -> void:
 super.update_guide()
 if is_instance_valid(guide): guide.text=guide.text.replace("106：","107：")+"\nCtrl+Alt+F8 林下草带对照"
