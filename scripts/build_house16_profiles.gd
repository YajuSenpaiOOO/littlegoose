extends "res://scripts/build_forest14_profiles.gd"
func _initialize() -> void:
	var result := {}
	for id in ["slate","shingle","moss"]:
		var file := "res://assets/house16/%s.png"%id
		var image := Image.load_from_file(file)
		var data := profile(image)
		data.foot[0] = float(data.bounds[0])+float(data.bounds[2])*.5
		data.file = file
		result[id] = data
	var output := FileAccess.open("res://assets/house16/profiles.json",FileAccess.WRITE)
	output.store_string(JSON.stringify(result,"\t"))
	print(JSON.stringify(result))
	quit()
