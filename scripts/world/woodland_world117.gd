extends "res://scripts/world/woodland_world116.gd"
var woodland_ready117 := false
var candy117: Control
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 117 · 像素百宝盒 / 棒棒糖轻瞄准")
func _workshop_script116() -> Script: return preload("res://scripts/art/memory_workshop117.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time117.gd")
func _candy_script117() -> Script: return preload("res://scripts/combat/candy_aim117.gd")
func _ready() -> void:
 super._ready()
 while not woodland_ready116: await get_tree().physics_frame
 var layer := CanvasLayer.new();layer.layer=28;add_child(layer)
 candy117=_candy_script117().new();candy117.battle=self;layer.add_child(candy117)
 woodland_ready117=true;time55.update_guide();_title35();print("WOODLAND117_READY")
