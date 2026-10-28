extends "res://scripts/combat/hero188.gd"
var receiver192: StandardMaterial3D
static func make_receiver192() -> StandardMaterial3D:
 var material := StandardMaterial3D.new()
 material.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR;material.alpha_scissor_threshold=.5
 material.cull_mode=BaseMaterial3D.CULL_DISABLED;material.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
 material.vertex_color_use_as_albedo=true;material.roughness=1.;material.metallic_specular=0.
 material.albedo_color=Color(.82,.82,.82,1.)
 # Tangent-space normal tilts only the lighting normal toward overhead light.
 # Positive tangent green points toward world-up on the upright Sprite3D.
 var image := Image.create(2,2,false,Image.FORMAT_RGB8)
 image.fill(Color(.5,.5+sin(deg_to_rad(25.))*.5,.5+cos(deg_to_rad(25.))*.5))
 material.normal_enabled=true;material.normal_texture=ImageTexture.create_from_image(image)
 return material
func _ready() -> void:
 super._ready()
 receiver192=make_receiver192();visual.material_override=receiver192;visual.shaded=true
 bind_texture192()
func bind_texture192() -> void:
 if receiver192==null or not is_instance_valid(visual) or visual.texture==null: return
 # Sprite3D already supplies the atlas-region UVs. Bind the sheet, not a
 # second cropped atlas, so walk/dash/guard frames use the native UV mapping.
 receiver192.albedo_texture=visual.texture.atlas if visual.texture is AtlasTexture else visual.texture
func render_pose() -> void:
 super.render_pose()
 bind_texture192()
