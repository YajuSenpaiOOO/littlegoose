extends "res://scripts/combat/memory_kit235.gd"
func card(id: String) -> Dictionary:
 var data=super.card(id).duplicate(true)
 if id=="music_class":data.fx="120 BPM多拍收缩框。缩到辅助框时点击Perfect＋40%；偏早/偏晚Great＋20%。点击Miss仍发空弹，不伤害/不附加特效、不占下一拍。漏拍不扣血。按住自动普通攻击。发射才奏下一音，射速转每拍威力。仅普通弹幕原型。"
 return data
