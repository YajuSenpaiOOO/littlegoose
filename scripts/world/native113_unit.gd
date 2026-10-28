extends SceneTree
class State:
 extends RefCounted
 var at := Vector3(0,1,0)
 var previous := Vector3.ZERO
class Buffs:
 extends RefCounted
 func level(_id: String) -> int: return 0
class Pool:
 extends RefCounted
 var retired := 0
 func retire(_shot: Dictionary) -> void: retired+=1
class Host:
 extends Node3D
 var shots: Array[Dictionary]=[]
 var buffs=Buffs.new()
 var pool110=Pool.new()
 var enemies := []
 var query110 := PhysicsRayQueryParameters3D.new()
 var space110: PhysicsDirectSpaceState3D
 var hero := CharacterBody3D.new()
 var combat_clock33 := 0.
 var use_grid111 := false
 var simple_trace113 := false
 var expired := 0
 func _shot_expired(_shot: Dictionary) -> void: expired+=1
 func emit_trail(_at: Vector3,_velocity: Vector3) -> void: pass
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var library=load("res://native/combat113/combat113.gdextension")
 var helper=ClassDB.instantiate("NativeCombat113");var host := Host.new();root.add_child(host);host.add_child(host.hero)
 await physics_frame;host.space110=root.get_world_3d().direct_space_state;host.query110.collide_with_areas=true
 for i in 100: host.shots.append({"node":State.new(),"velocity":Vector3.RIGHT,"life":.5,"hit_rids":[],"ignore_rids110":[],"trail_distance":0.})
 helper.step(host,1./60.,19.)
 var moved: bool= host.shots.size()==100 and absf(host.shots[0].node.at.x-1./60.)<.000001 and absf(host.shots[0].life-(.5-1./60.))<.000001
 helper.step(host,.6,19.)
 var retired: bool= host.shots.is_empty() and host.pool110.retired==100 and host.expired==100
 print("NATIVE113_UNIT moved=",moved," retired=",retired," library=",library!=null)
 quit(0 if moved and retired else 1)
