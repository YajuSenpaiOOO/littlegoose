extends "res://scripts/world/frame_overlay66.gd"

func refresh(now: float) -> void:
	super.refresh(now)
	var size := DisplayServer.window_get_size()
	readout.text+="\n%d×%d · 同步%s · 上限%s · Ctrl+F11 同步开关"%[size.x,size.y,"关" if DisplayServer.window_get_vsync_mode()==DisplayServer.VSYNC_DISABLED else "开",str(Engine.max_fps) if Engine.max_fps>0 else "不限"]
