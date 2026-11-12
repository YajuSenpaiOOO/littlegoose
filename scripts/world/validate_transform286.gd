extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world286.gd"
 func _init() -> void:
  super._init();memory_save116="user://transform286-validation-preview.cfg"
 func test_config_path226() -> String:return "user://transform286-validation.cfg"
 func reward_path273() -> String:return "user://transform286-validation-reward.cfg"
 func export_stats226() -> Error:return OK
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not is_instance_valid(w.transform286):await process_frame
 w.auto286=0.;w.set_process(false);await settle(4)
 var at: Vector3=w.hero.global_position
 var material=w.hero.visual.material_override
 var collision=w.hero.collision_layer
 var fov=w.camera.fov
 w.start286();var fx=w.transform286
 check(w.intro286 and w.combat_paused and not w.hero.controls_enabled and not w.hero.visual.visible,"intro pauses combat/controls and hides only native visual")
 for t in [.28,.80,1.18,1.86,2.55]:
  fx.sample(t);w.lighting286();w.project286()
  check(w.hero.global_position.is_equal_approx(at) and fx.actor.position==Vector3.ZERO,"foot remains fixed at timeline %.2f"%t)
  await shot("transform286-%.2f"%t)
 # Opaque real 3D panel must occlude the transformed actor, not just native hero.
 fx.sample(1.86);w.lighting286();w.project286()
 var panel=MeshInstance3D.new();var quad=QuadMesh.new();quad.size=Vector2(6,6);panel.mesh=quad
 var mat=StandardMaterial3D.new();mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;mat.albedo_color=Color(.03,.08,.95);panel.material_override=mat;w.add_child(panel)
 var centre=w.hero.global_position+Vector3.UP*.9
 panel.global_transform=Transform3D(w.camera.global_basis,centre+w.camera.global_basis.z)
 await shot("transform286-front-occluder")
 var where=w.camera.unproject_position(centre);var im=root.get_texture().get_image();var c=im.get_pixelv(Vector2i(where))
 check(c.b>.3 and c.b>c.r*3.,"real front panel occludes transform portrait and light geometry")
 panel.global_position-=w.camera.global_basis.z*2.
 await shot("transform286-behind-occluder")
 im=root.get_texture().get_image();c=im.get_pixelv(Vector2i(where))
 check(not (c.b>.3 and c.b>c.r*3.),"transform portrait renders before a rear panel")
 panel.queue_free();await process_frame
 fx.sample(4.0);var hanging=fx.last_cape[-1].y
 fx.motion_target=Vector3(4,0,0);fx.advance(.3)
 check(fx.last_cape[-1].y>hanging+.1,"motion raises and trails the hanging ribbon ends")
 await shot("transform286-moving")
 fx.motion=Vector3.ZERO;fx.motion_target=Vector3.ZERO;fx.sample(4.0)
 check(fx.last_cape[-1].y<fx.last_cape[0].y,"stationary cape naturally hangs below its shoulders")
 await shot("transform286-hanging")
 fx.sample(.85)
 check(fx.strips[8].get_aabb().size.y>60.,"upward flash beam extends far beyond the character/viewport")
 fx.age=3.14;fx.advance(.02)
 check(not w.intro286 and not w.combat_paused and w.hero.controls_enabled and w.hero.visual.visible,"reveal restores native hero/control/pause state")
 check(fx.cape_amount()>.9 and not fx.actor.visible,"gold ribbons persist after hero reveal without a portrait duplicate")
 check(w.hero.visual.material_override==material and w.hero.collision_layer==collision,"native hero material and collision preserved")
 check(is_equal_approx(w.camera.fov,fov),"reveal restores original camera FOV")
 fx.age=9.99;fx.advance(.02)
 check(not fx.playing and w.shade286.color.a==0.,"end releases all effect state")
 w.start286();w.cancel286()
 check(not w.intro286 and not fx.playing and w.hero.visual.visible and w.hero.controls_enabled,"cancel restores hero visibility and controls")
 w.start286();w.start286();w.cancel286()
 check(not w.combat_paused and w.hero.controls_enabled,"reentry cannot overwrite saved restore state")
 w.combat_paused=true;w.start286()
 check(not fx.playing,"no activation through paused/dialog state")
 w.combat_paused=false
 var ok=checks.all(func(c):return c.pass)
 var f=FileAccess.open("res://docs/transform286-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"checks":checks,"visual_acceptance":"pending user","limitations":"native world geometry with depth; forest occlusion still inherits old scene issues; no active skill conversion"},"  "));f.close()
 print("TRANSFORM286_VALIDATION ",ok);quit(0 if ok else 1)
