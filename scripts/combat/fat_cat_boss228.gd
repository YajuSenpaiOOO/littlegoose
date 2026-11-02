extends "res://scripts/combat/fat_cat_boss221.gd"
func first228() -> bool:return battle.repairs220==0
func _ready() -> void:
 super._ready();next_roll220=1.6
func followup_allowed221() -> bool:return not first228()
func recovery_time221() -> float:return 1.6 if first228() else 1.3
func enter220(next: String) -> void:
 super.enter220(next)
 if next=="windup":windup_time221=.65 if first228() else (.4 if burst221==1 else .55)
 if next=="chase":next_roll220=1.8 if first228() else 1.6
