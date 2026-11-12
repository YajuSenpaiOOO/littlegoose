extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world290.gd"
 func export_stats226() -> Error:return OK
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not is_instance_valid(w.transform288):await process_frame
 w.auto114=false;w.boss_unlocked264=true;w.boss264()
 w.set_process(false);w.set_physics_process(false);w.hero.set_physics_process(false)
 var b=w.boss247;b.set_physics_process(false)
 var native_visual=b.visual;var target=b.hit_area.get_child(0).shape;var hp=b.hp
 check(not b.resting265,"battle uses active boss, not sleeping NPC")
 for phase in ["rest","angry","squat","flight","flat","bumper"]:
  b.enter247(phase);b.clock247=.2;b.lift247=1. if phase=="flight" else 0.
  b.hit_left=0.;b.landing_left=0.
  b.glass290=false;b.render247()
  var pose="idle"
  for name in b.textures:
   if b.textures[name]==b.visual.texture:pose=name;break
  var entry: Dictionary=b.poses[pose]
  var old_span=Vector2(float(entry.visible_width),float(entry.visible_height))/24.*b.body_scale110*Vector2(b.visual.scale.x,b.visual.scale.y)
  # Compare opaque silhouette, rather than transparent canvas.
  b.glass290=true;b.render247()
  check(b.visual.texture==b.GLASS290 and b.soft_ink.get_shader_parameter("art")==b.GLASS290,phase+" selected skin reaches native renderer")
  check(is_equal_approx(b.soft_ink.get_shader_parameter("foot_y"),983./1160.),phase+" shader uses new foot coordinate")
  check(b.visual==native_visual and b.hit_area.get_child(0).shape==target and b.hp==hp,phase+" visual identity/collider/HP preserved")
  check(b.visual.scale.is_finite(),phase+" finite deformation")
  var new_span=b.SPAN290*b.visual.pixel_size*Vector2(b.visual.scale.x,b.visual.scale.y)
  check(old_span.distance_to(new_span)<.001,phase+" matches legacy world silhouette size")
  check(is_equal_approx(b.visual.offset.y+b.visual.texture.get_height()*.5,b.FOOT290.y),phase+" foot is scale pivot")
  if phase in ["rest","squat","flight","flat"]:
   await shot290(phase)
 b.glass290=false;b.render247();check(b.visual.texture!=b.GLASS290,"old skin comparison restores old art")
 b.glass290=true;b.render247()
 b.receive_hit(1.,Vector3.RIGHT);check(b.hp<hp and b.visual.texture==b.GLASS290,"damage reaction keeps selected skin")
 check(is_instance_valid(w.projection250),"native ground shadow remains attached")
 b.enter247("rest");b.hit_left=0.;b.landing_left=0.;w.invulnerability=100.
 var seen={}
 for i in 600:
  seen[b.phase247]=true;b._physics_process(1./60.)
 check(seen.has("angry") and seen.has("squat") and seen.has("flight") and seen.has("flat"),"native ten second AI cycle traverses charge, jumps and recovery")
 FileAccess.open("res://docs/boss290-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks},"  "))
 quit(0 if checks.all(func(c):return c.pass) else 1)
func shot290(tag: String) -> void:
 for i in 3:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/boss290-"+tag+".png")
