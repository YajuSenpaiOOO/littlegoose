extends "res://scripts/world/forest192_capture.gd"
class Walker201:
 extends "res://scripts/combat/hero192.gd"
 var command := Vector2.ZERO
 func movement_input() -> Vector2: return command if controls_enabled else Vector2.ZERO
class Trial201:
 extends "res://scripts/world/woodland_world201.gd"
 func _hero_script() -> Script: return Walker201
func world_script192() -> Script: return Trial201
func result_prefix192() -> String: return "forest201"
func extra_checks192() -> void:
 var art: Node3D=sample.forest188
 var fences := 0;var stumps := 0;var clear := true
 for entry in art.decor201:
  if entry.kind=="fence": fences+=1
  if entry.kind=="stump_lantern": stumps+=1
  if entry.kind!="plush": clear=clear and art.level201(entry.local,entry.width*.45 if entry.has("width") else .65)
 verify(fences>=4 and stumps>=2,"multiple themed fence sections and lantern corners are placed")
 verify(clear,"decoration feet avoid cliffs and preserve the walking lane")
 verify(art.fence_bodies201.size()==fences,"short fence sections have deliberate ground footprints")
 verify(sample.accent_lamps201.size()>=fences+2,"painted accent lanterns have registered real warm light")
 var warm := true
 for light in sample.accent_lamps201: warm=warm and light.light_color.r>light.light_color.b*1.3 and light.light_energy>0.
 verify(warm,"new light pools are warm amber and enabled")
 verify(sample.relations199.sight_trees199.is_empty() and sample.whole67.get_script()==preload("res://scripts/art/whole_tree_fade200.gd"),"tree behavior remains the parked 200 baseline")
 sample._teleport15(Vector2(-44.,27.));await hour(12.);await settle(100);await picture("decor_day")
 await hour(22.);await picture("decor_night")
 sample._teleport15(Vector2(-40.4,22.2));await settle(100);await picture("hammock_corner")
 sample.hero.set_physics_process(true);sample.hero.controls_enabled=true
 sample._teleport15(art.PLAN.CENTER+Vector2(33.,-3.));await settle(30)
 var route: Array[Vector2]=[]
 for p in [Vector2(28.,-3.),Vector2(23.,3.),Vector2(18.,3.),Vector2(14.,7.),Vector2(10.,8.),Vector2(6.,6.5),Vector2(3.,4.),Vector2(-4.5,3.5),Vector2(-6.,1.),Vector2(-5.6,-3.5),Vector2(-8.,-7.)]: route.append(art.PLAN.CENTER+p)
 verify(await walk(sample,route),"actual player walks entrance, decorated clearing and cottage route")
 sample.hero.command=Vector2.ZERO
 metrics.fences=fences;metrics.stump_corners=stumps;metrics.new_lights=sample.accent_lamps201.size()
