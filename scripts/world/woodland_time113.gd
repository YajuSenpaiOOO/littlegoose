extends "res://scripts/world/woodland_time112.gd"
func update_guide() -> void:
 super.update_guide()
 if is_instance_valid(guide):
  guide.text=guide.text.replace("112：","113：")+"\nCtrl+Alt+F11 节奏对照（重开）\n当前："+("慢起步 · 基础约3发/秒" if world.slow_start113 else "原射速 · 性能对照")
