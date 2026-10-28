extends "res://scripts/ground_lab_probe.gd"
class Actor:
	extends "res://scripts/combat/hero36.gd"
	func movement_input() -> Vector2: return Vector2.ZERO
	func dash_key_down() -> bool: return false
	func parry_key_down() -> bool: return false
class Sample:
	extends "res://scripts/world/world36.gd"
	var scripted_fire := false
	func _hero_script() -> Script: return Actor
	func fire_at(target: Vector3) -> void:
		if scripted_fire: super.fire_at(target)

func run() -> void:
	var sample: Node3D=Sample.new()
	root.add_child(sample)
	while not sample.parry_ready: await physics_frame
	sample.set_process_unhandled_input(false)
	sample.start_combat(); sample.set_cup_phone(false); sample.invulnerability=0.
	var hero: CharacterBody3D=sample.hero
	var enemy: CharacterBody3D=sample.enemies[0]
	for other in sample.enemies:
		other.active_ai=false
		other.position+=Vector3(15,0,0)
	var center: Vector2=sample.meadow.landmarks.grove
	hero.position=Vector3(center.x,sample.floor_height(center)+.04,center.y+2.)
	enemy.position=hero.position+Vector3(0,0,-3.)
	enemy.active_ai=true; enemy.hopping=false; enemy.phase_clock=.2
	hero.reset_physics_interpolation(); enemy.reset_physics_interpolation()
	var warning_saved := false
	var deadline := Time.get_ticks_msec()+12000
	while sample.parry_count==0 and Time.get_ticks_msec()<deadline:
		if enemy.attack_phase=="windup" and enemy.phase_clock>.26 and not warning_saved:
			var warning: Image=await snapshot()
			warning.save_png("res://docs/captures/world_restart/controls36_live_tell.png")
			warning_saved=true
		if enemy.attack_phase=="lunge" and enemy.position.distance_to(hero.position)<2.:
			hero.request_parry()
		await physics_frame
	verify(sample.parry_count==1 and sample.player_hp==100.,"live right-click timing catches a genuinely moving lunge without player damage")
	verify(warning_saved and not enemy.cue.visible,"live crouch and held direction are readable with no ground arrow")
	var impact: Image=await snapshot()
	impact.save_png("res://docs/captures/world_restart/controls36_live_parry.png")
	verify(get_nodes_in_group("parry_art").size()>0 and hero.visual.texture.resource_path.contains("parry_crouch"),"original guard art and impact flash render during actual hitstop")
	var until := Time.get_ticks_msec()+550
	while Time.get_ticks_msec()<until: await process_frame
	verify(enemy.parried_count==1 and enemy.attack_phase=="recover","deflected attacker remains in the real counterattack window")
	var hp_before: float=enemy.hp
	sample.scripted_fire=true; sample.fire_at(enemy.position+Vector3.UP*.8); sample.scripted_fire=false
	var timeout := Time.get_ticks_msec()+2500
	while enemy.hp==hp_before and Time.get_ticks_msec()<timeout: await physics_frame
	verify(enemy.hp<hp_before,"native goose shot can punish the parried enemy's recovery")
	await create_timer(.7,true,false,true).timeout
	verify(Engine.time_scale==1.,"parry hitstop and slow-motion sandwich recover to normal time")
	print("PARRY36_CAPTURE ",checks," checks; failures=",failures.size())
	sample.queue_free(); await process_frame
	quit(0 if failures.is_empty() else 1)

