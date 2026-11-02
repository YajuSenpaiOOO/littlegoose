extends SceneTree
func _initialize() -> void:
 # Asset packing only: retain the original five cells byte-for-byte in RGBA.
 var source=Image.load_from_file("res://assets/fat_cat220/roll_sheet.png")
 var edited=Image.load_from_file("res://assets/fat_cat230/roll_sheet.png")
 source.convert(Image.FORMAT_RGBA8);edited.convert(Image.FORMAT_RGBA8)
 source.blit_rect(edited,Rect2i(0,512,512,512),Vector2i(0,512))
 var err=source.save_png("res://assets/fat_cat230/roll_sheet.png")
 print("PACK230 ",err);quit(err)
