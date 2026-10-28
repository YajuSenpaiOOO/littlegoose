extends "res://scripts/ground_lab_probe.gd"
class Actor:
	extends "res://scripts/combat/hero36.gd"
	var test_direction := Vector2.ZERO
	func movement_input() -> Vector2: return test_direction
	func dash_key_down() -> bool: return false
	func parry_key_down() -> bool: return false
class Sample:
	extends "res://scripts/world/world36.gd"
	func _hero_script() -> Script: return Actor
	func fire_at(_target: Vector3) -> void: pass

func press(hero: CharacterBody3D,key: Key,down := true,repeat := false) -> void:
	var input := event(key)
	input.pressed=down; input.echo=repeat
	hero._input(input)

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
	var hero: CharacterBody3D=sample.hero
	hero.set_physics_process(false)
	for vertical in [KEY_W,KEY_S]:
		for horizontal in [KEY_A,KEY_D]:
			hero.walk_key_order.clear()
			press(hero,vertical); press(hero,horizontal)
			hero.test_direction=(hero.WALK_KEYS[vertical]+hero.WALK_KEYS[horizontal]).normalized()
			hero.render_pose()
			verify(hero.facing==("left" if horizontal==KEY_A else "right"),"vertical then horizontal selects last key: "+str(vertical)+" / "+str(horizontal))
			press(hero,vertical,true,true); hero.render_pose()
			verify(hero.facing==("left" if horizontal==KEY_A else "right"),"OS key repeat cannot steal facing from newer horizontal key")
			press(hero,horizontal,false); hero.test_direction=hero.WALK_KEYS[vertical]; hero.render_pose()
			verify(hero.facing==("up" if vertical==KEY_W else "down"),"releasing latest key restores remaining held direction")
			hero.walk_key_order.clear(); press(hero,horizontal); press(hero,vertical)
			hero.test_direction=(hero.WALK_KEYS[vertical]+hero.WALK_KEYS[horizontal]).normalized(); hero.render_pose()
			verify(hero.facing==("up" if vertical==KEY_W else "down"),"horizontal then vertical also selects the last key")
	hero.reset_actions(); press(hero,KEY_W); press(hero,KEY_D)
	hero.test_direction=Vector2(1,-1).normalized()
	verify(hero.request_dash() and hero.dash_pose=="right","dash captures newest directional input before the next walking tick")
	var locked_dash: Vector2=hero.dash_direction
	press(hero,KEY_W,false); press(hero,KEY_W); hero.render_pose()
	verify(hero.dash_pose=="right" and hero.dash_direction==locked_dash and hero.visual.texture==hero.dash_art.right.texture,"changing key priority during dash never flips its locked animation or trajectory")
	hero.reset_actions(); hero.test_direction=Vector2.LEFT
	press(hero,KEY_A); hero.render_pose(); hero.test_direction=Vector2.ZERO
	hero.render_pose()
	verify(hero.facing=="left","stopping preserves the last facing instead of following residual motion")
	hero._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	verify(hero.walk_key_order.is_empty(),"losing window focus clears stale held-key priority")
	var center: Vector2=sample.meadow.landmarks.grove
	var origin := Vector3(center.x,sample.floor_height(center)+.04,center.y+2.)
	hero.position=origin
	var enemy: CharacterBody3D=sample.enemies[0]
	for other in sample.enemies: other.position=origin+Vector3(15,0,0)
	enemy.position=origin+Vector3(0,0,-3.); enemy.home=Vector2(origin.x,origin.z)
	enemy.active_ai=true; enemy.impulse=Vector2.ZERO; enemy.hopping=false
	enemy._begin_windup(Vector2(hero.position.x,hero.position.z))
	var first: Vector2=enemy.attack_direction
	hero.position+=Vector3(1.2,0,.3)
	enemy._physics_process(.30)
	verify(enemy.attack_phase=="windup" and enemy.attack_direction.distance_to(first)>.1,"late windup keeps tracking after the old 0.18s lock point")
	enemy._physics_process(.17)
	hero.position+=Vector3(-.5,0,.25)
	enemy._physics_process(.02)
	var to_hero := Vector2(hero.position.x-enemy.position.x,hero.position.z-enemy.position.z)
	verify(enemy.attack_phase=="lunge" and enemy.attack_direction.dot(to_hero.normalized())>.9999,"takeoff snapshots the hero position from the exact final windup tick")
	verify(is_equal_approx(enemy.attack_distance,to_hero.length()+.35),"normal-range leap lands 0.35m beyond the takeoff target")
	var committed: Vector2=enemy.attack_direction
	var committed_distance: float=enemy.attack_distance
	hero.position+=Vector3(2,0,0)
	enemy._physics_process(.03)
	verify(enemy.attack_direction==committed and enemy.attack_distance==committed_distance,"airborne attack stays committed and cannot home onto a late dodge")
	# Return to the snapshotted target: a real swept jump must reach it once.
	hero.position-=Vector3(2,0,0)
	sample.player_hp=100.; sample.invulnerability=0.
	var hurt_before: int=sample.hurt_count
	for i in 24: enemy._physics_process(1./60.)
	verify(sample.player_hp==80. and sample.hurt_count==hurt_before+1,"native lunge reaches the updated target and applies damage exactly once")
	enemy._lock_direction(Vector2(enemy.position.x+50.,enemy.position.z))
	verify(is_equal_approx(enemy.attack_distance,6.2),"teleports or distant targets cannot create an unbounded lunge")
	sample._reset_impact_state()
	print("CONTROLS36 ",checks," checks; failures=",failures.size())
	sample.queue_free(); await process_frame
	quit(0 if failures.is_empty() else 1)
