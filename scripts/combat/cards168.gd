extends RefCounted
static var POOL: Array=make168()
static func make168() -> Array:
 var cards: Array=preload("res://scripts/combat/cards167.gd").POOL.duplicate(true)
 for card in cards:
  if card.id=="forest_fireboy": card.fx="占1格，额外小黑鹅+1，沿本体路径开火车。额外鹅40%伤害，保留射速/弹幕形态，不降低本体伤害。"
  elif card.id=="three_player": card.fx="占2格，额外小黑鹅+2，沿本体路径开火车。每只40%伤害，保留射速/弹幕形态，不降低全队射速。"
 cards.append({"id":"boarding_school","name":"住校","desc":"把小伙伴们都叫来，挤一挤，床边还能坐下！","line":"晚安之前，再玩最后一局。","fx":"占3格，额外小黑鹅+3；鹅队在本体附近团聚。每只40%伤害，不降低本体属性；可与其他加鹅碎片叠加。","mods":{"goose_count":3},"max":1})
 return cards
