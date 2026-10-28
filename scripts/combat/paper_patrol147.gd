extends "res://scripts/combat/paper_memories146.gd"
const MAX_PLANES147 := 3
var patrol147: Array[Dictionary]=[]
var drops147 := 0
var skipped147 := 0
var peak_shots147 := 0
func reset146() -> void:
 for plane in patrol147:
  if is_instance_valid(plane.node): plane.node.queue_free()
 patrol147.clear();super.reset146()
func can_replay146(packet: Dictionary) -> bool:
 return not battle.random_planes147 or not packet.plane or patrol147.size()<MAX_PLANES147
func launch146(packet: Dictionary,origin: Vector3,target: Vector3,gain := 1.,replay := false) -> void:
 if not battle.random_planes147: super.launch146(packet,origin,target,gain,replay);return
 if patrol147.size()>=MAX_PLANES147: return
 var centre := origin;centre.y=battle.floor_height(Vector2(origin.x,origin.z))
 var direction := Vector2(target.x-origin.x,target.z-origin.z).normalized()
 if direction.length_squared()<.01: direction=Vector2.UP
 var angle := direction.angle()+flight_rng146.randf_range(-.65,.65)
 var sprite := sprite146(plane_texture146,.9 if not replay else .72);sprite.position=origin
 patrol147.append({"node":sprite,"start":origin,"centre":centre,"pos":origin,"angle":angle,"turn":flight_rng146.randf_range(-.9,.9),"speed":flight_rng146.randf_range(2.,3.),"height":flight_rng146.randf_range(2.8,3.8),"age":0.,"life":flight_rng146.randf_range(3.8,4.8),"choice":.25,"tick":.55,"gain":gain,"charged":bool(packet.get("charged147",false)),"ratio":float(packet.get("ratio147",0.)),"land":Vector3.INF})
 planes_launched146+=1;max_live146=maxi(max_live146,patrol147.size())
func step146(delta: float) -> void:
 if (not battle.active114 or battle.player_hp<=0.) and not patrol147.is_empty(): reset146()
 super.step146(delta)
 if not battle.active114 or battle.player_hp<=0. or battle.combat_paused: return
 peak_shots147=maxi(peak_shots147,battle.shots.size())
 for i in range(patrol147.size()-1,-1,-1):
  var p: Dictionary=patrol147[i];p.age+=delta
  var old: Vector3=p.pos
  if p.age<float(p.life):
   p.choice-=delta
   if p.choice<=0.:
    p.turn=lerpf(float(p.turn),flight_rng146.randf_range(-1.4,1.4),.6);p.speed=flight_rng146.randf_range(1.6,3.1);p.choice=flight_rng146.randf_range(.3,.7)
   var offset := Vector2(p.pos.x-p.centre.x,p.pos.z-p.centre.z)
   if offset.length()>4.6:
    p.angle=lerp_angle(float(p.angle),(-offset).angle(),minf(1.,delta*2.8))
   p.angle+=float(p.turn)*delta
   var flat := Vector2.from_angle(p.angle)*float(p.speed)*delta
   p.pos+=Vector3(flat.x,0,flat.y)
   var floor_y: float=battle.floor_height(Vector2(p.pos.x,p.pos.z))
   var climb := smoothstep(0.,.55,float(p.age))
   p.pos.y=lerpf(float(p.start.y),maxf(float(p.centre.y),floor_y)+float(p.height)+sin(float(p.age)*2.1)*.22,climb)
   p.tick-=delta
   if p.tick<=0. and p.age>.5:
    var interval: float=battle.patrol_interval147(p.charged)
    p.tick=interval # No catch-up loop after a slow frame.
    if battle.shots.size()<battle.MAX_SHOTS147-18:
     var ground := Vector3(p.pos.x+flight_rng146.randf_range(-.35,.35),0,p.pos.z+flight_rng146.randf_range(-.35,.35))
     ground.y=battle.floor_height(Vector2(ground.x,ground.z))+.05
     battle.drop_patrol147(p.pos,ground,float(p.gain)/3.,p.charged,p.ratio);drops147+=1
    else: skipped147+=1
  else:
   if not Vector3(p.land).is_finite():
    p.land=p.pos;p.land.y=battle.floor_height(Vector2(p.pos.x,p.pos.z))+.06;p.fall_start=p.pos
   var fall := clampf((float(p.age)-float(p.life))/.75,0.,1.)
   p.pos=Vector3(p.fall_start).lerp(p.land,fall*fall)
   p.node.modulate.a=1.-smoothstep(.82,1.,fall)
   if fall>=1.: p.node.queue_free();patrol147.remove_at(i);continue
  p.node.position=p.pos;p.node.basis=battle.camera.global_basis
  var heading: Vector3=Vector3(p.pos)-old
  if heading.length_squared()>.000001:
   var screen: Vector2=battle.camera.unproject_position(p.pos+heading.normalized()*.2)-battle.camera.unproject_position(p.pos)
   p.node.rotate_object_local(Vector3.FORWARD,screen.angle()+sin(float(p.age)*3.)*.08)
func _process(delta: float) -> void:
 super._process(delta)
 if not battle.random_planes147 or battle.buffs.level("paper_plane")==0: return
 hud146.text="随机巡航 %d/3 · 向下投弹 · F8切换瞄准投递\n"%patrol147.size()+hud146.text.get_slice("\n",1)+"\n"+hud146.text.get_slice("\n",2)
 if not pending146.is_empty() and patrol147.size()>=MAX_PLANES147: hud146.text+=" · 等待飞机空位"
func draw146() -> void:
 super.draw146()
 if not is_instance_valid(battle.camera): return
 for p in patrol147:
  var ground: Vector3=p.pos;ground.y=battle.floor_height(Vector2(ground.x,ground.z))+.06
  var point: Vector2=battle.camera.unproject_position(ground)
  art146.draw_arc(point,7.,0.,TAU,16,Color(.98,.89,.67,.3),1.)
