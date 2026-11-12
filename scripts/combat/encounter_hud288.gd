extends "res://scripts/combat/encounter_hud264.gd"
func _ready() -> void:
 super._ready();remove_child(timer229);timer229.queue_free()
 timer229=preload("res://scripts/combat/red_alert288.gd").new();timer229.battle=battle;add_child(timer229);timer229.hide()
func _process(delta: float) -> void:
 super._process(delta)
 if int(battle.levels226.get("flashlight",0))>0:footer.text+=" · Q 手电主动"
