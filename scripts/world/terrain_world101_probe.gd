extends "res://scripts/world/woodland101_probe.gd"
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
 await detail_checks101(sample)

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
 var file := FileAccess.open("res://docs/swing101-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
 print("SWING100 ",JSON.stringify(data))

func detail_checks101(sample: Node3D) -> void:
 var d: Node3D=sample.details101
 verify(d.props.size()==7 and d.leaves.size()==5,"seven root props and five transparent leaf patches are installed")
 verify(d.pebbles.multimesh.instance_count>15 and d.grass.multimesh.instance_count>45,"broken path edges contain low stones and reactive grass")
 verify(d.grass.material_override==sample.grass_material,"new edge grass shares player bending and trail uniforms")
 var receive := true
 for prop in d.props: receive=receive and prop.material_override.shader.code.contains("porch_light49") and prop.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_ON
 verify(receive,"new upright art receives local lighting and casts native shadows")
 var g: Vector2=sample.meadow.landmarks.grove
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 sample._teleport15(g+Vector2(0,3));await settle72(25)
 verify(d.active.has(true),"daytime butterflies update near the player and padded camera view")
 sample._teleport15(sample.meadow.landmarks.home);await settle72(30)
 var count: int=d.flight_updates;await settle72(30)
 verify(not d.active.has(true) and d.flight_updates==count,"distant butterflies stop all flight updates")
 sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look()
 sample._teleport15(g);await settle72(30)
 verify(not d.active.has(true),"daytime butterflies disappear at night")
 var audio: Node3D=d.audio;audio.bird_wait=0.;var events: int=audio.bird_events;await settle72(15)
 verify(audio.bird_events==events,"canopy bird calls stay silent at night")
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 audio.bird_wait=0.;await settle72(15)
 verify(audio.bird_events>events,"daytime nearby bird cue triggers through a bounded spatial voice")
 sample._teleport15(g+Vector2(5,-1));audio.rope_wait=0.;var ropes: int=audio.rope_events;sample.park99.kick100(1.);await settle72(15)
 verify(audio.rope_events>ropes,"swing contact produces a local rope cue")
 audio.set_enabled(false);audio.bird_wait=0.;events=audio.bird_events;await settle72(15)
 verify(not audio.bird.playing and not audio.rope.playing and audio.bird_events==events,"environment mute stops both voices and prevents new events")
 audio.set_enabled(true)
 var distance: float=sample.camera_distance;sample.camera_distance=9.;sample._update_camera(0.,true)
 await shot99(sample,g+Vector2(-6.5,8.2),"root_microgarden")
 await shot99(sample,g+Vector2(8.7,2.8),"path_edge")
 sample.camera_distance=distance;sample._update_camera(0.,true)
