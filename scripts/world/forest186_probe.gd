extends "res://scripts/world/forest180_probe.gd"
const P=preload("res://scripts/world/forest_plan183.gd")
const D=preload("res://scripts/world/forest_dressing183.gd")
const MOOD=preload("res://scripts/art/forest_mood186.gd")
class Walker186:
 extends "res://scripts/combat/hero183.gd"
 var command := Vector2.ZERO
 func movement_input() -> Vector2: return command if controls_enabled else Vector2.ZERO
 func dash_key_down() -> bool: return false
 func parry_key_down() -> bool: return false
class Trial186:
 extends "res://scripts/world/woodland_world186.gd"
 func _hero_script() -> Script: return Walker186
func shot(tag: String) -> void:
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/forest186_"+tag+".png")
func picture186() -> Image:
 await process_frame;await RenderingServer.frame_post_draw
 return root.get_texture().get_image()
func compare186(s: Node3D,tag: String) -> void:
 s.forest_mood186.enabled=false;await settle(130);var off := await picture186();off.save_png("res://docs/captures/world_restart/forest186_"+tag+"_plain.png")
 s.forest_mood186.enabled=true;await settle(130);var on := await picture186();on.save_png("res://docs/captures/world_restart/forest186_"+tag+"_mood.png")
 var plain := 0.;var mood := 0.;var pixels := 0
 for y in range(350,850,4):
  for x in range(400,1250,4):
   var a := off.get_pixel(x,y);var b := on.get_pixel(x,y)
   plain+=(a.r+a.g+a.b)/3.;mood+=(b.r+b.g+b.b)/3.;pixels+=1
 verify(mood<plain*.90 and mood>plain*.32,"regional atmosphere has visible, nonblack exposure change in "+tag+": "+str(mood/maxf(plain,.001)))
 print("MOOD186 ",tag," plain=",plain/pixels," mood=",mood/pixels)
func run() -> void:
 root.size=Vector2i(1600,1000);var s := Trial186.new();s.memory_save116="user://forest186_probe_tmp.cfg";root.add_child(s)
 while not s.forest_ready186: await physics_frame
 await settle(90);var art: Node3D=s.forest186
 verify(art.native_casters184.is_empty(),"sphere crowns and axis-aligned house shadow volumes removed")
 verify(not s.find_child("CottagePlinth184",true,false).visible and not s.find_child("CottageFoundation183",true,false).visible,"both mismatched cottage slabs hidden")
 verify(art.cottage_shadow183.get_script()==preload("res://scripts/art/forest_projection186.gd"),"house uses source-alpha camera-plane projection")
 verify(art.stage_tree185.get_child(0).get_script()==preload("res://scripts/art/forest_projection186.gd"),"tree shadow follows actual branch and leaf silhouette")
 verify(s.forest_mood186.focus.shader.code.contains("forest_region186"),"regional grade extends existing depth-aware scenic shader")
 verify(MOOD.weight186(Vector2(-4.7,-2.6))==0. and MOOD.weight186(P.CENTER+P.ENTRY)==0.,"home and top entrance have no forest atmosphere weight")
 var last := -1.;var gradual := true
 for p in P.PATH:
  var amount: float=MOOD.weight186(P.CENTER+p)
  gradual=gradual and amount>=last;last=amount
 verify(gradual and last>.98,"three stair flights progressively enter full forest mood")
 var route: Array[Vector2]=[]
 for p in D.TRAIL: route.append(P.CENTER+p)
 verify(await walk(s,route),"actual hero follows root-island route into cottage nook")
 verify(art.house_contact186.mesh.get_aabb().size.z>.15,"house contact follows left wall and front porch footprint")
 await compare186(s,"cottage")
 route.reverse();verify(await walk(s,route),"cottage path returns without new visual collisions")
 s._teleport15(P.CENTER+Vector2(4.,3.));await settle(90);await compare186(s,"central")
 art.set_grounding184(false);await settle(3);await shot("central_shadow_off")
 art.set_grounding184(true);await settle(3);await shot("central_shadow_on")
 s._teleport15(P.CENTER+P.PATH[2]);await settle(100);await shot("stairs_transition")
 verify(s.forest_mood186.amount>.15 and s.forest_mood186.amount<.9,"midway entrance retains intermediate mood")
 s._teleport15(Vector2(-4.7,-2.6));await settle(180);await shot("home")
 verify(s.forest_mood186.amount<.001,"forest grade smoothly clears after returning home")
 verify(ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/world/world169.tscn" and not s.spider_trial170,"default scene and no-auto-forest-fight preserved")
 FileAccess.open("res://docs/forest186-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures}," "))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("FOREST186_DONE ",JSON.stringify({"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
