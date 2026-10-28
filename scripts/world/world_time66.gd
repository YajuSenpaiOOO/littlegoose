extends "res://scripts/world/world_time65.gd"

func update_guide() -> void:
	super.update_guide()
	var canopy: RefCounted=world.get("canopy66")
	if not is_instance_valid(canopy): return
	guide.text+="\n66：Alt+O 遮挡[%s]\nCtrl+F9 帧率显隐 · Ctrl+F10 清零"%["局部柔边" if canopy.local_enabled else "旧整树淡出"]
