extends Node3D
var battle: Node3D
var visual: Sprite3D
func _ready() -> void:
 visual=Sprite3D.new();visual.texture=preload("res://assets/tuantuan_rest265/cushion.png")
 var data=JSON.parse_string(FileAccess.get_file_as_string("res://assets/tuantuan_rest265/layout.json"))["cushion.png"]
 var box: Array=data.alpha_bbox;var foot: Array=data.foot
 visual.pixel_size=4.2/float(box[2]-box[0]);visual.offset=Vector2(visual.texture.get_width()*.5-float(foot[0]),float(foot[1])-visual.texture.get_height()*.5)
 visual.billboard=BaseMaterial3D.BILLBOARD_ENABLED;visual.shaded=true;visual.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD;visual.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;visual.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(visual)
 battle._add_actor_shadow(self,visual)
 # Soft cloth is intentionally traversable; the resting boss owns its own footprint.
