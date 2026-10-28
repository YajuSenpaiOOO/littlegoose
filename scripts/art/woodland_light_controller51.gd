extends "res://scripts/art/route_light_controller50.gd"
const LABELS51 := ["50林路原版","树密度林荫","密度＋阳光开口"]
var variants: Array[Dictionary] = []
var woodland_data: Dictionary

func _ready() -> void:
	super._ready()
	variants.append({"texture":field_texture,"image":field_image,"bounds":field_bounds})
	woodland_data=JSON.parse_string(FileAccess.get_file_as_string("res://assets/lighting51/woodland_openings.json"))
	var b: Array=woodland_data.bounds
	var bounds := Vector4(b[0],b[1],b[2],b[3])
	for suffix in ["density","openings"]:
		var texture: Texture2D=load("res://assets/lighting51/woodland_"+suffix+".png")
		var image := texture.get_image()
		if image.is_compressed(): image.decompress()
		variants.append({"texture":texture,"image":image,"bounds":bounds})
	set_profile(2)
	print("WOODLAND51_READY tree_density=",woodland_data.tree_count," regions=",woodland_data.regions.size())

func _route_strength() -> float: return 1.

func set_profile(value: int) -> void:
	if variants.size()==3:
		var chosen: Dictionary=variants[clampi(value,0,2)]
		field_texture=chosen.texture
		field_image=chosen.image
		field_bounds=chosen.bounds
	super.set_profile(value)
