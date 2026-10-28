extends "res://scripts/world/combat111_probe.gd"
class Trial:
 extends "res://scripts/world/woodland_world115.gd"
 func _hero_script() -> Script: return Fighter
func run() -> void:
 root.size=Vector2i(1600,1000);DisplayServer.window_set_size(root.size)
 var s := Trial.new();root.add_child(s)
 while not s.woodland_ready115: await physics_frame
 verify(s.trial_ui114.menu.visible and not s.active114 and s.combat_paused,"initial menu waits for an explicit mode selection")
 var image := await snapshot();image.save_png("res://docs/captures/world_restart/trial115_menu.png")
 var box: VBoxContainer=s.trial_ui114.menu.get_child(0)
 box.get_child(2).pressed.emit();verify(not s.auto114 and s.active114,"A button starts manual fire mode")
 verify(s.enemies.size()==3 and s.buffs.levels.is_empty(),"trial has exactly three enemies and no cards")
 var health_equal := true
 for enemy in s.enemies: health_equal=health_equal and enemy.hp==4. and enemy.rank110==0
 verify(health_equal and absf(s.attack_cooldown()-.34)<.00001,"both trials use ordinary four-hit enemies and slow basic fire")
 disable_enemies(s);s.hero.set_physics_process(false);s.hero.controls_enabled=true
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(0,2))
 var enemy: CharacterBody3D=s.enemies[0];var at := g+Vector2(1.,-1.)
 enemy.position=Vector3(at.x,s.floor_height(at)+.06,at.y)
 for i in [1,2]: s.enemies[i].position+=Vector3(40,0,40)
 await settle72(5)
 var point: Vector2=s.camera.unproject_position(enemy.hit_area.global_position)+Vector2(15,0)
 s.aim_tick114=-1;var aim: Vector3=s.aim_at_screen(point)
 verify(s.target114==enemy and aim.distance_to(enemy.hit_area.global_position)<.01,"directional assistance acquires a nearby body despite cursor offset")
 var upper := s.camera.unproject_position(enemy.global_position+Vector3.UP*1.25)
 s.aim_tick114=-1;s.aim_at_screen(upper)
 verify(s.target114==enemy,"aiming at the visible upper body also selects its actual collision center")
 # Acquire well outside the sprite, then retain outside the acquisition cone.
 s.target114=null;s.aim_tick114=-1
 var broad := cursor115(s,enemy,.45);s.aim_at_screen(broad)
 verify(s.target114==enemy and not s.aim_model.sprite_contains(s.camera,broad,enemy.visual),"a broad direction acquires the enemy with the cursor completely off its sprite")
 var retained := cursor115(s,enemy,.80);s.aim_tick114=-1;s.aim_at_screen(retained)
 verify(s.target114==enemy,"target remains selected at 46 degrees after leaving the body and acquisition cone")
 root.warp_mouse(retained);await settle72(18);s.aim_tick114=-1;s.aim_at_screen(retained)
 verify(s.target114==enemy,"off-body selection persists across frames instead of expiring immediately")
 var near_player := s.camera.unproject_position(s.hero.global_position+Vector3.UP*.8)+Vector2(2,2)
 s.aim_tick114=-1;s.aim_at_screen(near_player)
 verify(s.target114==enemy,"small cursor movement near the player preserves the existing target")
 var saved_position := enemy.position;enemy.position=s.hero.position+Vector3(.12,0,0);s.target114=null;s.aim_tick114=-1
 s.aim_at_screen(s.camera.unproject_position(enemy.hit_area.global_position))
 verify(s.target114==enemy,"direct body selection works even when an enemy overlaps the cursor dead zone")
 enemy.position=saved_position
 var second: CharacterBody3D=s.enemies[1];var second_at := g+Vector2(-2.5,-1.)
 second.position=Vector3(second_at.x,s.floor_height(second_at)+.06,second_at.y);await settle72(3)
 s.target114=enemy;s.aim_tick114=-1
 var screen_origin := s.camera.unproject_position(s.hero.global_position+Vector3.UP*.8)
 var first_dir := s.camera.unproject_position(enemy.hit_area.global_position)-screen_origin
 var next_dir := s.camera.unproject_position(second.hit_area.global_position)-screen_origin
 var boundary := screen_origin+first_dir.normalized().rotated(first_dir.angle_to(next_dir)*.53)*500.
 s.aim_at_screen(boundary)
 verify(s.target114==enemy,"small cursor motion across a selection boundary retains the current target")
 s.aim_tick114=-1;s.aim_at_screen(s.camera.unproject_position(second.hit_area.global_position))
 verify(s.target114==second,"pointing directly at another enemy deliberately switches the target")
 second.position+=Vector3(40,0,40);s.target114=enemy
 var opposite: Vector2=cursor115(s,enemy,PI)
 s.aim_tick114=-1;s.aim_at_screen(opposite)
 verify(s.target114==null,"a clear turn away releases the old target and enables free aiming")
 s.auto114=true;s.aim_tick114=-1;s.aim_at_screen(opposite)
 verify(s.target114==enemy and s.fire_input_held(),"automatic mode selects a visible nearby threat regardless of cursor")
 s.hero.guarding109=true;verify(not s.fire_input_held(),"held guard suppresses automatic fire");s.hero.guarding109=false
 var origin: Vector3=s.projectile_origin();var wall := StaticBody3D.new();wall.collision_layer=2
 var collider := CollisionShape3D.new();var shape := BoxShape3D.new();shape.size=Vector3(1.2,3.,.3);collider.shape=shape;wall.add_child(collider);s.add_child(wall);wall.global_position=origin.lerp(enemy.hit_area.global_position,.5)
 await settle72(3);s.aim_tick114=-1;s.aim_at_screen(point)
 verify(s.target114==null and not s.fire_input_held(),"automatic selection rejects targets occluded by actual scenery")
 wall.queue_free();await settle72(3);s.auto114=false;s.aim_tick114=-1;s.aim_at_screen(point)
 var off_body := cursor115(s,enemy,.80);s.aim_tick114=-1;s.aim_at_screen(off_body)
 root.warp_mouse(off_body);await process_frame;image=await snapshot();image.save_png("res://docs/captures/world_restart/trial115_manual.png")
 verify(s.target114==enemy,"the visible ring still corresponds to the shot target while the cursor stays off-body")
 var count_before: int=s.fired_count;await settle72(10)
 verify(s.fired_count==count_before,"manual mode does not shoot merely because an enemy is selected")
 for i in 4: s.fire_at(s.aim_at_screen(off_body))
 await settle72(75)
 verify(enemy.dead and s.landed_hits>=4,"four shots fired with the cursor off-body still hit the selected native collider")
 for other in s.enemies:
  if is_instance_valid(other) and not other.dead: other.receive_hit(999.,Vector3.RIGHT)
 verify(not s.draft_open and s.wave_state=="fighting" and s.refill114>0.,"pack clear schedules a breather without opening cards or victory")
 await settle72(65);disable_enemies(s)
 verify(s.enemies.size()==3 and not s.enemies[0].dead and s.defeated_count==3,"breather refills three enemies while retaining run statistics")
 var before: float=s.elapsed114;s.combat_paused=true;s._physics_process(.5)
 verify(s.elapsed114==before,"paused trial does not consume its timer")
 s.combat_paused=false;s.elapsed114=44.99;s._physics_process(.02)
 verify(not s.active114 and s.trial_ui114.menu.visible and s.results114.has("A") and not s.draft_open,"45-second timer ends safely and records A results")
 box.get_child(3).pressed.emit();disable_enemies(s)
 verify(s.auto114 and s.active114 and s.elapsed114<.01 and s.defeated_count==0 and s.player_hp==100.,"B button resets health, clock, kills and mode")
 await settle72(5);root.warp_mouse(Vector2(40,900));await process_frame;image=await snapshot();image.save_png("res://docs/captures/world_restart/trial115_auto.png")
 s.finish114();verify(s.results114.has("A") and s.results114.has("B"),"comparison retains the last result of both modes")
 image=await snapshot();image.save_png("res://docs/captures/world_restart/trial115_results.png")
 var event := InputEventKey.new();event.physical_keycode=KEY_F2;event.pressed=true;s._unhandled_input(event)
 verify(not s.auto114 and s.active114 and s.buffs.levels.is_empty(),"F2 switches modes and starts a fresh card-free trial")
 s.player_hp=0.;s._physics_process(1./60.)
 verify(not s.active114 and s.trial_ui114.menu.visible,"defeat ends at comparison without an old victory/draft overlay")
 var data := {"checks":checks,"failures":failures};var file := FileAccess.open("res://docs/combat115-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));print("TRIAL115_DONE ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)

func cursor115(s: Node3D,enemy: CharacterBody3D,angle: float) -> Vector2:
 var origin: Vector2=s.camera.unproject_position(s.hero.global_position+Vector3.UP*.8)
 var direction: Vector2=s.camera.unproject_position(enemy.hit_area.global_position)-origin
 return origin+direction.normalized().rotated(angle)*500.
