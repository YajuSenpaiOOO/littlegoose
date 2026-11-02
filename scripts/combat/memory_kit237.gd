extends "res://scripts/combat/memory_kit235.gd"
func card(id: String) -> Dictionary:
 var data=super.card(id).duplicate(true)
 if id=="music_class":data.fx="120 BPM单轨音符。到线点击Perfect＋40%；偏早/偏晚普通伤害。漏拍Miss不扣血。按住自动普通攻击。发射才奏下一音，射速转每拍威力。仅普通弹幕原型。"
 return data
