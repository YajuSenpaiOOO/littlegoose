extends "res://scripts/world/validate_roller269.gd"
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.ready264:await process_frame
 w.auto114=false;w.ordinary264();w.hero.set_physics_process(false)
 var m=w.live_minions260()[0];m.set_physics_process(false)
 var centre: Vector2=w.meadow.landmarks.grove
 m.position=Vector3(centre.x,w.floor_height(centre)+.03,centre.y)
 w.hero.position=m.position+Vector3(2.,0,2.);w._update_camera(0.,true)
 m.enter269("charge");m._physics_process(.4);w.combat_paused=true;await shot("roller269-charge-close")
 w.combat_paused=false;m.enter269("rolling");m._physics_process(.08);w.combat_paused=true;await shot("roller269-roll-close")
 w.combat_paused=false;m.enter269("dizzy");m._physics_process(.4);w.combat_paused=true;await shot("roller269-dizzy-close")
 quit()
