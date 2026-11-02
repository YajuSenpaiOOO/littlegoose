extends "res://scripts/world/native113_unit.gd"
class EyeBuffs:
 extends RefCounted
 var amount := 1
 func level(_id: String) -> int:return amount
class Target227:
 extends Node3D
 var dead := false
 var hit_area := Area3D.new()
 func _ready() -> void:add_child(hit_area)
var results227=[]
func probe227(helper: Object,tag: String,at: Vector3,velocity: Vector3,target_at: Vector3,global_level: int,packet_level: int) -> Vector3:
 var host=Host.new();root.add_child(host);host.add_child(host.hero)
 host.buffs=EyeBuffs.new();host.buffs.amount=global_level
 var target=Target227.new();host.add_child(target);target.position=target_at;host.enemies=[target]
 host.space110=root.get_world_3d().direct_space_state;host.query110.collide_with_areas=true
 var state=State.new();state.at=at
 var shot={"node":state,"velocity":velocity,"life":10.,"hit_rids":[],"ignore_rids110":[],"trail_distance":0.,"packet146":true,"tracking146":packet_level}
 host.shots.append(shot);helper.step(host,1./30.,19.)
 var after: Vector3=shot.velocity
 results227.append({"case":tag,"before":str(velocity),"after":str(after),"turned":not velocity.is_equal_approx(after),"global_eye":global_level,"packet_eye":packet_level,"target_hit_center":str(target_at),"speed_error":absf(after.length()-velocity.length())})
 host.queue_free();return after
func run() -> void:
 var library=load("res://native/combat113/combat113.gdextension")
 var helper=ClassDB.instantiate("NativeCombat113")
 await physics_frame
 var vertical=probe227(helper,"vertical_drop",Vector3(0,3,0),Vector3(0,-6,0),Vector3(.5,0,0),1,1)
 var nearly_vertical=probe227(helper,"downward_target_behind_xz_heading",Vector3(0,3,0),Vector3(.1,-6,0),Vector3(-.5,0,0),1,1)
 var ordinary=probe227(helper,"ordinary_horizontal_control",Vector3(0,1,0),Vector3(6,0,0),Vector3(2,1,1),1,1)
 var captured=probe227(helper,"packet_eye_not_runtime_eye",Vector3(0,1,0),Vector3(6,0,0),Vector3(2,1,1),0,1)
 var global=probe227(helper,"runtime_eye_not_packet_eye",Vector3(0,1,0),Vector3(6,0,0),Vector3(2,1,1),1,0)
 var height=probe227(helper,"bat_center_adds_legacy_height",Vector3(-1,1,0),Vector3(6,0,0),Vector3(0,1,0),1,1)
 var observed=vertical.is_equal_approx(Vector3(0,-6,0)) and nearly_vertical.is_equal_approx(Vector3(.1,-6,0)) and not ordinary.is_equal_approx(Vector3(6,0,0)) and captured.is_equal_approx(Vector3(6,0,0)) and not global.is_equal_approx(Vector3(6,0,0)) and height.y>0.
 FileAccess.open("res://docs/air-tracking227-probe.json",FileAccess.WRITE).store_string(JSON.stringify({"observed":observed,"production_changes":false,"cases":results227},"\t"))
 print("AIR_TRACKING227_PROBE ",observed," ",results227);quit(0 if observed else 1)
