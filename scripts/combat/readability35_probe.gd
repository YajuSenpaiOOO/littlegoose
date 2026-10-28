extends "res://scripts/ground_lab_probe.gd"
class Actor:
	extends "res://scripts/combat/hero34.gd"
	func movement_input() -> Vector2: return Vector2.ZERO
	func dash_key_down() -> bool: return false
	func parry_key_down() -> bool: return false
class Sample:
	extends "res://scripts/world/world35.gd"
	func _hero_script() -> Script: return Actor
	func fire_at(_target: Vector3) -> void: pass

func run() -> void:
	var sample: Node3D=Sample.new()
	root.add_child(sample)
	while not sample.parry_ready: await physics_frame
	sample.set_process_unhandled_input(false)
	sample.start_combat(); sample.set_cup_phone(false)
	for actor in sample.enemies:
		actor.active_ai=false; actor.set_physics_process(false)
	for i in 25: await physics_frame
	sample.set_process(false); sample.set_physics_process(false)
	sample.hero.set_physics_process(false)
	var center: Vector2=sample.meadow.landmarks.grove
	sample.hero.position=Vector3(center.x,sample.floor_height(center)+.04,center.y+2.)
	sample._update_camera(0.,true)
	var enemy: CharacterBody3D=sample.enemies[0]
	enemy.position=sample.hero.position+Vector3(0,0,-2.)
	enemy.hit_left=0.; enemy.squeeze=0.; enemy.landing_left=0.
	enemy.attack_phase="windup"; enemy.phase_clock=.20
	enemy._render_legacy(0.); enemy.small_cue._process(0.)
	verify(enemy.visual.texture==enemy.textures.anticipation,"windup holds the authored compressed anticipation silhouette")
	verify(not enemy.small_cue.visible,"early windup has no extra marker")
	enemy.phase_clock=.40; enemy._render_legacy(0.); enemy.small_cue._process(0.)
	verify(enemy.small_cue.visible and not enemy.cue.visible,"only the small glint appears just before takeoff; no arrow")
	var crouch_height: float=float(enemy.poses.anticipation.visible_height)*enemy.visual.scale.y
	var warning: Image=await snapshot()
	warning.save_png("res://docs/captures/world_restart/readability35_windup.png")
	sample._unhandled_input(event(KEY_PAGEDOWN)); enemy.small_cue._process(0.)
	verify(not enemy.small_cue.visible,"PageDown gives an action-only comparison")
	sample._unhandled_input(event(KEY_PAGEDOWN))
	enemy.attack_phase="lunge"; enemy._render_legacy(.3); enemy.small_cue._process(0.)
	verify(not enemy.small_cue.visible,"glint ends immediately on takeoff")
	enemy.attack_phase="recover"; enemy.phase_clock=0.; enemy.landing_left=.12
	enemy._render_legacy(0.)
	verify(enemy.visual.texture==enemy.textures.landing,"landing still briefly compresses on impact")
	var landing: Image=await snapshot()
	landing.save_png("res://docs/captures/world_restart/readability35_landing.png")
	enemy.phase_clock=.25; enemy.landing_left=0.; enemy._render_legacy(0.); enemy.small_cue._process(0.)
	verify(enemy.visual.texture==enemy.textures.idle,"recovery regains its standing silhouette instead of holding the landing frame")
	verify(float(enemy.poses.idle.visible_height)*enemy.visual.scale.y>crouch_height*1.15,"standing recovery has a visibly taller outline than held windup")
	verify(not enemy.small_cue.visible,"recovery never reuses the takeoff glint")
	var recovery: Image=await snapshot()
	recovery.save_png("res://docs/captures/world_restart/readability35_recovery.png")
	enemy.active_ai=true; enemy.hopping=false; enemy.phase_clock=.40
	enemy._physics_process(.10)
	verify(enemy.attack_phase=="recover","standing recovery still gives the player the original punish time")
	enemy._physics_process(.13)
	verify(enemy.attack_phase=="approach","recovery still ends at the original 0.62 seconds")
	enemy.dead=true; enemy.small_cue._process(0.)
	verify(not enemy.small_cue.visible,"defeated enemies never show attack cues")
	print("READABILITY35 ",checks," checks; failures=",failures.size())
	sample.queue_free(); await process_frame
	quit(0 if failures.is_empty() else 1)
