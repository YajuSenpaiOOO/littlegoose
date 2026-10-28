extends "res://scripts/combat/paper_hud151.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.active114 and (battle.trial152 or battle.paper_trial129):
  var mode := "直接射击" if battle.buffs.level("paper_plane")==0 else ("随机九发" if battle.scatter152 else "辅助六发")
  header.text=("作业纸" if battle.paper_trial129 else "团团怪")+" · "+mode+" · "+battle.BUILDS152[battle.build152].name
  footer.text="F8随机/辅助 · F4纸怪 F5团团 · 1普通 2蓄力 3分裂 4射速 5水柱 6直蓄 7直射 8直分 9直水 · Q笔记"
