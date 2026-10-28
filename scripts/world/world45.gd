extends "res://scripts/world/world44.gd"

func _garden_script() -> Script:
	return preload("res://scripts/art/kitchen_garden45.gd")

func _ready() -> void:
	super._ready()
	while not is_instance_valid(garden): await get_tree().physics_frame
	_title35()
	print("WORLD45_PAINTED_MATERIALS_READY")

func _title35() -> void:
	var stage := 1
	var shadow := true
	if is_instance_valid(garden): stage=garden.material_stage; shadow=garden.shadows_enabled
	DisplayServer.window_set_title("小白鹅 · 小院材质45 · %s · 摆件影%s · Ctrl+T 材质 / Ctrl+H 影子"%[["原材质","手绘木纹","手绘木纹＋石面"][stage],"开" if shadow else "关"])

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and is_instance_valid(garden):
		if event.physical_keycode==KEY_T:
			garden.set_material_stage((garden.material_stage+1)%3)
			_title35()
			return
		if event.physical_keycode==KEY_H:
			garden.set_shadows(not garden.shadows_enabled)
			_title35()
			return
	super._unhandled_input(event)

func _status() -> void:
	super._status()
	if world_ready:
		label.text=label.text.replace("连续世界44","连续世界45")
		label.text+="\nCtrl+T 材质：原版 → 手绘木纹 → 木纹＋石面 · Ctrl+H 新增摆件影 · Ctrl+F3 菜园"
