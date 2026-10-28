extends RefCounted
static var POOL: Array=make167()
static func make167() -> Array:
 var cards: Array=preload("res://scripts/combat/cards166.gd").POOL.duplicate(true)
 for card in cards:
  if card.id=="exercise": card.fx="闪避掠过目标留下舞步标记；闪避结束后彩带星芒三连，延迟合计20%弹药基础伤害，每次闪避每目标一次。"
 return cards
