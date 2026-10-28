extends "res://scripts/world/world_time59.gd"

func _ready() -> void:
	super._ready()
	world.atmosphere41.focus_material.shader=preload("res://scripts/art/scenic_day62.gdshader")
	world.atmosphere41._set_focus_level(world.atmosphere41.focus_level)

func update_guide() -> void:
	# Keep the time/lighting controls, replacing the old bridge comparison hints.
	super.update_guide()
	guide.text=guide.text.get_slice("\nAlt+5",0)
	var study: Node3D=world.get("landmark62")
	if not is_instance_valid(study): return
	guide.text+="\n62：Alt+5 古橡 / 6 银柳 / 7 花树\nAlt+8 旧树 · Alt+N 手绘/3D路牌\nCtrl+F5 古树全貌 · WASD退出全貌\nCtrl+F7 近看路牌 · Ctrl+F6 去桥\n当前：%s · %s\n绘本水保留 · 水波/波光默认关"%["旧占位树" if study.old_tree else study.LABELS[study.variant],"手绘路牌" if study.painted_sign else "原3D路牌"]
