extends "res://scripts/combat/fat_cat_boss228.gd"
func _ready() -> void:
 super._ready()
 roll_sheet220=load("res://assets/fat_cat230/roll_sheet.png")
 rolls220.clear()
 for f in roll_data220.frames:rolls220.append(atlas220(roll_sheet220,f.region))
 _render_legacy(0.)
