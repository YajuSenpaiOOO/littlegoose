extends "res://scripts/combat/paper_memories146.gd"
const AIRTIME149 := 3.6
const BLAST149 := 1.4
var planes149: Array[Dictionary]=[]
var bombs149: Array[Dictionary]=[]
var bursts149: Array[Dictionary]=[]
var history149: Array[Dictionary]=[]
var pending_mark149 := Vector3.INF
var drops149 := 0
var impacts149 := 0
func reset146() -> void:
 for f in planes149:
  if is_instance_valid(f.node): f.node.queue_free()
 planes149.clear();bombs149.clear();bursts149.clear();pending_mark149=Vector3.INF;super.reset146()
func curve149(a: Vector3,b: Vector3,c: Vector3,d: Vector3,t: float) -> Vector3:
 var u := 1.-t
 return a*u*u*u+b*3.*u*u*t+c*3.*u*t*t+d*t*t*t
func point149(f: Dictionary,age: float) -> Vector3:
 var approach := float(f.approach);var pass_time := float(f.pass_time)
 if age<approach: return curve149(f.start,f.c1,f.c2,f.inlet,age/approach)
 if age<approach+pass_time: return Vector3(f.inlet).lerp(f.outlet,(age-approach)/pass_time)
 var t := clampf((age-approach-pass_time)/(AIRTIME149-approach-pass_time),0.,1.)
 return curve149(f.outlet,f.out1,f.out2,f.finish,t)
func launch146(packet: Dictionary,origin: Vector3,target: Vector3,gain := 1.,replay := false) -> void:
 var mark := target;mark.y=battle.floor_height(Vector2(mark.x,mark.z))+.05
 var direction := Vector3(mark.x-origin.x,0.,mark.z-origin.z).normalized()
 if direction.length_squared()<.01: direction=Vector3.FORWARD
 var side := direction.cross(Vector3.UP);var sign := -1. if flight_rng146.randf()<.5 else 1.
 var height := maxf(origin.y,mark.y)+flight_rng146.randf_range(4.1,5.1)
 var centre := Vector3(mark.x,height,mark.z)
 var inlet := centre-direction*.9;var outlet := centre+direction*.9
 var approach := flight_rng146.randf_range(1.15,1.65);var pass_time := flight_rng146.randf_range(.58,.72)
 # Match the approach tangent to the flyover speed; randomness stays in the high approach.
 var tangent := approach*.6/pass_time
 var c1 := origin+direction*flight_rng146.randf_range(.7,1.5)+side*sign*flight_rng146.randf_range(1.5,3.)+Vector3.UP*flight_rng146.randf_range(4.,5.)
 var c2 := inlet-direction*tangent
 var finish := outlet+direction*flight_rng146.randf_range(4.,6.)+side*sign*flight_rng146.randf_range(1.7,3.5)
 finish.y=maxf(mark.y+.6,battle.floor_height(Vector2(finish.x,finish.z))+.4)
 var out_time := AIRTIME149-approach-pass_time
 var sprite := sprite146(plane_texture146,.85 if not replay else .72);sprite.position=origin
 planes149.append({"node":sprite,"packet":packet.duplicate(true),"start":origin,"mark":mark,"centre":centre,"inlet":inlet,"outlet":outlet,"c1":c1,"c2":c2,"out1":outlet+direction*(out_time*.6/pass_time),"out2":finish-direction*1.2+Vector3.UP*.7,"finish":finish,"approach":approach,"pass_time":pass_time,"age":0.,"next":0,"landed":0,"gain":gain,"bank":flight_rng146.randf_range(.06,.15)*sign,"replay":replay})
 planes_launched146+=1;max_live146=maxi(max_live146,planes149.size());pending_mark149=Vector3.INF
func drop149(f: Dictionary,index: int) -> void:
 var when := float(f.approach)+float(f.pass_time)*(.15+.35*index)
 var origin := point149(f,when)
 bombs149.append({"start":origin,"mark":f.mark,"packet":f.packet,"gain":float(f.gain)/3.,"age":0.,"duration":flight_rng146.randf_range(.6,.78),"flight":f,"pos":origin,"sway":flight_rng146.randf_range(-.15,.15),"index":index})
 drops149+=1;deliveries146+=1;last_origin146=origin
 history149.append({"origin":origin,"mark":f.mark,"index":index,"age":when})
 if history149.size()>96: history149.pop_front()
func step146(delta: float) -> void:
 if (not battle.active114 or battle.player_hp<=0.) and (not planes149.is_empty() or not bombs149.is_empty()): reset146()
 super.step146(delta)
 if not battle.active114 or battle.player_hp<=0. or battle.combat_paused: return
 for i in range(planes149.size()-1,-1,-1):
  var f: Dictionary=planes149[i];f.age+=delta
  var at := point149(f,f.age);var motion: Vector3=at-f.node.position
  f.node.position=at;f.node.basis=battle.camera.global_basis
  if motion.length_squared()>.000001:
   var screen: Vector2=battle.camera.unproject_position(at+motion.normalized()*.2)-battle.camera.unproject_position(at)
   f.node.rotate_object_local(Vector3.FORWARD,screen.angle()+sin(float(f.age)*2.4)*float(f.bank))
  while f.next<3 and f.age>=float(f.approach)+float(f.pass_time)*(.15+.35*int(f.next)):
   drop149(f,f.next);f.next+=1
  f.node.modulate.a=1.-smoothstep(AIRTIME149-.25,AIRTIME149,float(f.age))
  if f.age>=AIRTIME149: f.node.queue_free();planes149.remove_at(i)
 for i in range(bombs149.size()-1,-1,-1):
  var b: Dictionary=bombs149[i];b.age+=delta;var t := clampf(float(b.age)/float(b.duration),0.,1.)
  b.pos=Vector3(b.start).lerp(b.mark,t*t)+Vector3.RIGHT*sin(t*PI)*float(b.sway)
  if t>=1.:
   battle.bomb_impact149(b.packet,b.mark,b.gain);b.flight.landed+=1;impacts149+=1
   bursts149.append({"mark":b.mark,"age":0.,"stream":bool(b.packet.stream),"charged":bool(b.packet.specs[0].charged)})
   bombs149.remove_at(i)
 for i in range(bursts149.size()-1,-1,-1):
  bursts149[i].age+=delta
  if bursts149[i].age>.42: bursts149.remove_at(i)
func _process(delta: float) -> void:
 super._process(delta)
 if battle.buffs.level("paper_plane")>0:
  hud146.text="标记轰炸 · 在空%d架 · 每架3投 · 放飞 %.2f秒\n"%[planes149.size(),battle.attack_cooldown()]+hud146.text.get_slice("\n",1)+"\n"+hud146.text.get_slice("\n",2)
func ring149(at: Vector3,radius: float,color: Color,width := 1.5) -> void:
 var points := PackedVector2Array()
 for i in 33:
  var a := TAU*float(i)/32.
  points.append(battle.camera.unproject_position(at+Vector3(cos(a),0,sin(a))*radius))
 art146.draw_polyline(points,color,width,true)
func draw146() -> void:
 super.draw146()
 if not is_instance_valid(battle.camera): return
 if pending_mark149.is_finite(): ring149(pending_mark149,BLAST149,Color(1.,.91,.62,.45))
 for f in planes149:
  if f.landed>=3: continue
  var color := Color(.97,.8,.53,.75) if not f.replay else Color(.68,.85,1.,.65)
  ring149(f.mark,BLAST149,color);ring149(f.mark,.2,color,2.)
  var centre: Vector2=battle.camera.unproject_position(f.mark)
  for j in 3:
   art146.draw_circle(centre+Vector2((j-1)*9,17),2.5,color if j>=int(f.landed) else Color(.9,.9,.8,.2))
 for b in bombs149:
  if battle.camera.is_position_behind(b.pos): continue
  var p: Vector2=battle.camera.unproject_position(b.pos)
  var color := Color("a7e4ef") if b.packet.stream else Color("ffeac3")
  var size := 7. if b.packet.specs[0].charged else 5.
  var poly := PackedVector2Array([p+Vector2(-size,-size*.5),p+Vector2(0,-size),p+Vector2(size,-size*.5),p+Vector2(size,size*.5),p+Vector2(0,size),p+Vector2(-size,size*.5),p+Vector2(-size,-size*.5)])
  art146.draw_colored_polygon(poly,color);art146.draw_polyline(poly,Color("68415f"),1.5)
  art146.draw_line(p+Vector2(0,-size),p+Vector2(2,-size-6),Color(1.,.9,.65,.6),2.)
 for burst in bursts149:
  var t := float(burst.age)/.42;var at: Vector3=burst.mark
  var color := Color(.65,.9,1.,1.-t) if burst.stream else Color(1.,.88,.6,1.-t)
  ring149(at,BLAST149*(.25+.75*t),color,3.*(1.-t)+1.)
  var p: Vector2=battle.camera.unproject_position(at+Vector3.UP*.15)
  for j in 6:
   var direction := Vector2.from_angle(TAU*float(j)/6.)
   art146.draw_line(p+direction*(4.+t*9.),p+direction*(8.+t*16.),color,2.)
