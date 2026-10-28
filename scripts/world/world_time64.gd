extends "res://scripts/world/world_time63.gd"

func _ready() -> void:
	super._ready()
	world.atmosphere41.focus_material.shader=preload("res://scripts/art/scenic_day64.gdshader")
	world.atmosphere41._set_focus_level(world.atmosphere41.focus_level)

func update_guide() -> void:
	super.update_guide()
	var study: Node3D=world.get("landmark62")
	if not is_instance_valid(study): return
	guide.text+="\n64：Ctrl+F8 近看树根\nAlt+J 树下小景[%s]\nAlt+Y 整段根部接地[%s]"%["开" if study.understory_enabled else "关","开" if study.seated_roots else "关"]
