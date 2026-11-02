extends "res://scripts/combat/hud121.gd"
func _ready() -> void:
 super._ready();gems.setup(14,420.)
func reset_round() -> void:
 super.reset_round()
 gems._initialized=false;gems.set_value(battle.player_hp,battle.max_player_health())
func _process(delta: float) -> void:
 super._process(delta)
 if not battle.active114:return
 gems.set_value(battle.player_hp,battle.max_player_health())
 gems.warning=battle.health_fraction()<=.2 and battle.player_hp>0.
 var screen=get_viewport_rect().size
 _place(gems,Vector2(screen.x*.5-210,35),Vector2(420,44))
 _place(health_text,Vector2(screen.x*.5+218,47),Vector2(145,24))
 health_text.text="决心 %s / 14"%String.num(battle.player_hp,1)
 header.text="姐姐战测试 · "+battle.loadout_name226
 footer.text="C 装配与统计 · F8重开战斗 · F7回门口 · F4自动输出 · F5猪猪 · F6暂停 · F9修补预览"
func hurt(amount: float) -> void:
 gems.hit_shake(amount/2.)
 respond("受击 −"+String.num(amount,1),ROSE)
