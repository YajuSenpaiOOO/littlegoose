extends "res://scripts/combat/paper_squad230.gd"
const PAYLOAD_GAIN232 := 1.25
const DURATION232 := 1.25
func repeat_penalty230() -> float:return .1
func launch146(packet: Dictionary,origin: Vector3,target: Vector3,gain := 1.,replay := false) -> void:
 var first=planes149.size();super.launch146(packet,origin,target,gain,replay)
 for i in range(first,planes149.size()):
  var f: Dictionary=planes149[i]
  var start: Vector3=f.route.sample_baked(0.)
  var direction=Vector3(f.mark.x-start.x,0.,f.mark.z-start.z).normalized()
  if direction.length_squared()<.01:direction=Vector3.FORWARD
  f.rain232={"start":start,"over":Vector3(f.mark.x,maxf(f.mark.y+3.4,start.y+2.4),f.mark.z),"direction":direction,"side":direction.cross(Vector3.UP)}
  f.release=.50+float(f.get("goose_source169",0))*.025;f.spacing=.09;f.gain*=PAYLOAD_GAIN232
  # Three inner samples express the marked target; three outer samples retain
  # the rain's area coverage. This does not force all drops onto one enemy.
  var rotation=flight_rng146.randf_range(0.,TAU)
  f.coverage151=[]
  for j in 6:
   var angle=rotation;var radius=0.
   if j==1:angle+=PI*.5;radius=.7
   elif j==3:angle+=PI*1.5;radius=.9
   elif j in [2,4,5]:angle+=TAU*float([2,4,5].find(j))/3.;radius=COVERAGE151*.7
   var point: Vector3=f.mark+Vector3(cos(angle),0.,sin(angle))*radius
   point.y=battle.floor_height(Vector2(point.x,point.z))+.05;f.coverage151.append(point)
func drop150(f: Dictionary,index: int) -> void:
 var when=drop_time150(f,index);var path_origin=point150(f,when)
 var sample: Vector3=f.coverage151[index];var target=choose_local230(f,sample,path_origin.y);var aim=sample
 if is_instance_valid(target):
  aim=target.hit_area.global_position
  var shape: Shape3D=target.hit_area.get_child(0).shape
  var radius=minf(.28,float(shape.radius)*.35) if shape is CapsuleShape3D or shape is SphereShape3D else .12
  var angle=flight_rng146.randf_range(0.,TAU);var jitter=radius*sqrt(flight_rng146.randf())
  aim+=Vector3(cos(angle),0.,sin(angle))*jitter
  var offset=Vector2(aim.x-f.mark.x,aim.z-f.mark.z).limit_length(COVERAGE151)
  aim.x=f.mark.x+offset.x;aim.z=f.mark.z+offset.y
  var id=target.get_instance_id();f.used151[id]=int(f.used151.get(id,0))+1;assigned151+=1;local_assignments230+=1
 var origin=Vector3(aim.x,path_origin.y,aim.z)
 send146(f.packet,origin,aim,float(f.gain)/6.)
 drops149+=1;deliveries146+=1;last_origin146=origin
 history149.append({"origin":origin,"mark":f.mark,"aim":aim,"sample":sample,"index":index,"age":when,"packet":f.packet,"target_id":target.get_instance_id() if is_instance_valid(target) else 0})
 if history149.size()>96:history149.pop_front()
func point150(f: Dictionary,age: float) -> Vector3:
 if not f.has("rain232"):return super.point150(f,age)
 var r: Dictionary=f.rain232;var beginning: Vector3=r.over-r.side*.9
 if age<.25:return Vector3(r.start).lerp(beginning,smoothstep(0.,.25,age))
 if age<.85:return r.over+r.side*lerpf(-.9,.9,clampf((age-.25)/.6,0.,1.))
 var t=clampf((age-.85)/.4,0.,1.)
 return r.over+r.side*.9+Vector3(r.direction)*t*5.+Vector3.DOWN*t*.8
func step146(delta: float) -> void:
 super.step146(delta)
 if battle.combat_paused:return
 for i in range(planes149.size()-1,-1,-1):
  var f: Dictionary=planes149[i]
  if not f.has("rain232"):continue
  f.node.modulate.a=1.-smoothstep(DURATION232-.2,DURATION232,float(f.age))
  if f.age>=DURATION232:f.node.queue_free();planes149.remove_at(i)
func _process(delta: float) -> void:
 super._process(delta)
 if hud146.visible and "局部校准 · 直落六连投" in hud146.text:hud146.text=hud146.text.replace("局部校准 · 直落六连投","连续洒落 · 载荷＋25%")
