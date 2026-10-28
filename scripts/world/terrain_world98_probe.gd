extends "res://scripts/world/woodland98_probe.gd"
func extra_checks98(sample: Node3D) -> void:
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
 await shot98(sample,s.SIDE_FOOT75+Vector2(-1.6,3.),"restored_moss_stairs")
 await shot98(sample,Vector2(8.4,-42.9),"restored_station_terrace")
 await shot98(sample,s.landmarks.home+Vector2(0,4.),"restored_home")
 await shot98(sample,s.landmarks.shore+Vector2(-8,5),"restored_shore")
