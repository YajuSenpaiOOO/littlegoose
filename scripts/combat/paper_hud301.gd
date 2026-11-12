extends "res://scripts/combat/encounter_hud288.gd"
func _process(delta: float) -> void:
 super._process(delta)
 if battle.ready301:
  header.text="吊线纸偶 · "+battle.loadout_name226
  footer.text="C装配 · F7重开 · F6暂停 · F4瞄准 · F3回院"
