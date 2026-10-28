extends "res://scripts/world/station84_probe.gd"
class Sample85:
	extends "res://scripts/world/world85.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false
	func hurt_player(_damage: float,_from: Vector2) -> void: pass
	func start_combat(_reposition := true) -> void: pass

func press85(sample: Node3D,at: Vector2,direction: Vector2) -> Vector3:
	sample.hero.controls_enabled=true;sample._teleport15(at);await settle72(12)
	sample.hero.wish=direction
	await settle72(75)
	sample.hero.wish=Vector2.ZERO
	return sample.hero.position

func shot85(sample: Node3D,at: Vector2,tag: String) -> void:
	sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(45)
	var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/station85_"+tag+".png")

func run() -> void:
	var sample := Sample85.new();root.add_child(sample)
	while not is_instance_valid(sample.station81): await physics_frame
	await settle72(20)
	var s: RefCounted=sample.meadow;var foot: Vector2=s.stair_start73()
	verify(sample.rail72.wall_faces85>100,"visible retaining walls and stair cheeks provide shared lateral collision")
	for sign_value in [-1.,1.]:
		var pos := await press85(sample,foot+Vector2(sign_value*4.2,-1.65),Vector2(-sign_value,0))
		print("FRONT85_SIDE ",sign_value," ",pos)
		verify(sign_value*(pos.x-foot.x)>2.9,"front stair "+str(sign_value)+" cheek blocks actual hero from low ground")
	var side := await press85(sample,Vector2(7.,-42.7),Vector2.UP)
	print("MOSS85_SIDE ",side)
	verify(side.z> -44.1,"moss stair outside wall blocks entry from low ground")
	sample.hero.controls_enabled=true;sample._teleport15(foot+Vector2(0,.9));await settle72(8)
	var front_ok := await walk_to(sample,foot-Vector2(0,s.station_stair_run74()+1.))
	front_ok=front_ok and await walk_to(sample,foot+Vector2(0,.9))
	verify(front_ok,"front centre remains climbable and descendable")
	sample._teleport15(s.SIDE_FOOT75+Vector2(.7,0));await settle72(8)
	var side_ok := await walk_to(sample,s.SIDE_TOP75)
	side_ok=side_ok and await walk_to(sample,Vector2(4.8,-49.)) and await walk_to(sample,s.SIDE_TOP75) and await walk_to(sample,s.SIDE_FOOT75)
	verify(side_ok,"moss stairs retain climb landing turn and descent")
	verify(await walk_route72(sample,"junction_to_station"),"winding approach still reaches station")
	var baseline: Resource=preload("res://assets/lighting55/woodland_day57.tres")
	var timing: Node=sample.time55
	verify(timing.noon_weight85(8.)==0. and timing.noon_weight85(16.)==0. and timing.noon_weight85(18.)==0. and timing.noon_weight85(22.)==0.,"noon adjustment leaves morning late afternoon sunset and night untouched")
	verify(timing.noon_weight85(12.)==1. and absf(timing.noon_weight85(10.99)-timing.noon_weight85(11.01))<.001,"noon transition reaches full strength continuously")
	sample.label.get_parent().hide();sample.frames66.panel.hide()
	timing.preview_at(12.);timing.visual_hour=12.;timing.apply_look()
	await shot85(sample,foot+Vector2(0,3.2),"front_noon")
	await shot85(sample,s.SIDE_FOOT75+Vector2(-1.6,3.),"moss_noon")
	for entry in [{"at":s.landmarks.station+Vector2(0,1.),"name":"hall"},{"at":s.landmarks.junction+Vector2(0,5.),"name":"junction"},{"at":s.landmarks.grove,"name":"grove"}]:
		timing.noon_enabled85=false;timing.apply_look();await shot85(sample,entry.at,entry.name+"_old")
		timing.noon_enabled85=true;timing.apply_look();await shot85(sample,entry.at,entry.name+"_new")
	timing.visual_hour=22.;timing.preview_at(22.);timing.apply_look()
	verify(is_equal_approx(sample.sun.light_energy,float(baseline.sample(22.).energy)),"night sun intensity remains the accepted value")
	await shot85(sample,s.landmarks.station+Vector2(0,1.),"hall_night")
	var data := {"checks":checks,"failures":failures,"wall_triangles":sample.rail72.wall_faces85}
	var file := FileAccess.open("res://docs/station85-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
	print("STATION85_VALIDATION ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
