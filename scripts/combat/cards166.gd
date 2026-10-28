extends RefCounted
static var POOL: Array=make166()
static func make166() -> Array:
 var cards: Array=preload("res://scripts/combat/cards164.gd").POOL.duplicate(true)
 for card in cards:
  if card.id=="snack":
   card.fx="命中后向周围抛出短程糖屑（0.5×），在命中点附近约两米内落地；子弹不追踪。";card.fx2="糖屑还能再次分裂，同样短程下落。"
  elif card.id=="exercise": card.fx="闪避掠过身边目标造成20%弹药基础伤害；短顿后彩带星芒三连，单次闪避每目标只结算一次。"
 return cards
