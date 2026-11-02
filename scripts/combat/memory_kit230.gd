extends "res://scripts/combat/memory_kit229.gd"
func card(id: String) -> Dictionary:
 var data=super.card(id).duplicate(true)
 if id=="eye_exercise":
  data.fx="射速＋25%。直射弹幕微追踪；纸飞机只在覆盖区内校准落点，落下后不拐弯。"
  data.fx2="射速合计＋50%，直射追踪与投递落点校准增强。"
 if id=="paper_plane":data.fx="把当前弹幕载荷送到标记区域，六次直落；落弹前校准附近目标，不在空中横追。"
 return data
