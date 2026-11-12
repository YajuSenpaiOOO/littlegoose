extends "res://scripts/world/woodland_world273.gd"
func _init() -> void:
 super._init();ball_owned273=true
func loadout_error257(levels: Dictionary,level: int) -> String:
 if level<1 or level>20:return "测试决心等级范围为1—20"
 return balance_profile226().error(levels,slots_at257(level))
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 274 · 弹力球自由测试 / 单体反弹")
func _process(delta: float) -> void:
 super._process(delta)
 if ready264:guide206.text=guide206.text.replace("273 林间空地","274 林间空地").replace("273 大团团挑战","274 大团团挑战")
