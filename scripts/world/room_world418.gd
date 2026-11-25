extends "res://scripts/world/room_world417.gd"

func yard_script403() -> Script:
 return preload("res://scripts/room/home_yard418.gd")

func apply_zone410() -> void:
 super.apply_zone410()
 if ready410:
  # The outer shell and room share coordinates. Only the front/roof group cuts.
  yard403.permanent418.show()
  for wall in room.caps392:
   wall.visible=inside403
  for wall in room.tall392:
   wall.visible=inside403

func _ready() -> void:
 await super._ready()
 help367="418 · A稿外屋结构\nWASD穿过原门槛 · F3快捷进出\n室内外连续 · 前墙与屋面切开"
 DisplayServer.window_set_title("小白鹅 · 418 · A稿外屋")
 refresh367()
