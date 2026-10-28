extends "res://scripts/world/woodland102_probe.gd"
func extra_checks99(sample: Node3D) -> void:
 var s: RefCounted=sample.meadow
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 sample.hero.controls_enabled=true;sample._teleport15(Vector2(7.,-42.7));await settle72(15)
 verify(sample.hero.position.y<.5,"actual station lower ground is restored below 0.5m")
 var side := await press85(sample,Vector2(7.,-42.7),Vector2.UP)
 verify(side.z> -44.1,"restored lower ground cannot bypass the moss stair side wall")
 sample._teleport15(s.SIDE_FOOT75+Vector2(.7,0));await settle72(10)
 verify(sample.hero.position.y<.6,"moss stair foot is exposed above its original low ground")
 var climb := true;sample.hero.controls_enabled=true
 for target in [s.SIDE_TOP75,Vector2(4.8,-49.)]: climb=climb and await walk_to(sample,target)
 verify(climb and sample.hero.position.y>1.95,"hero climbs exposed moss steps to the upper landing")
 var descend := true
 for target in [s.SIDE_TOP75,s.SIDE_FOOT75+Vector2(.7,0)]: descend=descend and await walk_to(sample,target)
 verify(descend and sample.hero.position.y<.65,"hero descends moss steps back to the low terrace")
 verify(await walk_route72(sample,"junction_to_station"),"full station approach works with the restored height difference")
 var front: Vector2=s.stair_start73()
 sample._teleport15(front+Vector2(0,.9));await settle72(10)
 var front_ok := await walk_to(sample,front-Vector2(0,s.station_stair_run74()+1.))
 front_ok=front_ok and await walk_to(sample,front+Vector2(0,.9))
 verify(front_ok,"station front steps retain their climb and descent")
 sample._teleport15(s.landmarks.home);await settle72(15)
 verify(sample.hero.position.y<.4,"actual cottage ground is restored to its original low elevation")
 await shot99(sample,s.SIDE_FOOT75+Vector2(-1.6,3.),"restored_moss_stairs")
 await shot99(sample,Vector2(8.4,-42.9),"restored_station_terrace")
 await shot99(sample,s.landmarks.home+Vector2(0,4.),"restored_home")
 await shot99(sample,s.landmarks.shore+Vector2(-8,5),"restored_shore")

 await swing_checks100(sample)
 await checks102(sample)

func seat_hits100(sample: Node3D) -> bool:
 var park: Node3D=sample.park99
 var shape := SphereShape3D.new();shape.radius=.035
 var query := PhysicsShapeQueryParameters3D.new();query.shape=shape;query.collision_mask=2
 query.transform=Transform3D(Basis.IDENTITY,park.seat_body100.global_position)
 for hit in sample.get_world_3d().direct_space_state.intersect_shape(query,16):
  if hit.collider==park.seat_body100: return true
 return false

func swing_checks100(sample: Node3D) -> void:
 var park: Node3D=sample.park99
 verify(sample.plane_conflicts100()==0,"overlapping local tree cards occupy distinct depth planes")
 var root_error := 0.;var root_samples := 0
 for piece in sample.root_pieces:
  if not piece.sprite.has_meta("swing_oak99"): continue
  var arrays: Array=piece.node.mesh.surface_get_arrays(0)
  var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX];var uvs: PackedVector2Array=arrays[Mesh.ARRAY_TEX_UV]
  for i in vertices.size():
   if uvs[i].y<.84: continue
   var point: Vector3=piece.node.to_global(vertices[i])
   root_error=maxf(root_error,absf(point.y-sample.floor_height(Vector2(point.x,point.z))));root_samples+=1
 verify(root_samples>50 and root_error<.035,"extended oak root fan follows the actual ground within 3.5cm")
 verify(is_instance_valid(sample.root_shadow100) and sample.root_shadow100.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY,"grounded oak root geometry also casts its contact shadow")
 verify(seat_hits100(sample),"real physics query hits the swing plank collider")
 park.set_physics_process(false);park.angle100=0.;park.angular_speed100=0.;park.swing97.rotation.x=0.
 await settle72(8)
 var seat: Vector3=park.seat_body100.global_position
 sample.hero.controls_enabled=true;sample._teleport15(Vector2(seat.x,seat.z+1.2));await settle72(10)
 sample.hero.wish=Vector2.UP
 var contacts := 0
 for frame in 55:
  await physics_frame
  for i in sample.hero.get_slide_collision_count():
   if sample.hero.get_slide_collision(i).get_collider()==park.seat_body100: contacts+=1
 sample.hero.wish=Vector2.ZERO
 verify(contacts>0 and sample.hero.position.z>seat.z+.3,"stationary swing plank blocks an actual walking hero")
 park.set_physics_process(true);sample.hero.wish=Vector2.UP
 await settle72(75);sample.hero.wish=Vector2.ZERO
 verify(park.bump_count100>0 and park.max_angle100>.05,"hero contact transfers motion into a visible swing")
 var physical: Transform3D=PhysicsServer3D.body_get_state(park.seat_body100.get_rid(),PhysicsServer3D.BODY_STATE_TRANSFORM)
 print("SWING100_BODY_DELTA ",physical.origin.distance_to(park.seat_body100.global_position))
 verify(seat_hits100(sample),"moving plank retains collision at its animated position")
 sample._teleport15(Vector2(seat.x+3.,seat.z+3.));await settle72(5)
 var energy: float=park.angular_speed100*park.angular_speed100+9.8/park.length100*park.angle100*park.angle100
 await settle72(360)
 var remaining: float=park.angular_speed100*park.angular_speed100+9.8/park.length100*park.angle100*park.angle100
 verify(energy>.00001 and remaining<energy*.06,"swing loses energy after contact instead of oscillating forever")
 var g: Vector2=sample.meadow.landmarks.grove
 await shot99(sample,g+Vector2(16,-6),"tree_layers_day")
 await settle72(17);await shot99(sample,g+Vector2(16,-6),"tree_layers_later")
 await shot99(sample,g+Vector2(10,5),"grounded_oak")
 await shot99(sample,Vector2(seat.x,seat.z+2.4),"touch_swing")
 var data := {"tree_plane_moves":sample.plane_moves100,"remaining_planes":sample.plane_conflicts100(),"root_ground_error":root_error,"root_vertices":root_samples,"hero_contacts":contacts,"swing_bumps":park.bump_count100,"max_swing_angle":park.max_angle100,"energy_before":energy,"energy_after":remaining}
 var file := FileAccess.open("res://docs/swing102-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
 print("SWING100 ",JSON.stringify(data))

func checks102(sample: Node3D) -> void:
 var d: Node3D=sample.details101;var g: Vector2=sample.meadow.landmarks.grove
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 verify(sample.park99.slab_bodies102.size()==7,"all six treads and the lookout cap have actual solid collision")
 var clear := true
 for at in sample.forest87.flower_points94: clear=clear and not sample.forest87.slab102(at-g)
 for plant in sample.forest87.plants87: clear=clear and not sample.forest87.slab102(Vector2(plant.position.x,plant.position.z)-g)
 verify(clear,"lookout slab and stairs contain no flower or fern roots")
 var heights := true
 for group in d.mushrooms102:
  var highest := 0.
  for node in group.get_children(): highest=maxf(highest,node.position.y+node.mesh.get_aabb().end.y*node.scale.y)
  heights=heights and highest>.28 and highest<.42
 verify(d.mushrooms102.size()==4 and heights and d.props.is_empty(),"four mushroom clusters have actual upright stems and three dimensional caps")
 verify(d.cones102.size()==6 and d.cones102[0].collision_layer==32,"six single pinecones have separate rigid bodies and no attached twig")
 var textures_ok := true
 for texture in d.leaf_textures102: textures_ok=textures_ok and texture.get_width()>60 and texture.get_height()>60
 verify(textures_ok and d.leaf_states102.size()==120,"leaf piles contain 120 separately textured individual leaves")
 var start: Vector2=g+sample.PARK99.from_stair99(Vector2(sample.PARK99.STAIR_X,2.1))
 sample._teleport15(start);sample.hero.controls_enabled=true;await settle72(12)
 var penetration := 0.;var climbed := true
 for z in [.7,-.1,-.9,-1.7,-2.5,-3.4,-4.3]:
  var target: Vector2=g+sample.PARK99.from_stair99(Vector2(sample.PARK99.STAIR_X,z))
  sample.hero.wish=Vector2.ZERO
  for frame in 100:
   var at := Vector2(sample.hero.position.x,sample.hero.position.z)
   if at.distance_to(target)<.18: break
   sample.hero.wish=at.direction_to(target);await physics_frame
   var support: float=sample.park99.support102(Vector2(sample.hero.position.x,sample.hero.position.z))
   if is_finite(support): penetration=maxf(penetration,support-sample.hero.position.y)
  sample.hero.wish=Vector2.ZERO
  climbed=climbed and Vector2(sample.hero.position.x,sample.hero.position.z).distance_to(target)<.4
 verify(climbed and sample.hero.position.y>3.6 and penetration<.035,"continuous real walking keeps actor feet above each solid tread within 3.5cm")
 verify(sample.assisted_steps102>0,"small-step traversal assists actual stair motion instead of using only the old ramp")
 var cone: RigidBody3D=d.cones102[0];var original: Vector3=cone.position;var kicks: int=d.cone_kicks102
 sample._teleport15(Vector2(original.x,original.z+.8));await settle72(12);sample.hero.controls_enabled=true;sample.hero.wish=Vector2.UP
 await settle72(40);sample.hero.wish=Vector2.ZERO;await settle72(75)
 var cone_travel: float=Vector2(cone.position.x,cone.position.z).distance_to(Vector2(original.x,original.z))
 verify(d.cone_kicks102>kicks and cone_travel>.15,"walking hero kicks a single pinecone and rigid-body motion carries it across the floor")
 verify(cone.position.y>sample.floor_height(Vector2(cone.position.x,cone.position.z))+.04,"kicked pinecone retains real ground collision")
 var leaf: Dictionary=d.leaf_states102[48];var old_at: Vector2=leaf.at;var leaf_kicks: int=d.leaf_kicks102;var sounds: int=d.audio.rustle_events102
 sample._teleport15(g+old_at+Vector2(0,.8));await settle72(15);sample.hero.controls_enabled=true;sample.hero.wish=Vector2.UP
 var peak := 0.
 for frame in 40:
  await physics_frame
  for item in d.leaf_states102: peak=maxf(peak,item.lift)
 sample.hero.wish=Vector2.ZERO;await settle72(100)
 verify(d.leaf_kicks102>leaf_kicks and leaf.at.distance_to(old_at)>.06 and peak>.02,"walking through a leaf pile scatters individual leaves and briefly lifts them")
 verify(d.audio.rustle_events102>sounds,"walking through a leaf pile produces bounded local rustling")
 var settled := true
 for item in d.leaf_states102: settled=settled and item.lift<.003
 verify(settled,"disturbed leaves settle on the ground rather than remaining airborne")
 sample._teleport15(sample.meadow.landmarks.home);await settle72(30);var updates: int=d.leaf_updates102;await settle72(30)
 verify(not d.active102 and updates==d.leaf_updates102,"leaf simulation stops outside the padded local view")
 d.audio.set_enabled(false);verify(not d.audio.rustle_voice102.playing,"environment mute also stops the new rustle voice");d.audio.set_enabled(true)
 var distance: float=sample.camera_distance;sample.camera_distance=9.;sample._update_camera(0.,true)
 await shot99(sample,g+sample.PARK99.from_stair99(Vector2(sample.PARK99.STAIR_X,-.9)),"solid_stairs")
 await shot99(sample,g+Vector2(12.2,-.3),"mushrooms_and_leaves")
 sample.camera_distance=distance;sample._update_camera(0.,true)
 var data := {"checks":checks,"failures":failures,"stair_penetration":penetration,"step_assists":sample.assisted_steps102,"cone_travel":cone_travel,"cone_kicks":d.cone_kicks102,"leaf_kicks":d.leaf_kicks102,"leaf_peak":peak}
 var file := FileAccess.open("res://docs/interaction102-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));print("INTERACTION102 ",JSON.stringify(data))
