extends "res://scripts/art/forest_props94.gd"
var scope95: Node
func _flower_specs94() -> Array: return [Vector4(-3.1,-5.7,5.8,3.4)]
func _flower_attempts94() -> int: return 800
func _flower_gap94(_local: Vector2) -> bool: return false
func _flower_variant94(_spec: Vector4,rng: RandomNumberGenerator) -> int:
	var choice := rng.randf()
	return 0 if choice<.7 else (1 if choice<.94 else 2)

func _plant_material94(texture: Texture2D) -> ShaderMaterial:
	var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/woodland_plant95.gdshader")
	material.set_shader_parameter("paint",texture);world.porch49.shade_material(material)
	return material

func _plant_active94(visual: Sprite3D) -> bool:
	return not is_instance_valid(scope95) or not scope95.enabled95 or visual.get_meta("active95",true)

func _ready() -> void:
	super._ready()
	for plant in plants87:
		plant.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	for batch in flower_batches94:
		batch.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	for rock in rocks87:
		# Keep its existing fitted silhouette; enable receiving tree/actor shadows.
		var material: ShaderMaterial=rock.visual.material_override
		material.shader=preload("res://scripts/art/forest_receiver95.gdshader")
		world.porch49.shade_material(material)
	print("FOREST95_SHADOW_RECEIVERS plants=",plants87.size()," rocks=",rocks87.size()," flower_batches=",flower_batches94.size())
