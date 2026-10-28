extends "res://scripts/world/world_time64.gd"

func update_guide() -> void:
	super.update_guide()
	var lake: Node3D=world.get("bridge59")
	if not is_instance_valid(lake): return
	guide.text=guide.text.replace("水波/波光默认关","65：根部碰撞 / 行走优化")
	guide.text+="\nAlt+M 水波[%s] · Alt+G 波光[%s]"%["开" if lake.moving else "关","开" if lake.sparkling else "关"]
