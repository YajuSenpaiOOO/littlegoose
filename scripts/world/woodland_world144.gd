extends "res://scripts/world/woodland_world143.gd"
var hill_ready144 := false
var picnic144: Node3D
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 144 · 树荫野餐 / 两盏暖灯 / 看海坐石")
func _ready() -> void:
 super._ready()
 while not hill_ready143: await get_tree().physics_frame
 picnic144=_picnic_script144().new();picnic144.world=self;add_child(picnic144)
 hill_ready144=true;_title35()
 if "--hill144" in OS.get_cmdline_user_args(): _teleport15(Vector2(meadow.landmarks.grove)+Vector2(-19.3,-26.5))
 print("PAPER_HILL144_READY")

func _picnic_script144() -> Script: return preload("res://scripts/art/picnic_hill144.gd")
