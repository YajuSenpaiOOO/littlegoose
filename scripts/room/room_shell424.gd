extends "res://scripts/room/room_shell423.gd"

func build_shell() -> void:
 super.build_shell()
 # The new fascia occupies the real roof edge. Retire the old floating
 # wing cut trim, leaving the interior arch and other carpentry in place.
 for part in timbers.find_children("WingRoofCutTrim423*","MeshInstance3D",true,false):
  part.hide()
 for part in timbers.find_children("LiningRafter423*","MeshInstance3D",true,false):
  part.hide()
