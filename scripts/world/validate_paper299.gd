extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world299.gd"
 func export_stats226() -> Error:return OK
func shot299(tag: String) -> void:
 for i in 4:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/paper299-"+tag+".png")
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.available297:await process_frame
 var s=w.stage297;s.set_process(false)
 check(s.lanes.is_empty() and s.book==null and s.plinth==null,"no old 3D book/floor or sliding plinth")
 check(s.dinosaur298.texture==s.OPERATOR299,"coherent paper grip composition replaces separate operator")
 check(is_equal_approx(s.dinosaur298.pixel_size*s.SHEET_PIXELS299,37./24.),"operator paper body calibrated to ordinary paper height")
 var home=s.girl.position;var initial=0.
 for state in [[.85,"falling"],[1.36,"castle-drop"],[1.95,"wing-drop"],[2.85,"landed"],[6.7,"operator"]]:
  s.sample(state[0]);await shot299(state[1])
  check(is_equal_approx(s.castle.rotation.x,deg_to_rad(-25.)),"castle never flips from ground: "+state[1])
  check(s.girl.position.is_equal_approx(home),"girl remains fixed: "+state[1])
  if state[1]=="falling":initial=s.castle.position.y
  if state[1]=="castle-drop":check(s.castle.position.y<initial-4.,"castle drops vertically toward fixed slot")
 check(absf(s.castle.position.y-s.ground298(0,0))<.005,"castle settles at native summit floor")
 check(s.wings298.all(func(v):return absf(v.position.y-s.ground298(v.position.x,v.position.z))<.005),"both scenery flats settle at local ground")
 check(s.puppet298.visible and s.puppet298.position.z>2.,"tall unified puppet comes around castle without passing low arch")
 s.sample(8.6);s._process(.01);check(w.hero.controls_enabled and not w.combat_paused,"opening restores controls")
 s.start();check(not s.castle.visible and not s.puppet298.visible,"replay clears previous display")
 s.cancel();check(w.hero.controls_enabled and not w.combat_paused,"cancel restores controls")
 FileAccess.open("res://docs/paper299-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"scope":"presentation only, no new boss AI"},"  "))
 quit(0 if checks.all(func(c):return c.pass) else 1)
