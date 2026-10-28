extends "res://scripts/art/memory_workshop116.gd"
func prop116(label: String,file: String,region: Rect2,at: Vector2,height: float,body_size: Vector3) -> Prop116:
 var prop := super.prop116(label,file,region,at,height,body_size)
 var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/art/workshop_pixel117.gdshader")
 var atlas: AtlasTexture=prop.visual.texture
 ink.set_shader_parameter("paint",atlas.atlas)
 ink.set_shader_parameter("source_size117",Vector2(atlas.atlas.get_size()))
 ink.set_shader_parameter("crop_origin117",region.position)
 ink.set_shader_parameter("pixel_step117",8. if file=="stump_pot.png" else 10.)
 prop.visual.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST
 world.porch49.materials.erase(prop.visual.material_override.get_instance_id())
 prop.visual.material_override=ink;world.porch49.shade_material(ink)
 return prop
