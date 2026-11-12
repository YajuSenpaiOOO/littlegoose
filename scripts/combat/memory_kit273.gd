extends "res://scripts/combat/memory_kit262.gd"
const BALL273={"id":"bouncy_ball","name":"弹力球","max":1,"fx":"普通弹丸、弹弓重弹与飞出的气球剑命中后，额外弹一次：敌人间弹向附近另一只；附近无目标时也向外弹回，实体表面按法线反弹。反弹伤害70%，不重复命中原目标。光束、纸飞机与分裂子弹暂不参与。"}
func card(id: String) -> Dictionary:return BALL273 if id=="bouncy_ball" else super.card(id)
