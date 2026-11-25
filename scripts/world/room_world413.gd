extends "res://scripts/world/room_world412.gd"
func yard_script403() -> Script:return preload("res://scripts/room/home_yard413.gd")
func apply_zone410() -> void:
 super.apply_zone410()
 if ready410 and is_instance_valid(yard403.inside_roof413):
  room.roof402.hide();room.frame399.hide();yard403.inside_roof413.visible=inside403
func _ready() -> void:
 await super._ready()
 apply_zone410()
 help367="413 · C阁楼木屋 / 正面实体结构\nWASD实际穿门 · 靠近自动开门\nF3进出 · F2昼夜 · F12跟随\n近景镜头保持 · 家具和小院未搬\n新坡顶梁架 · 阁楼暂未开放"
 DisplayServer.window_set_title("小白鹅 · 413 · C阁楼木屋")
 refresh367()
