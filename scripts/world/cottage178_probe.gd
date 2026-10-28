extends SceneTree
const PLAN=preload("res://scripts/world/forest_plan177.gd")
var checks: Array=[]
var failures: Array=[]
class Walker:
 extends "res://scripts/combat/hero30.gd"
 var command := Vector2.ZERO
 func movement_input() -> Vector2: return command
 func dash_key_down() -> bool: return false
class Trial:
 extends "res://scripts/world/forest_graybox178.gd"
 func hero_script() -> Script: return Walker
func _initialize() -> void: run.call_deferred()
func verify(ok: bool,words: String) -> void:
 checks.append({"check":words,"ok":ok});print("PASS " if ok else "FAIL ",words)
 if not ok: failures.append(words)
func settle(frames := 15) -> void:
 for i in frames: await physics_frame
func shot(tag: String) -> void:
 if DisplayServer.get_name()=="headless": return
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/cottage178_"+tag+".png")
func walk(s: Node3D,target: Vector2) -> bool:
 var frames := 0
 while Vector2(s.hero.position.x,s.hero.position.z).distance_to(target)>.25 and frames<480:
  s.hero.command=(target-Vector2(s.hero.position.x,s.hero.position.z)).normalized();frames+=1;await physics_frame
 s.hero.command=Vector2.ZERO;await settle();return frames<480
func run() -> void:
 root.size=Vector2i(1600,1000);var s := Trial.new();root.add_child(s)
 while not s.ready178: await physics_frame
 await settle()
 var art: Sprite3D=s.terrain.cottage_sprite;var img := art.texture.get_image()
 print("HOUSE_ALPHA ",img.get_pixel(0,0).a," BOUNDS ",s.terrain.alpha_bounds)
 verify(img.has_mipmaps() or img.get_width()>500,"house texture imported as normal resource")
 verify(img.get_pixel(0,0).a<.1,"transparent image background retained")
 verify(art.alpha_cut==SpriteBase3D.ALPHA_CUT_DISCARD,"sprite writes depth and uses alpha cutout")
 verify(s.hero.is_on_floor(),"preview starts grounded in front of cottage")
 verify(absf(art.pixel_size*s.terrain.alpha_bounds.size.x-6.7)<.01,"house drawn at 6.7m opaque width")
 await shot("front")
 verify(await walk(s,PLAN.CENTER+Vector2(-7.,-6.4)),"hero can approach front door")
 verify(s.hero.test_move(s.hero.global_transform,Vector3(0.,0.,-1.5)),"house physical footprint still blocks walking through wall")
 await shot("door")
 s.teleport(PLAN.CENTER+Vector2(-3.7,-4.8));await settle();await shot("side")
 s.teleport(PLAN.CENTER+Vector2(-8.,-11.2));await settle(40)
 verify(art.transparency>.6,"house card fades behind wall instead of hiding hero")
 await shot("behind")
 s.teleport(PLAN.CENTER+Vector2(-7.,-4.8));await settle(40)
 verify(art.transparency<.1,"house opacity restores in front")
 verify(ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/world/world169.tscn","normal default remains world169")
 verify(s.enemies.is_empty(),"art preview adds no combat or progression")
 s.overview=true;s.update_camera(0.,true);await shot("overview")
 FileAccess.open("res://docs/cottage178-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures}," "))
 print("COTTAGE178_DONE ",JSON.stringify({"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
