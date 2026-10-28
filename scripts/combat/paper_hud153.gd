extends "res://scripts/combat/paper_hud152.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.active114 and (battle.trial152 or battle.paper_trial129):
  header.text=("作业纸" if battle.paper_trial129 else "团团怪")+" · "+battle.BUILDS153[battle.build153].name
  footer.text="F4纸怪 F5团团 · 1直剑 2剑雨 3快剑 4快剑雨 5分剑 6分剑雨 7蓄剑 8直射 9飞机 · Q笔记 · F8随机/辅助"
