extends "res://scripts/combat/buff_book229.gd"
func eligible() -> Array[Dictionary]:
 var entries=super.eligible();var filtered: Array[Dictionary]=[]
 for entry in entries:
  if entry.id!="distract":filtered.append(entry)
 return filtered
