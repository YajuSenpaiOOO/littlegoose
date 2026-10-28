extends "res://scripts/world/world_time59.gd"

func update_guide() -> void:
	super.update_guide()
	var study: Node3D=world.get("bridge59")
	if not is_instance_valid(study): return
	guide.text+="\n60：换桥保留水色 · 水位降低0.4m\nAlt+G 波光[%s] · Alt+M 流动[%s]"%["开" if study.sparkling else "关","开" if study.moving else "停"]
