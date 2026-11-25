extends "res://scripts/combat/battle_skills288.gd"
const FEATHER=preload("res://assets/black_goose_feather387/feather.png")
const REGION=Rect2(134,415,1044,518)
var feathers_drawn387:=0
func _draw() -> void:
 feathers_drawn387=0;super._draw()
func draw_custom_projectile110(shot: Dictionary,at: Vector3,screen: Vector2,pixel: float) -> bool:
 if not battle.feather_shot387(shot):return false
 var size: Vector2=REGION.size*(.40*battle.Profile.PPM*pixel/REGION.size.x)*shot.art.scale_gain
 draw_set_transform(screen,battle.screen_direction(at,shot.velocity.normalized()).angle())
 draw_texture_rect_region(FEATHER,Rect2(-size*.5,size),REGION,shot.art.modulate)
 draw_set_transform(Vector2.ZERO);feathers_drawn387+=1;return true
