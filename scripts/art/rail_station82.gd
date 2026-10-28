extends "res://scripts/art/rail_station80.gd"
## Default 79 painted moss stone stays on the lower junction stairs and wall.
func finish79(st: SurfaceTool,label: String) -> MeshInstance3D:
	var node := super.finish79(st,label)
	if label in ["ClosedFrontStoneFlight80","FrontOutsideStoneCurbs80","PaintedFrontStoneSteps79"]:
		var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/station_brick73.gdshader")
		world.porch49.shade_material(material);node.material_override=material
	return node
