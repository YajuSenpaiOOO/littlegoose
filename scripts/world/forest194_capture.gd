extends "res://scripts/world/forest192_capture.gd"
class Walker194:
 extends "res://scripts/combat/hero192.gd"
 var command := Vector2.ZERO
 func movement_input() -> Vector2: return command if controls_enabled else Vector2.ZERO
class Trial194:
 extends "res://scripts/world/woodland_world194.gd"
 func _hero_script() -> Script: return Walker194
func world_script192() -> Script: return Trial194
func result_prefix192() -> String: return "forest194"
func extra_checks192() -> void:
 var art: Node3D=sample.forest188
 verify(sample.lighting191.rejected_craft_casters194==2,"both handwork cylinder shadow casters removed")
 var no_craft_shadow := true
 for shadow in sample.actor_shadows:
  if is_instance_valid(shadow) and shadow.get("visual") in art.craft_props183: no_craft_shadow=false
 verify(no_craft_shadow,"handwork retains contact shadows without stacked full silhouettes")
 verify(not art.hammock_cat189.visible and art.ropes193.is_empty(),"old overlaid hammock cat and added ropes removed")
 verify(is_instance_valid(art.nook194) and is_instance_valid(art.cat194) and art.trunk_bodies194.size()==2,"integrated twin-tree nook has separate cat and two physical trunks")
 metrics.plant_count=art.plant_records194.size()
 verify(art.plant_records194.size()>=24,"grouped border vegetation adds substantial layered coverage")
 var safe := true
 for entry in art.plant_records194: safe=safe and art.safe194(entry.local)
 verify(safe,"plant feet avoid cliffs, stair flights and the clear walking lane")
 sample._teleport15(Vector2(-40.4,22.2));await hour(12.);await picture("nook_day")
 await hour(22.);await picture("nook_night")
 sample._teleport15(Vector2(-44.,27.));await settle(100);await picture("handwork_shadow")
 var hp: float=sample.player_hp
 sample._teleport15(art.PLAN.CENTER+art.pop_at194+Vector2(0,2.));await settle(100)
 art.pop_age194=-1.;art.pop_cooldown194=0.;art.pop_armed194=true
 verify(art.trigger_pop194(),"proximity puppet can arm its delayed harmless reveal")
 art.update_pop194(.3);verify(not art.pop_board194.visible,"puppet waits before appearing")
 art.update_pop194(.85);await picture("puppet_boo")
 verify(art.pop_board194.visible and art.pop_words194.visible,"late puppet raises with a little text bubble")
 art.update_pop194(.65);await picture("puppet_operator")
 verify(art.pop_spider194.visible,"little spider operator is revealed after the attempted scare")
 verify(not art.trigger_pop194() and is_equal_approx(sample.player_hp,hp),"puppet cannot spam or damage player")
 art.update_pop194(2.);verify(not art.pop_board194.visible and not art.pop_words194.visible,"puppet withdraws after its short performance")
 # Walk the existing entrance and central lane with the actual 192 controller.
 sample.hero.set_physics_process(true);sample.hero.controls_enabled=true;sample.hero.command=Vector2.ZERO
 sample._teleport15(art.PLAN.CENTER+Vector2(33.,-3.));await settle(15)
 var route: Array[Vector2]=[]
 for p in [Vector2(28.,-3.),Vector2(23.,3.),Vector2(18.,3.),Vector2(14.,7.),Vector2(10.,8.),Vector2(6.,6.5),Vector2(3.,4.),Vector2(-4.5,3.5)]: route.append(art.PLAN.CENTER+p)
 verify(await walk(sample,route),"real player walks entrance stairs and planted sample lane to central tree")
 sample.hero.command=Vector2.ZERO
 metrics.pop_count=art.pop_count194
