extends "res://scripts/world/stone_time91.gd"
var expanded92 := false
func update_guide() -> void:
	super.update_guide()
	if not is_instance_valid(guide): return
	if expanded92:
		guide.text+="\n92：Ctrl+Alt+M 草势对照 · Ctrl+Alt+F1收起";return
	guide.text="第%d天 · %02d:%02d\nAlt+1晨 / 2午 / 3暮 / 4夜\nCtrl+6入口 · 7西侧 · 8后林\nCtrl+Alt+M 草势对照\nCtrl+Alt+K 原90对照\nF1隐藏 · Ctrl+Alt+F1完整说明"%[clock55.day,int(visual_hour),int(fmod(visual_hour,1.)*60.)]
