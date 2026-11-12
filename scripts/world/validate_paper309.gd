extends "res://scripts/world/validate_paper305.gd"

class Harness309:
 extends "res://scripts/world/woodland_world309.gd"
 func export_stats226() -> Error:
  return OK

func world_script301() -> Script:
 return Harness309

func report304() -> String:
 return "res://docs/paper309-validation.json"

func shot301(_tag: String) -> void:
 pass

func extra304() -> void:
 await super.extra304()
 w.focus303 = "mixed"
 w.restart301()
 var dinosaur = w.cards301[0]
 var knight = w.spawn301()
 var monster = w.spawn301()
 check(knight.kind301 == "knight" and knight.get_script() == preload("res://scripts/combat/paper_card305.gd"), "mixed mode uses the original 305 knight script")
 for card in [dinosaur, monster]:
  check(card.get_script() == preload("res://scripts/combat/paper_card306.gd"), "mixed mode retains current non-knight presentation")
 knight = solo303("knight")
 check(knight.get_script() == preload("res://scripts/combat/paper_card305.gd"), "solo mode uses the original 305 knight script")
 knight.enter301("warn")
 knight.render301()
 check(knight.cue301.visible and knight.charge_duration304() == 1.35 and knight.contact_damage303() == 1.5, "305 knight cue, timing and damage are restored")
