extends "res://scripts/world/paper_hill137_probe.gd"
class Restored:
 extends "res://scripts/world/woodland_world138.gd"
 func _hero_script() -> Script: return Fighter
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func shot138(s: Node3D,p: Vector2,tag: String) -> void:
 s.hero.wish=Vector2.ZERO;s._teleport15(Vector2(s.meadow.landmarks.grove)+p);await settle72(20)
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/paper_hill138_%s.png"%tag)
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Restored.new();s.memory_save116="user://hill138_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not s.hill_ready138: await physics_frame
 s.hill_visited138=true;s.hero.controls_enabled=true;s.combat_paused=false;disable_enemies(s)
 var g: Vector2=s.meadow.landmarks.grove
 var original := preload("res://scripts/world/world_surface107.gd").new()
 var preserved := true;var grounded := true
 for p in [Vector2(-14,-22),Vector2(-20,-31),Vector2(-26,4),Vector2(-10,-23),Vector2(-25,-24),Vector2(-26,-6)]:
  var at: Vector2=g+p;var expected: float=original.height_at(at.x,at.y,true)
  preserved=preserved and absf(s.meadow.height_at(at.x,at.y,true)-expected)<.001
  var hit: Dictionary=s.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(at.x,35.,at.y),Vector3(at.x,-50.,at.y),1))
  grounded=grounded and not hit.is_empty() and absf(hit.position.y-expected)<.10
 verify(preserved,"six original mountain and lower-land samples retain baseline heights")
 verify(grounded,"restored mountain and land also have native terrain collision")
 var anchors := 0
 for p in [Vector2(-25,-24),Vector2(-26,-6),Vector2(-25,3),Vector2(-26,11)]:
  for tree in s.trees:
   var at := Vector2(tree.root.position.x,tree.root.position.z)-g
   # The original authoring pass reuses any existing trunk within two metres.
   if at.distance_to(p)<2.05: anchors+=1;break
 verify(anchors>=3,"authored summit border and lower-shelf trees are restored")
 verify(s.rocks91.get_script().resource_path=="res://scripts/art/rock_surfaces103.gd","original terrain rendering has no broad coastal discard mask")
 verify(s.coast138.get_child_count()==1 and s.coast138.panorama138.texture.resource_path=="res://assets/paper_hill136/coast.png","original complete seascape replaces independently drifting islands")
 await shot138(s,Vector2(-10.8,-11.8),"stair_mountain")
 var route: Array[Vector2]=[g+s.PARK99.from_stair99(Vector2(s.PARK99.STAIR_X,s.PARK99.STAIR_FOOT+.5)),g+s.PARK99.from_stair99(Vector2(s.PARK99.STAIR_X,s.PARK99.STAIR_TOP+.1))]
 for p in s.HILL138.POINTS: route.append(g+p)
 s._teleport15(route[0]);await settle72(5)
 var up := true
 for at in route:
  if not await walk137(s,at): up=false;break
 verify(up,"key-like input still climbs the repaired stairs after restoration")
 var down := true;route.reverse();s._teleport15(route[0]);await settle72(5)
 for at in route:
  if not await walk137(s,at): down=false;break
 verify(down,"key-like input still descends the repaired stairs")
 await shot138(s,Vector2(-23,-16),"trees")
 var first: Vector2=s.coast138.shift138
 await shot138(s,Vector2(-40,-18),"panorama")
 verify(s.coast138.shift138.distance_to(first)>.001 and s.coast138.shift138.distance_to(first)<.02,"whole panorama uses restrained unified parallax")
 var persists := true
 for p in [Vector2(-28,-31),Vector2(-28,1)]:
  s._teleport15(g+p);await settle72(3);persists=persists and s.coast138.panorama138.visible
 verify(persists,"whole panorama does not disappear at the former region limits")
 s.paper_trial129=true;s.start_combat();disable_enemies(s)
 verify(s.enemies.size()==6,"six-paper summit trial remains available")
 s.home116();await settle72(2)
 FileAccess.open("res://docs/paper-hill138-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"restored_tree_anchors":anchors},"\t"))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("PAPER_HILL138_DONE ",JSON.stringify({"checks":checks,"failures":failures,"anchors":anchors}));quit(0 if failures.is_empty() else 1)
