extends "res://scripts/world/woodland_world222.gd"
func _init() -> void:
 super._init();memory_save116="user://plush_boss223_preview.cfg"
func _sister_script220() -> Script:
 return preload("res://scripts/art/bat_faces223.gd")
func _candy_script117() -> Script:
 return preload("res://scripts/combat/bat_aim223.gd")
func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 223 · 蝙蝠血量表情 / 修补时辅助瞄准")
func _process(delta: float) -> void:
 super._process(delta)
 if ready220:guide206.text=guide206.text.replace("222 姐姐修补","223 蝙蝠表情")+"\n蝙蝠：高空无框 · 修补时可锁定 · 受损表情跨轮保留"
