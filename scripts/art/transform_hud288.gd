extends "res://scripts/art/transform_hud287.gd"
var battle: Node3D
func _draw() -> void:
 if not is_instance_valid(battle):return
 if fx.playing:
  super._draw();return
 if int(battle.levels226.get("flashlight",0))<=0:return
 var at=Vector2(get_viewport_rect().size.x*.5-145.,get_viewport_rect().size.y-95.)
 var color=Color(1.,.81,.40)
 draw_style_box(panel287(color,false),Rect2(at,Vector2(290,62)))
 var text="Q 光能变身 · 可用" if battle.cooldown288<=0. else "手电冷却 · %.1f 秒"%battle.cooldown288
 if not battle.active114 and battle.cooldown288<=0.:text="Q 光能变身 · 战斗中启用"
 draw_string(ThemeDB.fallback_font,at+Vector2(16,26),text,HORIZONTAL_ALIGNMENT_LEFT,-1,18,color)
 draw_string(ThemeDB.fallback_font,at+Vector2(16,49),"8秒 / 红灯3秒 / 结束后冷却30秒",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color(.8,.75,.7))
