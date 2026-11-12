extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world285.gd"
 func _init() -> void:
  super._init();memory_save116="user://transform285-validation-preview.cfg"
 func test_config_path226() -> String:return "user://transform285-validation.cfg"
 func reward_path273() -> String:return "user://transform285-validation-reward.cfg"
 func export_stats226() -> Error:return OK
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not is_instance_valid(w.transform285):await process_frame
 w.auto285=0.;w.set_process(false);await settle(4)
 var at: Vector3=w.hero.global_position
 var material=w.hero.visual.material_override
 var collision=w.hero.collision_layer
 var fov=w.camera.fov
 w.start285();var fx=w.transform285
 check(w.intro285 and w.combat_paused and not w.hero.controls_enabled and not w.hero.visual.visible,"intro pauses combat/controls and hides only native visual")
 for t in [.28,.8,1.45,1.86,2.55]:
  fx.sample(t);w.lighting285();w.project285()
  check(w.hero.global_position.is_equal_approx(at) and fx.actor.position==Vector2.ZERO,"foot remains fixed at timeline %.2f"%t)
  await shot("transform285-%.2f"%t)
 fx.age=3.14;fx.advance(.02)
 check(not w.intro285 and not w.combat_paused and w.hero.controls_enabled and w.hero.visual.visible,"reveal restores native hero/control/pause state")
 check(fx.cape_amount()>.9 and not fx.actor.visible,"gold ribbons persist after hero reveal without a portrait duplicate")
 check(w.hero.visual.material_override==material and w.hero.collision_layer==collision,"native hero material and collision preserved")
 check(is_equal_approx(w.camera.fov,fov),"reveal restores original camera FOV")
 fx.age=6.99;fx.advance(.02)
 check(not fx.playing and w.shade285.color.a==0.,"end releases all effect state")
 w.start285();w.cancel285()
 check(not w.intro285 and not fx.playing and w.hero.visual.visible and w.hero.controls_enabled,"cancel restores hero visibility and controls")
 w.start285();w.start285();w.cancel285()
 check(not w.combat_paused and w.hero.controls_enabled,"reentry cannot overwrite saved restore state")
 w.combat_paused=true;w.start285()
 check(not fx.playing,"no activation through paused/dialog state")
 w.combat_paused=false
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/transform285-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks,"visual_acceptance":"pending user","limitations":"screen overlay choreography, no 3D occlusion/light casting, no active skill/damage conversion"},"  "));f.close()
 print("TRANSFORM285_VALIDATION ",ok);quit(0 if ok else 1)
