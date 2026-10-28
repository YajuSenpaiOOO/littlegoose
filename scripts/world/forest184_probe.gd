extends "res://scripts/world/forest180_probe.gd"
const P=preload("res://scripts/world/forest_plan183.gd")
const D=preload("res://scripts/world/forest_dressing183.gd")
class Walker184:
 extends "res://scripts/combat/hero183.gd"
 var command := Vector2.ZERO
 func movement_input() -> Vector2: return command if controls_enabled else Vector2.ZERO
 func dash_key_down() -> bool: return false
 func parry_key_down() -> bool: return false
class Trial184:
 extends "res://scripts/world/woodland_world184.gd"
 func _hero_script() -> Script: return Walker184
func shot(tag: String) -> void:
 if DisplayServer.get_name()=="headless": return
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/forest184_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000);var s := Trial184.new();s.memory_save116="user://forest184_probe_tmp.cfg";root.add_child(s)
 while not s.forest_ready184: await physics_frame
 await settle(30);var art: Node3D=s.forest184
 verify(absf(s.floor_height(P.CENTER+Vector2(0.,-15.))-.2)<.01,"north bank remains at original grade")
 verify(absf(s.floor_height(P.CENTER+Vector2(0.,15.))-.2)<.01,"southern bank restored to enclosed bowl")
 verify(s.floor_height(P.CENTER+Vector2(-11.,-11.))< -2.1,"cottage alcove has actual lowered floor")
 verify(P.edge183(Vector2(-4.8,-10.))>1. and P.edge183(Vector2(-11.,-11.))< -1.,"raised rock shoulder separates cottage nook from main clearing")
 verify(art.cottage_sprite.position.x== -11. and art.cottage_sprite.position.z== -9.,"cottage moved outside main clearing into rear alcove")
 verify(art.cottage_sprite.billboard==BaseMaterial3D.BILLBOARD_ENABLED,"cottage retains stable camera-plane projection")
 verify(is_instance_valid(art.cottage_shadow183) and art.cottage_shadow183.mesh!=null,"cottage has live projected silhouette")
 verify(art.get_node_or_null("CentralOak184")!=null and art.trees[-1].texture==preload("res://assets/forest184/ribbon_oak.png"),"generated central tree replaces old oak")
 verify(art.craft_props183.size()==2,"two generated craft corners integrated")
 verify(art.prop_shadows182.size()==art.props181.size()+1,"all new props and cottage have projected shadows")
 verify(art.contacts182.size()==16,"solid props, tree and cottage receive contact shadows")
 verify(art.hanging_lamps184.size()==2 and absf(art.trees[-1].pixel_size*art.opaque_bounds181(art.trees[-1].texture).size.y-11.)<.01,"central tree is 11m with two independent hanging lamps")
 verify(art.lamp_bodies182.size()==8 and art.rack_bodies182.size()==2,"raised solid lamps and rack retained")
 await shot("entrance")
 var route: Array[Vector2]=[]
 for p in D.TRAIL: route.append(P.CENTER+p)
 verify(await walk(s,route),"real hero walks around root island and through nook to cottage")
 verify(s.hero.is_on_floor() and s.hero.position.y< -2.,"cottage approach supports hero on ground")
 await shadow_comparison184(s,art,"cottage")
 route.reverse();verify(await walk(s,route),"cottage nook returns to central clearing")
 s._teleport15(P.CENTER+Vector2(4.,3.));await settle(30);await shadow_comparison184(s,art,"central")
 s._teleport15(P.CENTER+Vector2(0.,7.));await settle(30)
 var query := PhysicsRayQueryParameters3D.create(s.camera.global_position,s.hero.position+Vector3.UP*.8,1)
 verify(s.get_world_3d().direct_space_state.intersect_ray(query).is_empty(),"main southern walking route remains visible above restored foreground rim")
 await shot("south")
 s._teleport15(P.CENTER+D.TRAIL[0]);await settle()
 var up: Array[Vector2]=[]
 for i in range(P.PATH.size()-2,-1,-1): up.append(P.CENTER+P.PATH[i])
 verify(await walk(s,up),"three short entrance stair flights still walk uphill")
 verify(ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/world/world169.tscn" and not s.spider_trial170,"normal default and no-auto-fight preview preserved")
 FileAccess.open("res://docs/forest184-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures}," "))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116))
 print("FOREST184_DONE ",JSON.stringify({"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)

func shadow_comparison184(s: Node3D,art: Node3D,tag: String) -> void:
 art.set_grounding184(false);await settle(2);await process_frame;await RenderingServer.frame_post_draw
 var off := root.get_texture().get_image();off.save_png("res://docs/captures/world_restart/forest184_"+tag+"_off.png")
 art.set_grounding184(true);await settle(2);await process_frame;await RenderingServer.frame_post_draw
 var on := root.get_texture().get_image();on.save_png("res://docs/captures/world_restart/forest184_"+tag+"_on.png")
 var darker := 0
 for y in range(0,on.get_height(),2):
  for x in range(0,on.get_width(),2):
   var a := off.get_pixel(x,y);var b := on.get_pixel(x,y)
   if (a.r+a.g+a.b)-(b.r+b.g+b.b)>.09: darker+=1
 verify(darker>120,"visible shadow pixels in "+tag+" comparison: "+str(darker))
 var shadow: MeshInstance3D=art.cottage_shadow183
 verify(shadow.corrected_upload184>=0 and shadow.custom_aabb.position.length()<40.,"projected caster bounds are local after CPU fallback")
 print("GROUND184 ",tag," floor=",s.floor_height(Vector2(-59.,-9.))," shadow_visible=",shadow.is_visible_in_tree()," bounds=",shadow.custom_aabb)
