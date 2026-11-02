extends "res://scripts/combat/paper_squad226.gd"
## Resolve only near a sector sample, once, before the payload begins falling.
var local_assignments230 := 0
const FLIGHT_SPEED230 := 1.5
func launch146(packet: Dictionary,origin: Vector3,target: Vector3,gain := 1.,replay := false) -> void:
 var first := planes149.size()
 super.launch146(packet,origin,target,gain,replay)
 for i in range(first,planes149.size()):
  planes149[i].release/=FLIGHT_SPEED230;planes149[i].spacing/=FLIGHT_SPEED230
func point150(f: Dictionary,age: float) -> Vector3:
 return super.point150(f,age*FLIGHT_SPEED230)
func step146(delta: float) -> void:
 super.step146(delta)
 if battle.combat_paused:return
 var duration := AIRTIME149/FLIGHT_SPEED230
 for i in range(planes149.size()-1,-1,-1):
  var f: Dictionary=planes149[i]
  f.node.modulate.a=1.-smoothstep(duration-.25,duration,float(f.age))
  if f.age>=duration:f.node.queue_free();planes149.remove_at(i)
func correction230(packet: Dictionary) -> float:
 var eye := 0
 for spec in packet.specs:eye=maxi(eye,int(spec.get("tracking",0)))
 return 2.2 if eye>=2 else 2.05 if eye==1 else 1.9
func repeat_penalty230() -> float:return .5
func choose_local230(f: Dictionary,sample: Vector3,height: float) -> Node3D:
 var chosen: Node3D;var best := INF
 for enemy in battle.enemies:
  if not in_area151(enemy,f.mark):continue
  var centre: Vector3=enemy.hit_area.global_position
  var distance := Vector2(centre.x-sample.x,centre.z-sample.z).length()
  var shape: Shape3D=enemy.hit_area.get_child(0).shape
  var radius := float(shape.radius) if shape is CapsuleShape3D or shape is SphereShape3D else .25
  if distance>correction230(f.packet)+radius:continue
  if centre.y>=height-.1:continue
  var ceiling := Vector3(centre.x,height,centre.z)
  var query := PhysicsRayQueryParameters3D.create(ceiling,centre,1|2,[battle.hero.get_rid()])
  if not battle.get_world_3d().direct_space_state.intersect_ray(query).is_empty():continue
  var score := distance*distance+float(f.used151.get(enemy.get_instance_id(),0))*repeat_penalty230()
  if score<best:best=score;chosen=enemy
 return chosen
func drop150(f: Dictionary,index: int) -> void:
 var when := drop_time150(f,index);var path_origin := point150(f,when)
 var sample: Vector3=f.coverage151[index]
 var target := choose_local230(f,sample,path_origin.y)
 var aim := sample
 if is_instance_valid(target):
  aim=target.hit_area.global_position
  var id := target.get_instance_id();f.used151[id]=int(f.used151.get(id,0))+1
  assigned151+=1;local_assignments230+=1
 # Rain occupies the marked area under the aircraft; no angled pursuit afterward.
 var origin := Vector3(aim.x,path_origin.y,aim.z)
 send146(f.packet,origin,aim,float(f.gain)/float(delivery_count150()))
 # Do not attach flight150/target151: continuous beam packets retain this release.
 drops149+=1;deliveries146+=1;last_origin146=origin
 history149.append({"origin":origin,"mark":f.mark,"aim":aim,"sample":sample,"index":index,"age":when,"packet":f.packet,"target_id":target.get_instance_id() if is_instance_valid(target) else 0})
 if history149.size()>96:history149.pop_front()
func _process(delta: float) -> void:
 super._process(delta)
 if hud146.visible and "辅助六连投" in hud146.text:hud146.text=hud146.text.replace("辅助六连投","局部校准 · 直落六连投")
