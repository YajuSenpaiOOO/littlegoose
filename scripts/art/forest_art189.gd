extends "res://scripts/art/forest_art188.gd"
var flowers189: Array[Dictionary]=[]
var hammock_cat189: Sprite3D
var cat_anchor189 := Vector3.ZERO
func _ready() -> void:
 super._ready()
 for prop in props181:
  if prop.texture!=preload("res://assets/forest188/lilac_ground_clump_pixel.png"): continue
  var bounds := opaque_bounds181(prop.texture)
  var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/forest_flower189.gdshader")
  material.set_shader_parameter("paint",prop.texture)
  material.set_shader_parameter("flower_y",Vector2(float(bounds.position.y)/prop.texture.get_height(),float(bounds.end.y)/prop.texture.get_height()))
  prop.material_override=material;prop.extra_cull_margin=.45
  flowers189.append({"visual":prop,"push":Vector3.ZERO})
 # Place the little sling in front of the painted purple fabric.  The source
 # tree atlas coordinates keep the cat attached to the authored cloth.
 var tile: AtlasTexture=stage_tree185.texture
 var source: Texture2D=tile.atlas;var bounds := opaque_bounds181(source)
 var pixel := Vector2(bounds.position)+Vector2(bounds.size)*Vector2(.55,.745)
 var dx := (pixel.x-source.get_width()*.5+stage_tree185.offset.x)*stage_tree185.pixel_size
 var up := (tile.region.size.y-pixel.y)*stage_tree185.pixel_size
 var at: Vector3=stage_tree185.global_position+world.camera.global_basis.x*dx+world.camera.global_basis.y*up+world.camera.global_basis.z*.065
 hammock_cat189=cutout181(preload("res://assets/forest189/hammock_ghost_cat.png"),to_local(at),1.75,Vector2(.5,.65),true)
 hammock_cat189.name="HammockGhostCat189";cat_anchor189=hammock_cat189.position
func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(world.hero): return
 var walker: Vector3=world.hero.get_global_transform_interpolated().origin
 for entry in flowers189:
  var visual: Sprite3D=entry.visual
  var away := Vector2(visual.global_position.x-walker.x,visual.global_position.z-walker.z)
  var touch := (1.-smoothstep(.10,.95,away.length()))*(1.-smoothstep(.55,1.15,absf(visual.global_position.y-walker.y)))
  var target := Vector3(away.normalized().x,-.20,away.normalized().y)*touch*.30
  entry.push=Vector3(entry.push).lerp(target,1.-exp(-delta*(12. if touch>.01 else 5.)))
  visual.material_override.set_shader_parameter("push94",entry.push);visual.material_override.set_shader_parameter("clock",world.clock)
 if is_instance_valid(hammock_cat189):
  hammock_cat189.position=cat_anchor189+world.camera.global_basis.x*(sin(world.clock*1.25)*.025)+Vector3.UP*(sin(world.clock*2.5)*.009)
