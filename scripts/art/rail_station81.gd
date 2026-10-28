extends "res://scripts/art/rail_station80.gd"
func material79() -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader=preload("res://scripts/art/station_brick73.gdshader")
	world.porch49.shade_material(material)
	return material
