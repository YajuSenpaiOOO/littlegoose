extends "res://scripts/world/world_time68.gd"
func _guide_suffix67() -> String:
	return super._guide_suffix67()+"\n80：封闭连续石阶 / 干净地表\n5 前短阶 · 0 侧阶 · 1 院前\nCtrl+Alt+1 苔草 / 2 浅砾 / 3 薄叶\n当前："+world.GROUND_NAMES80[world.ground_style80]+"\n4 湖心岛 · 7 后林 · 8 铁路\nTab 地势 · 9 全图 · WASD退出"
