extends "res://scripts/ground_lab_probe.gd"

func run() -> void:
	var sample: Node3D = load("res://scenes/sandbox/forest_cottage13.tscn").instantiate()
	root.add_child(sample)
	sample.hero.controls_enabled = false
	for i in 15: await physics_frame
	verify(sample.hero.is_on_floor() and is_equal_approx(sample.camera.rotation_degrees.x,-25.),"forest sample preserves real movement floor and fixed 25-degree perspective")
	verify(sample.candidate==3 and sample.ground_materials[3].get_shader_parameter("paint")!=null,"approved D meadow stays in use")
	verify(sample.trees.size()>=80 and sample.distant_roots.size()>=60,"overlapping rear and side woodland ranks close the distance")
	var seated := true
	var bases := 0
	for tree in sample.trees:
		var at: Vector3 = tree.root.position
		seated = seated and absf(at.y-sample.meadow.height_at(at.x,at.z,true))<.0001
		for child in tree.root.get_children():
			if child is StaticBody3D: bases += 1
	verify(seated and bases==sample.trees.size(),"every tree is seated on terrain with one trunk collision body")
	var textures := true
	for id in ["oak","young","cottage"]:
		var texture: Texture2D = sample.art_textures[id]
		textures = textures and texture.get_image().has_mipmaps() and texture.get_image().get_format()==Image.FORMAT_RGBA8
	verify(textures,"all three transparent generated assets use shared mipmapped textures")
	verify(sample.house_art.billboard==BaseMaterial3D.BILLBOARD_DISABLED and is_equal_approx(sample.house_art.rotation_degrees.x,-25.),"house uses a fixed camera-facing front illustration, without a baked side wall")
	var pad := true
	for x in [-7.,-4.7,-2.]:
		for z in [-8.,-6.,-4.8]: pad = pad and absf(sample.meadow.height_at(x,z,true)-.12)<.001
	verify(pad,"cottage footprint sits on a level pad, not the old test hill")
	verify(sample.sun.shadow_enabled and sample.house_art.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_ON,"painted silhouettes cast actual directional shadows")
	var field: Texture2D = sample.ground_materials[3].get_shader_parameter("forest_mask")
	verify(field!=null and sample.meadow_materials[3].get_shader_parameter("forest_mask")==field,"ground and reactive grass share the same canopy and root shading field")
	var camera_at: Vector3 = sample.camera.position
	var hero_at: Vector3 = sample.hero.position
	sample._unhandled_input(event(KEY_N))
	verify(not sample.depth_lighting and not sample.ground_materials[3].get_shader_parameter("forest_depth") and sample.camera.position==camera_at and sample.hero.position==hero_at,"N compares lighting and grounding without moving the camera or actor")
	sample._unhandled_input(event(KEY_N))
	sample._unhandled_input(event(KEY_B))
	var hidden := true
	for tree in sample.distant_roots: hidden = hidden and not tree.visible
	sample._unhandled_input(event(KEY_B))
	var shown := true
	for tree in sample.distant_roots: shown = shown and tree.visible
	verify(hidden and shown,"B removes and restores only the far woodland ranks")
	# Walk the main path through the clearing with real input.
	sample.hero.controls_enabled = true
	Input.parse_input_event(event(KEY_W))
	for i in 40: await physics_frame
	var release := event(KEY_W)
	release.pressed = false
	Input.parse_input_event(release)
	sample.hero.controls_enabled = false
	for i in 8: await physics_frame
	verify(sample.hero.position.z<1.2 and sample.hero.is_on_floor(),"central road remains traversable with scenery and terrain enabled")
	# Door approach must stop against the actual cottage footprint.
	sample.hero.position = Vector3(-4.7,.2,-3.5)
	sample.hero.velocity = Vector3.ZERO
	sample.hero.reset_physics_interpolation()
	for i in 12: await physics_frame
	sample.hero.controls_enabled = true
	Input.parse_input_event(event(KEY_W))
	for i in 40: await physics_frame
	Input.parse_input_event(release)
	sample.hero.controls_enabled = false
	for i in 6: await physics_frame
	verify(sample.hero.position.z> -5.05 and sample.hero.position.z< -4.5 and sample.hero.is_on_floor(),"house collision blocks entry into the painted facade while preserving doorstep access")
	sample.set_process(false)
	sample.set_physics_process(false)
	sample.hero.set_physics_process(false)
	sample.hero.position = Vector3(-10,sample.meadow.height_at(-10,8,true),8)
	sample._update_camera(0,true)
	sample._process(.4)
	var faded := false
	for tree in sample.trees:
		var alpha: float = tree.visual.material_override.get_shader_parameter("fade")
		faded = faded or alpha<.8
	verify(faded,"foreground tree occlusion fades in the actual screen-space view")
	sample.hero.position = Vector3(-4.7,.12,-9.6)
	sample._update_camera(0,true)
	sample._process(.4)
	verify(float(sample.house_art.material_override.get_shader_parameter("fade"))<.8,"cottage fades when its physical footprint hides the actor")
	sample._unhandled_input(event(KEY_T))
	for i in 3: await physics_frame
	var flat := true
	for tree in sample.trees: flat = flat and absf(tree.root.position.y)<.0001
	verify(flat and absf(sample.cottage_root.position.y)<.0001,"flat-ground comparison reseats trees and cottage as well as grass")
	print("FOREST13 trees=",sample.trees.size()," far=",sample.distant_roots.size()," grass=",sample.grass.multimesh.instance_count)
	print(JSON.stringify({"checks":checks,"failures":failures}))
	quit(0 if failures.is_empty() else 1)
