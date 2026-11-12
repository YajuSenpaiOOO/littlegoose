extends "res://scripts/world/woodland_world303.gd"
func _hero_script() -> Script:return preload("res://scripts/combat/hero304.gd")
func card_script301() -> Script:return preload("res://scripts/combat/paper_card304.gd")
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 304 · 飞纸怪驱动 / 插枪弹射")
func _ready() -> void:
 await super._ready();hint288.text="304 纸偶招式\nF8混合 / F9竖直纸火 / F10飞纸怪 / F11插枪骑士"
func _process(delta: float) -> void:
 super._process(delta)
 if ready301:guide206.text=guide206.text.replace("303 纸偶招式","304 纸偶招式")
func launch_player304(direction: Vector2) -> void:
 hero.combat_impulse=direction*22.
 hero.velocity.y=6.
 hero.launch304=true
 invulnerability=maxf(invulnerability,.8)
