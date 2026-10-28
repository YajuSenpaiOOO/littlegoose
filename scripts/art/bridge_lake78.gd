extends "res://scripts/art/bridge_lake65.gd"
func _ready() -> void:
	super._ready()
	shore_material.shader=preload("res://scripts/art/lakeshore78.gdshader")
