extends "res://scripts/world/woodland46_probe.gd"
class WillowSample:
	extends "res://scripts/world/world64.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func shot64(tag: String) -> Image:
	var frame: Image=await snapshot()
	frame.save_png("res://docs/captures/world_restart/willow64_"+tag+".png")
	return frame

func foot_samples(study: Node3D) -> int:
	var image: Image=study.tree.visual.texture.get_image()
	if image.is_compressed(): image.decompress()
	var profile: Dictionary=study.profiles.giant_willow
	var scale_px: float=study.tree.height/profile.height
	var count := 0
	for fraction in [.30,.40,.50,.60,.70,.78]:
		var x := int(image.get_width()*fraction)
		for y in range(int(profile.foot[1]),int(profile.foot[1]-profile.height*.18),-1):
			if image.get_pixel(x,y).a<.55: continue
			var source_height: float=(profile.foot[1]-y)*scale_px
			if source_height<=study.root_piece.drop: count+=1
			break
	return count

func run() -> void:
	var sample: Node3D=WillowSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.landmark62) or not sample.landmark62.is_node_ready(): await physics_frame
	for i in 40: await physics_frame
	sample.label.get_parent().hide()
	sample.hero.controls_enabled=false
	var study: Node3D=sample.landmark62
	verify(study.variant==1 and study.seated_roots,"approved willow selected with seated roots")
	verify(study.stones64.size()==5 and not sample.tree_bench64.is_empty(),"five familiar stones and one existing-style bench")
	verify(not sample.bridge59.moving and not sample.bridge59.sparkling,"water remains parked")
	verify(sample.meadow.get_script().resource_path=="res://scripts/world/world_surface63.gd","approved trial footprint remains")
	sample.time55.preview_at(12.)
	sample.time55.visual_hour=12.
	sample.time55.apply_look()
	for i in 15: await physics_frame
	paused=true
	study.set_understory(false)
	study.set_seated_roots(false)
	var old_count := foot_samples(study)
	await shot64("old_roots_bare")
	study.set_seated_roots(true)
	var new_count := foot_samples(study)
	var bare: Image=await shot64("seated_roots_bare")
	verify(new_count>=old_count+2,"several side root tips now fold onto terrain")
	verify(is_equal_approx(study.root_piece.drop,1.55),"root region covers the full visible flare")
	study.tree_shadow63.update_shadow()
	var points: PackedVector3Array=study.tree_shadow63.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var grounded := true
	for point in points:
		var at: Vector3=study.tree_shadow63.to_global(point)
		grounded=grounded and absf(at.y-sample.floor_height(Vector2(at.x,at.z))-.024)<.001
	verify(grounded,"shadow follows the new folded-root geometry on terrain")
	study.set_understory(true)
	var furnished: Image=await shot64("furnished_full")
	verify(changed(bare,furnished,Rect2i(Vector2i.ZERO,bare.get_size()))>1000,"understory visibly adds a resting place")
	verify(sample.tree_bench64.body.collision_layer==2,"bench has normal furniture collision")
	study.set_understory(false)
	verify(not sample.tree_bench64.root.visible and sample.tree_bench64.body.collision_layer==0,"understory toggle removes bench visual and collision together")
	var hidden_contacts := true
	for foot in sample.contact_marks:
		if foot.prop.root==sample.tree_bench64.root: hidden_contacts=hidden_contacts and not foot.mark.visible
	verify(hidden_contacts,"no detached bench contact shadows when hidden")
	study.set_understory(true)
	paused=false
	study.review_view=false
	var hub: Vector2=sample.meadow.landmarks.junction
	sample._teleport15(hub+Vector2(0,6.2))
	for i in 40: await physics_frame
	paused=true
	await shot64("close_noon")
	study.set_understory(false)
	study.set_seated_roots(false)
	await shot64("close_old_roots")
	study.set_seated_roots(true)
	await shot64("close_seated_bare")
	study.set_understory(true)
	for hour in [7.5,17.5,22.]:
		sample.time55.visual_hour=hour
		sample.time55.apply_look()
		study.tree_shadow63.update_shadow()
		await shot64("close_hour_"+str(hour))
	paused=false
	sample.time55.preview_at(12.)
	sample.time55.visual_hour=12.
	sample.time55.apply_look()
	sample.hero.controls_enabled=true
	var reached: bool=await walk_to(sample,hub+Vector2(-3.5,5.7))
	verify(reached,"front approach and bench-side gap remain walkable")
	sample.hero.controls_enabled=false
	var file := FileAccess.open("res://docs/willow64-validation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"old_seated_foot_samples":old_count,"new_seated_foot_samples":new_count},"\t"))
	print("WILLOW64 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
