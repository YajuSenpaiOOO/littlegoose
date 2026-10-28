extends "res://scripts/world/paper_hill143_probe.gd"
class Current144:
 extends "res://scripts/world/woodland_world144.gd"
 func _hero_script() -> Script: return Walker143
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func shot144(s: Node3D,p: Vector2,tag: String) -> void:
 s.hero.wish=Vector2.ZERO;s._teleport15(p);await settle72(35)
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/paper_hill144_%s.png"%tag)
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Current144.new();s.memory_save116="user://hill144_probe_tmp.cfg";root.add_child(s)
 while not s.hill_ready144: await physics_frame
 s.hill_visited136=true;s.hero.controls_enabled=true;s.combat_paused=false;disable_enemies(s);await settle72(3)
 var g: Vector2=s.meadow.landmarks.grove;var props: Node3D=s.picnic144
 verify(props.seats144.size()==2 and is_instance_valid(props.seat144),"low painted sea stone reserves two story seats")
 verify(props.lamps144.size()==2 and props.basket144.texture!=null,"one basket with two mugs and exactly two new warm lights")
 var fitted := true
 for at in props.cloth_samples144:
  fitted=fitted and absf(at.y-s.floor_height(Vector2(at.x,at.z))-.035)<.002
 verify(fitted,"blanket follows actual ground without changing hill height")
 var blocked := false
 for body in s.hill_plants142.shrub_bodies143:
  if props.in_cloth144(body.global_position) and body.collision_layer!=0: blocked=true
 verify(not blocked,"old fern colliders are cleared from the walkable blanket")
 var hits := true
 for body in props.bodies144:
  var query := PhysicsRayQueryParameters3D.create(body.global_position+Vector3.UP*2.,body.global_position-Vector3.UP*2.,2)
  var hit: Dictionary=s.get_world_3d().direct_space_state.intersect_ray(query)
  hits=hits and not hit.is_empty() and hit.collider==body
 verify(hits,"basket, ground lantern and hanging lamp post have real blocking footprints")
 s.time55.preview_at(12.);s.time55.visual_hour=12.;s.time55.apply_look()
 s._teleport15(g+props.PICNIC144+Vector2(-2.,1.6));await settle72(15)
 props.update_lights144();var day: float=props.lamps144[0].light_energy
 var path_ok := true
 for p in [Vector2(-19.3,-26.4),Vector2(-20.,-27.),Vector2(-23.,-26.),Vector2(-25.7,-25.),s.VIEW141]:
  if not await walk139(s,g+p): path_ok=false;break
 verify(path_ok,"walk from picnic edge to scenic clearing without new obstructions")
 await settle72(120);verify(s.view_weight141>.9,"scenic camera still lifts near the low sea-view seat")
 var distance: float=s.camera_distance
 await shot144(s,g+Vector2(-23.,-22.),"overview")
 s.camera_distance=11.
 await shot144(s,g+props.PICNIC144+Vector2(-1.8,1.45),"picnic_day")
 await shot144(s,g+props.ENTRY144+Vector2(.8,1.3),"entry_day")
 s.camera_distance=distance
 await shot144(s,g+s.VIEW141,"seat_day")
 s.time55.preview_at(20.);s.time55.visual_hour=20.;s.time55.apply_look()
 s.camera_distance=11.
 await shot144(s,g+props.PICNIC144+Vector2(-1.8,1.45),"picnic_night")
 props.update_lights144()
 verify(props.lamps144[0].light_energy>day+.8 and props.lamp_inks144[0].get_shader_parameter("glow144")>1.,"night increases warm spill and glass emission")
 verify(not props.lamps144[0].shadow_enabled and not props.lamps144[1].shadow_enabled,"new lamps add no expensive shadow maps")
 await shot144(s,g+props.ENTRY144+Vector2(.8,1.3),"entry_night")
 s.camera_distance=distance
 s.time55.preview_at(18.);s.time55.visual_hour=18.;s.time55.apply_look()
 await shot144(s,g+s.VIEW141,"seat_dusk")
 FileAccess.open("res://docs/paper-hill144-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"cleared_ferns":props.cleared_ferns144,"night_energy":props.lamps144[0].light_energy},"\t"))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("PAPER_HILL144_DONE ",JSON.stringify({"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
