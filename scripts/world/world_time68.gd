extends "res://scripts/world/world_time67.gd"

func _guide_suffix67() -> String:
	var lamps: Node3D=world.get("local68")
	if not is_instance_valid(lamps): return ""
	return "\n68：Alt+S 夜间灯影[%s]"%["开" if lamps.enabled else "关"]
