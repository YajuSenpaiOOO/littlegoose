extends "res://scripts/art/kitchen_garden45.gd"

const YARD = preload("res://scripts/world/yard_layout432.gd")

func _build_door_paving() -> void:
 for i in range(2,YARD.ENTRY.size()-1):
  var at: Vector2=YARD.ENTRY[i]
  var side:=.13 if i%2==0 else -.14
  _stone(at+Vector2(0.,side),Vector2(.38,.33),float(i))
  if i%2==0:
   _stone(at-Vector2(.13,side*2.1),Vector2(.29,.30),float(i)+.5)

func _occupied(at: Vector2) -> bool:
 if YARD.workshop_paved(at) or YARD.bath_paved(at):
  return true
 if YARD.BOUNDS.has_point(at):
  if YARD.path_distance(at,YARD.ENTRY)<YARD.ENTRY_WIDTH*.91:return true
 return super._occupied(at)
