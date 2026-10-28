extends "res://scripts/world/world_time60.gd"

func update_guide() -> void:
	super.update_guide()
	var study: Node3D=world.get("bridge59")
	if not is_instance_valid(study): return
	guide.text+="\n61：绳桥＋绘本水 · Alt+V 远水柔光[%s]"%["开" if study.distant_glow else "关"]
