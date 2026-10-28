extends "res://scripts/world/forest180_probe.gd"
const DRESS=preload("res://scripts/world/forest_dressing181.gd")
class Trial181:
 extends "res://scripts/world/woodland_world181.gd"
 func _hero_script() -> Script: return Walker
func shot(tag: String) -> void:
 if DisplayServer.get_name()=="headless": return
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/forest181_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000);var s := Trial181.new();s.memory_save116="user://forest181_probe_tmp.cfg";root.add_child(s)
 while not s.forest_ready181: await physics_frame
 await settle(20)
 var art: Node3D=s.forest181
 verify(art.ribbons.is_empty(),"long purple placeholder strips are gone")
 verify(is_instance_valid(art.flags181) and is_instance_valid(art.kitten181) and is_instance_valid(art.lantern181),"flags plush and woven lantern are installed in world")
 for prop in [art.flags181,art.kitten181,art.lantern181]:
  verify(prop.texture.get_image().get_pixel(0,0).a<.1,"generated prop retains true transparent background")
 verify(art.stair_treads.size()==18 and art.stair_treads.all(func(n): return n.material_override==s.park99.stone97),"all three flights reuse existing hand-painted stair material")
 verify(art.stair_treads.all(func(n): return n.get_children().all(func(c): return not c is CollisionObject3D or c.collision_layer==0)),"new visual treads do not add hard movement snags")
 verify(art.thin_stones181.size()==9 and is_instance_valid(art.terrain_trail181),"worn-soil trail and sparse thin stone accents reach cottage")
 verify(art.lights181.size()>=8,"lantern artwork has real warm engine lights")
 verify(s.hero.is_on_floor() and absf(s.hero.position.y-PLAN.BASE)<.12,"sample starts physically grounded on lowland")
 await shot("sample")
 var route: Array[Vector2]=[]
 for p in DRESS.TRAIL: route.append(PLAN.CENTER+p)
 verify(await walk(s,route),"hero walks new cottage trail past decorations and roots")
 await shot("cottage_trail")
 route.reverse();verify(await walk(s,route),"new trail also walks back to entry vignette")
 var backwards: Array[Vector2]=[]
 for i in range(PLAN.PATH.size()-2,-1,-1): backwards.append(PLAN.CENTER+PLAN.PATH[i])
 verify(await walk(s,backwards),"reused stone stair flights walk uphill without snagging")
 await shot("stairs")
 var connection: Array[Vector2]=[]
 for i in range(s.connection181.size()-1,-1,-1): connection.append(s.connection181[i])
 verify(await walk(s,connection),"whole map connection back to yard remains usable")
 s._teleport15(PLAN.CENTER+PLAN.ENTRY);await settle()
 var approach: Array[Vector2]=[]
 for i in range(1,PLAN.PATH.size()): approach.append(PLAN.CENTER+PLAN.PATH[i])
 verify(await walk(s,approach),"reused stair flights walk downhill with matching support")
 await shot("sample_return")
 verify(art.cottage_sprite.billboard==BaseMaterial3D.BILLBOARD_ENABLED,"stable cottage projection retained")
 verify(ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/world/world169.tscn" and not s.spider_trial170,"default entry and no-auto-fight preview behavior retained")
 var report := {"checks":checks,"failures":failures,"note":"Three transparent props integrated; map stair builder/material reused; old strip removed. Real walks sample-cottage-sample-upstairs-yard and back down. Terrain180 unchanged."}
 FileAccess.open("res://docs/forest181-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report," "));DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116))
 print("FOREST181_DONE ",JSON.stringify({"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
