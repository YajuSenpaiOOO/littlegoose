extends "res://scripts/world/woodland76_probe.gd"
func run() -> void:
	var sample := ForestSample.new();root.add_child(sample)
	while not is_instance_valid(sample.wall76): await physics_frame
	await settle72()
	sample.hero.controls_enabled=false;sample._teleport15(sample.meadow.landmarks.junction+Vector2(3,-13));await settle72(5)
	paused=true
	var ordinary: Dictionary=sample.trees[0]
	var sprite: Sprite3D=ordinary.visual
	var original: Transform3D=ordinary.root.global_transform
	print("ORD76 initial root=",original," sprite=",sprite.transform," px=",sprite.pixel_size," tex=",sprite.texture.get_size()," off=",sprite.offset," cam=",sample.camera.global_transform)
	for depth in [1.8,3.,5.]:
		for vertical in [-5.,-3.,-1.]:
			ordinary.root.global_position=sample.camera.global_position-sample.camera.global_basis.z*depth+Vector3.UP*vertical
			ordinary.root.force_update_transform();sprite.force_update_transform()
			var bounds: Rect2=sample.whole67.screen_bounds(sprite)
			sample.whole67.update(.08)
			print("ORD76 depth=",depth," y=",vertical," sprite=",sprite.global_position," rect=",bounds," entry=",sample.whole67.entries[sprite.get_instance_id()])
	ordinary.root.global_transform=original
	paused=false;quit()
