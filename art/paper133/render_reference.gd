extends SceneTree
func _init() -> void:
 var art := Image.new()
 art.load_svg_from_string(FileAccess.get_file_as_string("res://assets/paper129/scrap.svg"),3.)
 art.save_png("res://art/paper133/current-shape-reference.png")
 quit()
