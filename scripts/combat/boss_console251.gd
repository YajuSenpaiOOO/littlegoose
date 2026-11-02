extends "res://scripts/combat/balance_console226.gd"
func _ready() -> void:
 super._ready();rename251(self);bat_hp.hide()
func rename251(node: Node) -> void:
 if node is Label:
  node.text=node.text.replace("姐姐战","团团Boss").replace("下场猫血","下场Boss血")
  if node.text=="蝙蝠血":node.hide()
 for child in node.get_children():rename251(child)
