extends "res://scripts/combat/paper_flyby150.gd"
const COVERAGE151 := 2.4
var assigned151 := 0
func delivery_count150() -> int: return 6
func marker_radius150() -> float: return COVERAGE151
func spacing150() -> float: return flight_rng146.randf_range(.045,.06)
func launch146(packet: Dictionary,origin: Vector3,target: Vector3,gain := 1.,replay := false) -> void:
 super.launch146(packet,origin,target,gain,replay)
 var f: Dictionary=planes149[-1];f.used151={};f.coverage151=[]
 var rotation := flight_rng146.randf_range(0.,TAU)
 # One centre and five outer sectors; empty sectors remain a real spread.
 for i in 6:
  var offset := Vector3.ZERO
  if i>0:
   var a := rotation+TAU*float(i-1)/5.;offset=Vector3(cos(a),0,sin(a))*COVERAGE151*.7
  var point: Vector3=f.mark+offset;point.y=battle.floor_height(Vector2(point.x,point.z))+.05
  f.coverage151.append(point)
func in_area151(enemy: Variant,mark: Vector3) -> bool:
 if not is_instance_valid(enemy) or enemy.dead or not enemy.is_visible_in_tree(): return false
 var centre: Vector3=enemy.hit_area.global_position
 return Vector2(centre.x-mark.x,centre.z-mark.z).length()<=COVERAGE151 and absf(centre.y-mark.y)<=4.
func choose151(f: Dictionary,origin: Vector3,sample: Vector3) -> Node3D:
 var chosen: Node3D;var best := INF
 for enemy in battle.enemies:
  if not in_area151(enemy,f.mark): continue
  var centre: Vector3=enemy.hit_area.global_position
  var query := PhysicsRayQueryParameters3D.create(origin,centre,1|2,[battle.hero.get_rid()])
  if not battle.get_world_3d().direct_space_state.intersect_ray(query).is_empty(): continue
  var score := float(f.used151.get(enemy.get_instance_id(),0))*20.+Vector2(centre.x-sample.x,centre.z-sample.z).length_squared()
  if score<best: best=score;chosen=enemy
 return chosen
func aim151(enemy: Node3D,origin: Vector3,packet: Dictionary) -> Vector3:
 var centre: Vector3=enemy.hit_area.global_position
 var speed: float=packet.specs[0].speed
 return centre+(enemy.velocity*minf(.3,origin.distance_to(centre)/maxf(1.,speed))).limit_length(.65)
func drop150(f: Dictionary,index: int) -> void:
 var when := drop_time150(f,index);var origin := point150(f,when)
 var sample: Vector3=f.coverage151[index];var target := choose151(f,origin,sample)
 var aim := sample
 if is_instance_valid(target):
  aim=aim151(target,origin,f.packet);var id := target.get_instance_id();f.used151[id]=int(f.used151.get(id,0))+1;assigned151+=1
 send146(f.packet,origin,aim,float(f.gain)/6.)
 if f.packet.stream and not bursts146.is_empty():
  bursts146[-1].flight150=f;bursts146[-1].target151=target;bursts146[-1].mark151=f.mark
 drops149+=1;deliveries146+=1;last_origin146=origin
 history149.append({"origin":origin,"mark":f.mark,"aim":aim,"sample":sample,"index":index,"age":when,"packet":f.packet,"target_id":target.get_instance_id() if is_instance_valid(target) else 0})
 if history149.size()>96: history149.pop_front()
func step146(delta: float) -> void:
 if not battle.combat_paused:
  for burst in bursts146:
   if burst.has("target151") and in_area151(burst.target151,burst.mark151): burst.target=aim151(burst.target151,burst.origin,burst.packet)
 super.step146(delta)
func _process(delta: float) -> void:
 super._process(delta)
 if battle.buffs.level("paper_plane")>0:
  hud146.text="区域六连投 · 在空%d架 · 圈内分配 · 放飞 %.2f秒\n"%[planes149.size(),battle.attack_cooldown()]+hud146.text.get_slice("\n",1)+"\n"+hud146.text.get_slice("\n",2)
func draw146() -> void:
 super.draw146()
 if not is_instance_valid(battle.camera): return
 for f in planes149:
  var alpha := 1.-smoothstep(float(f.release)+.25,float(f.release)+.8,float(f.age))
  if alpha<=0. or not f.has("coverage151"): continue
  for i in f.coverage151.size():
   if i>=int(f.next): ring150(f.coverage151[i],.16,Color(.98,.89,.65,.3*alpha))
