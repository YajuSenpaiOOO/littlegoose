extends RefCounted

# Shared texture/material: actor modulation controls strength without allocations.
static var _texture: GradientTexture2D
static var _material: ShaderMaterial

static func create() -> Sprite2D:
	if _texture == null:
		_texture = GradientTexture2D.new()
		_texture.width = 96
		_texture.height = 30
		var gradient := Gradient.new()
		gradient.set_color(0, Color.WHITE)
		gradient.set_color(1, Color.WHITE)
		_texture.gradient = gradient
		_material = ShaderMaterial.new()
		_material.shader = preload("res://scripts/art/contact_shadow.gdshader")
	var result := Sprite2D.new()
	result.name = "Shadow"
	result.texture = _texture
	result.material = _material
	result.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	return result
