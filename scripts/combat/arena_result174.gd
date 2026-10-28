extends "res://scripts/combat/workshop_result116.gd"
func _ready() -> void:
 super._ready()
 var close: Button=menu.get_child(0).get_child(3);close.text="关闭试玩"
 for connection in close.pressed.get_connections(): close.pressed.disconnect(connection.callable)
 close.pressed.connect(func(): get_tree().quit())
func show_menu(finished: bool) -> void:
 super.show_menu(finished)
 if not finished: return
 menu.get_child(0).get_child(0).text="林间试玩结束"
 stats.text="击倒 %d / %d · 受击 %d 次 · %.1f 秒\n%s"%[battle.defeated_count,battle.spider_count170,battle.hurt_count,battle.elapsed114,battle.BUILDS170[battle.build170].name]
