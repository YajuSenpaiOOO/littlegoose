extends "res://scripts/combat/paper_memories146.gd"
const AIRTIME149 := 3.6
var planes149: Array[Dictionary]=[]
var history149: Array[Dictionary]=[]
var pending_mark149 := Vector3.INF
var drops149 := 0
func delivery_count150() -> int: return 3
func marker_radius150() -> float: return .8
func spacing150() -> float: return flight_rng146.randf_range(.085,.11)
func drop_time150(f: Dictionary,index: int) -> float:
 return float(f.release)+(float(index)-float(delivery_count150()-1)*.5)*float(f.spacing)
func reset146() -> void:
 for f in planes149:
  if is_instance_valid(f.node): f.node.queue_free()
 planes149.clear();pending_mark149=Vector3.INF;super.reset146()
func point150(f: Dictionary,age: float) -> Vector3:
 return f.route.sample_baked(clampf(age/AIRTIME149,0.,1.)*float(f.length),true)
func launch146(packet: Dictionary,origin: Vector3,target: Vector3,gain := 1.,replay := false) -> void:
 var mark := target;mark.y=battle.floor_height(Vector2(mark.x,mark.z))+.05
 var direction := Vector3(mark.x-origin.x,0.,mark.z-origin.z).normalized()
 if direction.length_squared()<.01: direction=Vector3.FORWARD
 var side := direction.cross(Vector3.UP);var sign := -1. if flight_rng146.randf()<.5 else 1.
 var over := mark+side*flight_rng146.randf_range(-.35,.35)
 over.y=maxf(origin.y,mark.y)+flight_rng146.randf_range(4.1,5.1)
 var finish := over+direction*flight_rng146.randf_range(5.,7.)+side*sign*flight_rng146.randf_range(1.4,3.)
 finish.y=maxf(mark.y+.5,battle.floor_height(Vector2(finish.x,finish.z))+.4)
 var route := Curve3D.new();route.bake_interval=.06
 route.add_point(origin,Vector3.ZERO,direction*1.3-side*sign*flight_rng146.randf_range(1.4,2.7)+Vector3.UP*4.)
 var tangent := direction*flight_rng146.randf_range(1.5,2.1)+side*sign*flight_rng146.randf_range(1.6,2.2)-Vector3.UP*.15
 route.add_point(over,-tangent,tangent)
 route.add_point(finish,-direction*1.7+Vector3.UP*1.4,Vector3.ZERO)
 var length := route.get_baked_length()
 var release := clampf(route.get_closest_offset(over)/length*AIRTIME149, .5,AIRTIME149-.7)
 var copy := packet.duplicate(true);copy.air150=true
 var sprite := sprite146(plane_texture146,.85 if not replay else .72);sprite.position=origin
 planes149.append({"node":sprite,"packet":copy,"route":route,"length":length,"mark":mark,"over":over,"release":release,"spacing":spacing150(),"age":0.,"next":0,"gain":gain,"bank":flight_rng146.randf_range(.05,.13)*sign,"replay":replay})
 planes_launched146+=1;max_live146=maxi(max_live146,planes149.size());pending_mark149=Vector3.INF
func drop150(f: Dictionary,index: int) -> void:
 var when := drop_time150(f,index)
 var origin := point150(f,when)
 send146(f.packet,origin,f.mark,float(f.gain)/3.)
 if f.packet.stream and not bursts146.is_empty(): bursts146[-1].flight150=f
 drops149+=1;deliveries146+=1;last_origin146=origin
 history149.append({"origin":origin,"mark":f.mark,"index":index,"age":when,"packet":f.packet})
 if history149.size()>96: history149.pop_front()
func step146(delta: float) -> void:
 if (not battle.active114 or battle.player_hp<=0.) and (not planes149.is_empty() or pending_mark149.is_finite()): reset146()
 if battle.combat_paused: return
 for burst in bursts146:
  if burst.has("flight150"): burst.origin=point150(burst.flight150,float(burst.flight150.age)+delta)
 super.step146(delta)
 if not battle.active114 or battle.player_hp<=0. or battle.combat_paused: return
 for i in range(planes149.size()-1,-1,-1):
  var f: Dictionary=planes149[i];f.age+=delta
  var at := point150(f,f.age);var motion: Vector3=at-f.node.position
  f.node.position=at;f.node.basis=battle.camera.global_basis
  if motion.length_squared()>.000001:
   var screen: Vector2=battle.camera.unproject_position(at+motion.normalized()*.2)-battle.camera.unproject_position(at)
   f.node.rotate_object_local(Vector3.FORWARD,screen.angle()+sin(float(f.age)*2.4)*float(f.bank))
  while f.next<delivery_count150() and f.age>=drop_time150(f,f.next):
   drop150(f,f.next);f.next+=1
  f.node.modulate.a=1.-smoothstep(AIRTIME149-.25,AIRTIME149,float(f.age))
  if f.age>=AIRTIME149: f.node.queue_free();planes149.remove_at(i)
func _process(delta: float) -> void:
 super._process(delta)
 if battle.buffs.level("paper_plane")>0:
  hud146.text="掠过三投 · 在空%d架 · 当前弹幕载荷 · 放飞 %.2f秒\n"%[planes149.size(),battle.attack_cooldown()]+hud146.text.get_slice("\n",1)+"\n"+hud146.text.get_slice("\n",2)
func ring150(at: Vector3,radius: float,color: Color) -> void:
 var points := PackedVector2Array()
 for i in 25:
  var a := TAU*float(i)/24.
  points.append(battle.camera.unproject_position(at+Vector3(cos(a),0,sin(a))*radius))
 art146.draw_polyline(points,color,1.5,true)
func draw146() -> void:
 super.draw146()
 if not is_instance_valid(battle.camera): return
 if pending_mark149.is_finite(): ring150(pending_mark149,marker_radius150(),Color(1.,.91,.62,.45))
 for f in planes149:
  var alpha := 1.-smoothstep(float(f.release)+.25,float(f.release)+.8,float(f.age))
  if alpha<=0.: continue
  var color := Color(.97,.8,.53,.75*alpha) if not f.replay else Color(.68,.85,1.,.65*alpha)
  ring150(f.mark,marker_radius150(),color);ring150(f.mark,.15,color)
  var p: Vector2=battle.camera.unproject_position(f.mark)
  for j in delivery_count150(): art146.draw_circle(p+Vector2((float(j)-float(delivery_count150()-1)*.5)*9,14),2.5,color if j>=int(f.next) else Color(.9,.9,.8,.15*alpha))
