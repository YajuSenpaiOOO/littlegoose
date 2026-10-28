extends "res://scripts/combat/goose_hud168.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.active114 and (battle.trial152 or battle.paper_trial129):
  header.text=("作业纸" if battle.paper_trial129 else "团团怪")+" · "+battle.BUILDS169[battle.build169].name
  footer.text="1双鹅机队 2三鹅机队 3住校四机 4蓄力双机 5气球剑三机 6分裂双机 7火车四机 8快射双机 9本体单机 · F4纸 F5团团"
