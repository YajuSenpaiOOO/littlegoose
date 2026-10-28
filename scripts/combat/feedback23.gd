extends "res://scripts/combat/combat_feedback22.gd"
func _draw_cursor(cursor: Vector2,color: Color) -> void:
	if battle.world_cursor:
		draw_circle(cursor,1.7,Color(color,.55))
	else: super._draw_cursor(cursor,color)
