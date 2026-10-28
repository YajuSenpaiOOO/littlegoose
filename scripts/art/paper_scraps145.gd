extends RefCounted
## Art-only material preview; no inventory, pickup or enemy drop rule is added here.
static func texture145() -> Texture2D:
 var source := Image.load_from_file("res://assets/paper145/paper_scraps.png")
 var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/paper145/region.json"))
 var r: Array=data.region;var image := source.get_region(Rect2i(r[0],r[1],r[2],r[3]));image.generate_mipmaps()
 return ImageTexture.create_from_image(image)
static func sprite145(width := .48) -> Sprite3D:
 var sprite := Sprite3D.new();sprite.texture=texture145();sprite.pixel_size=width/sprite.texture.get_width()
 sprite.offset.y=sprite.texture.get_height()*.5;sprite.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD
 sprite.alpha_scissor_threshold=.86;sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
 sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 return sprite
