extends "res://scripts/world/woodland_world94.gd"
var woodland_ready95 := false
var effect_scope95: Node
func _forest_script87() -> Script: return preload("res://scripts/art/forest_props95.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time95.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 95 · 林隙花海 / 统一受影 / 周边更新")
func _ready() -> void:
	super._ready()
	while not woodland_ready94: await get_tree().physics_frame
	effect_scope95=preload("res://scripts/art/effect_scope95.gd").new();effect_scope95.world=self;add_child(effect_scope95)
	forest87.scope95=effect_scope95
	woodland_ready95=true;_title35()
	print("WOODLAND95_READY")
