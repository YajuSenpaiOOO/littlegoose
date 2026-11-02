extends "res://scripts/combat/memory_kit239.gd"
func card(id: String) -> Dictionary:
 var data=super.card(id).duplicate(true)
 if id=="music_class":data.fx="外框缩到辅助框时点击，Perfect＋40%、Great＋20%。基础120 BPM，随射速提高；按住自动普通。支持气球剑/零食/多鹅/飞机；弹弓、手电互斥。空弹不伤害、不占下一拍。"
 if id=="eye_exercise":data.fx="射速＋25%，保留微追踪；搭乐器课变为150 BPM。";data.fx2="射速合计＋50%；搭乐器课变为180 BPM。"
 return data
