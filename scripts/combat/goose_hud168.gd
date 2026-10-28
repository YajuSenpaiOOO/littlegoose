extends "res://scripts/combat/play_hud166.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.active114 and (battle.trial152 or battle.paper_trial129):
  header.text=("作业纸" if battle.paper_trial129 else "团团怪")+" · "+battle.BUILDS168[battle.build168].name
  footer.text="1双鹅火车 2三鹅火车 3住校团聚 4弹弓火车 5飞机火车 6气球剑火车 7四鹅火车对照 8水柱火车 9本体对照 · F4纸 F5团团"
