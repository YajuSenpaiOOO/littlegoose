extends "res://scripts/world/forest202_capture.gd"
func result_prefix192() -> String: return "forest203"
func world_script192() -> Script: return preload("res://scripts/world/woodland_world203.gd")
func extra_checks192() -> void:
 while not sample.ready203: await physics_frame
 sample._clear_combat_shots();sample.player_hp=1000.;sample.invulnerability=100.;sample.hero.controls_enabled=false
 for enemy in sample.enemies: enemy.set_physics_process(false)
 var actor: CharacterBody3D=sample.enemies[0]
 var at: Vector2=Vector2(sample.hero.position.x-2.,sample.hero.position.z)
 actor.position=Vector3(at.x,sample.floor_height(at)+.06,at.y);actor.hp=1000.;actor.max_hp110=1000.;actor.actions172=0
 actor.prepare170(Vector2(sample.hero.position.x,sample.hero.position.z));actor.clock170=.3
 verify(actor.state170=="weave","fixture enters the real weaving state")
 var clock: float=actor.clock170;var pad: CharacterBody3D=actor.pad172
 var offset: Vector2=actor.visual.offset
 sample.fluff203.clear203();actor.fluff_gate203=0.
 actor.receive_hit(1.,Vector3.RIGHT)
 offset=actor.visual.offset
 verify(actor.state170=="weave" and actor.clock170==clock and actor.pad172==pad,"hit preserves weaving state, timer and the existing pad")
 verify(sample.fluff203.motes.size()==4,"spider hit emits four fluff clusters via dedicated contact callback")
 sample.swords153.contact158.pop158(actor.position+Vector3.UP*.6,Vector3.RIGHT,actor.get_instance_id())
 verify(sample.swords153.contact158.events158.is_empty(),"balloon sword spider contact also avoids jelly droplets")
 actor._render_legacy(0.)
 var scale: Vector3=actor.visual.scale
 verify(scale.x>1.10 and scale.y<.90,"hit visibly squashes the active pose")
 for i in 20: actor._render_legacy(0.)
 verify(actor.visual.scale.is_equal_approx(scale) and actor.visual.offset==offset,"re-rendering does not accumulate deformation or shift the foot anchor")
 await hour(12.);actor.hit_age203=1.;actor.fluff_gate203=0.;actor.receive_hit(1.,Vector3.RIGHT);await picture("weave_hit")
 actor.set_physics_process(true)
 await settle(180)
 verify(actor.celebrations172>0 and pad.live172,"weaving completes and celebrates after taking a hit")
 actor.set_physics_process(false);actor.hit_age203=1.;actor.flash=0.;actor.enter170("watch");actor._render_legacy(0.)
 verify(absf(actor.visual.scale.x-1.)<.001,"hit deformation settles back to normal")
 var hp: float=sample.player_hp
 sample.hero.position=actor.position+Vector3(.5,0,0);actor.nudge_gate203=0.;actor._physics_process(.016)
 verify(sample.player_hp==hp and sample.hero.combat_impulse.length()>.1,"body proximity gently nudges without contact damage")
 sample.stop_trial202();await settle(5)
 verify(sample.fluff203.motes.is_empty(),"stop and restart clear transient fluff")
 verify(sample.forest188.kitten181.texture==preload("res://assets/forest203/ghost_kitten.png") and sample.forest188.pop_board194.texture==sample.forest188.kitten181.texture,"hanging cat and popup puppet use the redrawn sprite")
 sample._teleport15(Vector2(-43.,30.));await settle(80);await picture("new_ghost_day")
 await hour(22.);await picture("new_ghost_night")
