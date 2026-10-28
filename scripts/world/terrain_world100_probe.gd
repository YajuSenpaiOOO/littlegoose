extends "res://scripts/world/woodland100_probe.gd"
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
 var file := FileAccess.open("res://docs/swing100-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
 print("SWING100 ",JSON.stringify(data))
