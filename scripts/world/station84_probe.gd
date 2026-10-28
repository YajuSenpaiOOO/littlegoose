extends "res://scripts/world/station83_probe.gd"
class Sample84:
	extends "res://scripts/world/world84.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false
	func hurt_player(_damage: float,_from: Vector2) -> void: pass
	func start_combat(_reposition := true) -> void: pass
func shot84(sample: Node3D,at: Vector2,tag: String) -> void:
	sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(90)
	var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/station84_"+tag+".png")
func run() -> void:
	var sample := Sample84.new();root.add_child(sample)
	while not is_instance_valid(sample.station81): await physics_frame
	await settle72(20)
	var kit: Node3D=sample.station81;var s: RefCounted=sample.meadow;var station: Vector2=s.landmarks.station
	verify(sample.meadow.terrain_hit84 and sample.grounding.hits84>800 and sample.grounding.misses84==0,"terrain and both root-generation passes load static baked data")
	verify(sample.grass_hit84 and sample.grass_pose_hit84,"grass layout and CPU placement transforms both load baked data")
	var grass_valid := true;var varied := false
	for batch in sample.grass_batches:
		for i in mini(3,batch.points.size()):
			var at: Vector3=batch.node.position+batch.node.multimesh.get_instance_transform(i).origin
			grass_valid=grass_valid and absf(at.y-sample.meadow.height_at(at.x,at.z,true))<.02
			var color: Color=batch.node.multimesh.get_instance_custom_data(i)
			varied=varied or color.g>.1
	verify(grass_valid and varied,"cached grass keeps original terrain placement and nonzero colour variation")
	verify(sample.ground.mesh.get_surface_count()==sample.meadow.chunks.size() and sample.floor_tiles.size()>100,"cached terrain retains matching chunk data and physical floor lookup")
	verify(kit.visuals81[0].offset.y==795.-443.5,"hall facade uses stone sill anchor instead of projecting timber feet")
	verify(kit.hall81.get_node("GroundedPropSilhouette63").position.y>.035,"hall cast shadow sits above the plaza paving rather than below it")
	verify(sample.ground_materials[-1].shader.code.contains("retaining_paint84"),"remaining sloped stair backing receives painted retaining-stone treatment")
	verify(sample.rail72.side_steps80.material_override.get_shader_parameter("stair_top84")==true,"treads use separate stone courses rather than broad slate ground texture")
	verify(kit.beds83[0].get_child(0).mesh.get_surface_count()==1,"segmented uneven bed kerbs stay in one batch")
	sample.hero.controls_enabled=true;sample._teleport15(s.SIDE_FOOT75+Vector2(.7,0));await settle72(8)
	var stair_ok := await walk_to(sample,s.SIDE_TOP75)
	stair_ok=stair_ok and await walk_to(sample,Vector2(4.8,-49.)) and await walk_to(sample,s.SIDE_TOP75) and await walk_to(sample,s.SIDE_FOOT75)
	verify(stair_ok,"cached floor preserves side-stair climb landing turn and descent")
	verify(await walk_route72(sample,"home_to_junction"),"actual hero follows home to junction route on cached floor")
	verify(await walk_route72(sample,"junction_to_station"),"actual hero follows winding junction to station route on cached floor")
	verify(await walk_route72(sample,"junction_to_grove"),"actual hero reaches combat clearing on cached floor")
	sample.label.get_parent().hide();sample.frames66.panel.hide()
	sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
	await shot84(sample,s.SIDE_FOOT75+Vector2(-1.6,3.),"side_stairs")
	await shot84(sample,station+Vector2(0,1.0),"hall_day")
	await shot84(sample,station+Vector2(-14.,5.),"border_day")
	sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look()
	await shot84(sample,station+Vector2(0,1.0),"hall_night")
	var data := {"checks":checks,"failures":failures}
	var file := FileAccess.open("res://docs/station84-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
	print("STATION84_VALIDATION ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
