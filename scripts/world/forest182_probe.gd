extends "res://scripts/world/forest180_probe.gd"
const VALLEY=preload("res://scripts/world/forest_plan182.gd")
const DRESS=preload("res://scripts/world/forest_dressing181.gd")
class Walker182:
 extends "res://scripts/combat/hero182.gd"
 var command := Vector2.ZERO
 func movement_input() -> Vector2: return command if controls_enabled else Vector2.ZERO
 func dash_key_down() -> bool: return false
 func parry_key_down() -> bool: return false
class Trial182:
 extends "res://scripts/world/woodland_world182.gd"
 func _hero_script() -> Script: return Walker182
func shot(tag: String) -> void:
 if DisplayServer.get_name()=="headless": return
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/forest182_"+tag+".png")
func press182(s: Node3D,target: Vector2,frames := 90) -> void:
 for i in frames:
  s.hero.command=(target-Vector2(s.hero.position.x,s.hero.position.z)).normalized();await physics_frame
 s.hero.command=Vector2.ZERO;await settle(2)
func run() -> void:
 root.size=Vector2i(1600,1000);var s := Trial182.new();s.memory_save116="user://forest182_probe_tmp.cfg";root.add_child(s)
 while not s.forest_ready182: await physics_frame
 await settle(30);var art: Node3D=s.forest182
 verify(absf(s.meadow.walk_height(VALLEY.CENTER+Vector2(0.,-15.),true)-.2)<.01,"north bank remains original ground")
 for z in [9.,12.,15.,18.]: verify(s.floor_height(VALLEY.CENTER+Vector2(0.,z))< -2.05,"south valley stays low at z=%.0f"%z)
 verify(art.lamp_bodies182.size()==8 and art.rack_bodies182.size()==2,"all lamp posts and both rack uprights have collision")
 verify(art.lantern181.texture==preload("res://assets/forest182/post_top_nightlight.png"),"new supported post-top nightlight replaces hanging design")
 var bounds: Rect2i=art.opaque_bounds181(art.lantern181.texture)
 verify(absf(art.lantern181.pixel_size*bounds.size.y-2.3)<.01,"lamp opaque height increased to 2.3m")
 verify(absf(art.flags181.position.y-VALLEY.BASE-3.2)<.01 and art.kitten181.position.y>VALLEY.BASE+2.5,"rack and plush raised above character head")
 verify(art.prop_shadows182.size()==art.props181.size() and art.prop_shadows182.all(func(n): return n.mesh!=null),"every sprite prop has live silhouette projection mesh")
 verify(art.contacts182.size()==10,"all ten solid feet receive contact shadows")
 verify(art.rack_bodies182.all(func(n): return n.collision_layer==2),"rack collisions use normal environment layer")
 await shot("sample")
 var lamp := VALLEY.CENTER+Vector2(10.2,4.8)
 await press182(s,lamp)
 var distance: float=Vector2(s.hero.position.x,s.hero.position.z).distance_to(lamp)
 verify(distance>.38 and distance<.65,"real hero movement is stopped by lamp post")
 await shot("lamp_collision")
 var rack := VALLEY.CENTER+Vector2(10.9,4.5)
 s._teleport15(VALLEY.CENTER+Vector2(10.9,6.3));await settle();await press182(s,rack)
 distance=Vector2(s.hero.position.x,s.hero.position.z).distance_to(rack)
 verify(distance>.26 and distance<.50,"real hero movement is stopped by rack upright")
 s._teleport15(VALLEY.CENTER+Vector2(10.,6.8));await settle()
 var south: Array[Vector2]=[VALLEY.CENTER+Vector2(5.,9.),VALLEY.CENTER+Vector2(0.,12.),VALLEY.CENTER+Vector2(0.,15.5)]
 verify(await walk(s,south),"hero walks from forest into open southern low ground")
 verify(s.hero.is_on_floor() and s.hero.position.y< -2.1,"southern foreground supports hero on lower floor")
 var query := PhysicsRayQueryParameters3D.create(s.camera.global_position,s.hero.position+Vector3.UP*.8,1)
 verify(s.get_world_3d().direct_space_state.intersect_ray(query).is_empty(),"foreground terrain no longer occludes camera-to-hero ray")
 await shot("south_open")
 verify(await walk(s,[VALLEY.CENTER+Vector2(0.,12.),VALLEY.CENTER+Vector2(5.,9.),VALLEY.CENTER+DRESS.TRAIL[0]]),"southern opening returns to forest without a rim climb")
 var route: Array[Vector2]=[]
 for p in DRESS.TRAIL: route.append(VALLEY.CENTER+p)
 verify(await walk(s,route),"raised solid props leave cottage path usable")
 await shot("cottage")
 route.reverse();verify(await walk(s,route),"cottage path returns to entrance")
 var up: Array[Vector2]=[]
 for i in range(VALLEY.PATH.size()-2,-1,-1): up.append(VALLEY.CENTER+VALLEY.PATH[i])
 verify(await walk(s,up),"original three short stair flights still walk uphill")
 verify(ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/world/world169.tscn" and not s.spider_trial170,"default and no-auto-fight preview behavior unchanged")
 var report := {"checks":checks,"failures":failures,"north_y":.2,"south_y":s.floor_height(VALLEY.CENTER+Vector2(0.,15.5)),"lamp_height":2.3,"rack_height":3.2,"note":"New open-south terrain; physical post bump tests, live silhouette/contact shadows, and foreground terrain visibility ray checked under actual map physics."}
 FileAccess.open("res://docs/forest182-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report," "));DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116))
 print("FOREST182_DONE ",JSON.stringify({"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
