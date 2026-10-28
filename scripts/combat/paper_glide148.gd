extends "res://scripts/combat/paper_memories146.gd"
const MAX_PLANES148 := 3
const CLEARANCE148 := 1.25
var gliders148: Array[Dictionary]=[]
var emissions148: Array[Dictionary]=[]
func reset146() -> void:
 for f in gliders148:
  if is_instance_valid(f.node): f.node.queue_free()
 gliders148.clear();super.reset146()
func can_replay146(packet: Dictionary) -> bool:
 return not packet.plane or gliders148.size()<MAX_PLANES148
func choose_target148(origin: Vector3,lock: Vector3,preferred: Node3D=null) -> Node3D:
 if is_instance_valid(preferred) and not preferred.dead and preferred.is_visible_in_tree() and origin.distance_squared_to(preferred.hit_area.global_position)<144.:
  if clear_line148(origin,preferred.hit_area.global_position): return preferred
 var chosen: Node3D;var best := 4.*4.
 for enemy in battle.enemies:
  if not is_instance_valid(enemy) or enemy.dead or not enemy.is_visible_in_tree(): continue
  var centre: Vector3=enemy.hit_area.global_position;var distance := lock.distance_squared_to(centre)
  if distance<best and clear_line148(origin,centre): best=distance;chosen=enemy
 return chosen
func clear_line148(origin: Vector3,target: Vector3) -> bool:
 var query := PhysicsRayQueryParameters3D.create(origin,target,1|2,[battle.hero.get_rid()])
 return battle.get_world_3d().direct_space_state.intersect_ray(query).is_empty()
func separated148(origin: Vector3) -> bool:
 for enemy in battle.enemies:
  if is_instance_valid(enemy) and not enemy.dead and enemy.is_visible_in_tree() and origin.distance_squared_to(enemy.hit_area.global_position)<CLEARANCE148*CLEARANCE148: return false
 return true
func launch146(packet: Dictionary,origin: Vector3,target: Vector3,gain := 1.,replay := false) -> void:
 if gliders148.size()>=MAX_PLANES148: return
 var direction := Vector3(target.x-origin.x,0,target.z-origin.z).normalized()
 if direction.length_squared()<.01: direction=Vector3.FORWARD
 var side := direction.cross(Vector3.UP);var sign := -1. if flight_rng146.randf()<.5 else 1.
 var distance := clampf(Vector2(target.x-origin.x,target.z-origin.z).length(),.5,8.)
 var spread := flight_rng146.randf_range(.85,1.35)*sign
 var release := origin+direction*minf(3.,distance*.38)+side*spread
 release.y=maxf(origin.y+flight_rng146.randf_range(.35,.75),battle.floor_height(Vector2(release.x,release.z))+.8)
 # A nearby enemy needs lateral room for the carried bullet to be visible.
 if release.distance_to(target)<1.8: release+=side*sign*(1.8-release.distance_to(target)+.15)
 var finish := release+direction*flight_rng146.randf_range(3.,4.)+side*sign*flight_rng146.randf_range(1.1,2.1)
 finish.y=maxf(release.y-.7,battle.floor_height(Vector2(finish.x,finish.z))+.4)
 var land := finish+direction*.6;land.y=battle.floor_height(Vector2(land.x,land.z))+.05
 var sprite := sprite146(plane_texture146,.85 if not replay else .72);sprite.position=origin
 var copy := packet.duplicate(true);var charged := bool(copy.specs[0].charged)
 var count := 1 if charged else (maxi(1,ceili(float(copy.burst_time)/float(copy.pulse_interval))) if copy.stream else 3)
 count=mini(count,10)
 for spec in copy.specs:
  spec.speed=clampf(float(spec.speed),5.,13. if charged else 10.)
  spec.life=maxf(float(spec.life),1.2)
 battle.stream_generation110+=1
 gliders148.append({"node":sprite,"packet":copy,"start":origin,"release":release,"c1":origin+direction*.7+Vector3.UP*.4,"c2":release-direction*.65,"finish":finish,"out1":release+direction*1.4+Vector3.UP*.35,"out2":finish-direction*.9+Vector3.UP*.45,"land":land,"age":0.,"entry":flight_rng146.randf_range(.42,.6),"exit":flight_rng146.randf_range(1.1,1.5),"gain":gain,"target":choose_target148(origin,target),"lock":target,"left":count,"count":count,"tick":0.,"interval":maxf(.05,float(copy.pulse_interval)) if copy.stream else maxf(.07,.14/battle.buffs.rate()),"generation":battle.stream_generation110,"wind":flight_rng146.randf_range(-.15,.15),"side":side})
 planes_launched146+=1;max_live146=maxi(max_live146,gliders148.size())
func curve148(a: Vector3,b: Vector3,c: Vector3,d: Vector3,t: float) -> Vector3:
 var u := 1.-t
 return a*u*u*u+b*3.*u*u*t+c*3.*u*t*t+d*t*t*t
func point148(f: Dictionary) -> Vector3:
 var age := float(f.age);var entry := float(f.entry);var exit := float(f.exit)
 if age<entry: return curve148(f.start,f.c1,f.c2,f.release,age/entry)
 if age<entry+exit:
  var t := (age-entry)/exit
  return curve148(f.release,f.out1,f.out2,f.finish,t)+Vector3(f.side)*sin(t*TAU)*sin(t*PI)*float(f.wind)
 return Vector3(f.finish).lerp(f.land,smoothstep(0.,1.,clampf((age-entry-exit)/.65,0.,1.)))
func step146(delta: float) -> void:
 if (not battle.active114 or battle.player_hp<=0.) and not gliders148.is_empty(): reset146()
 super.step146(delta)
 if not battle.active114 or battle.player_hp<=0. or battle.combat_paused: return
 for i in range(gliders148.size()-1,-1,-1):
  var f: Dictionary=gliders148[i];f.age+=delta
  var at := point148(f);var motion: Vector3=at-f.node.position
  f.node.position=at;f.node.basis=battle.camera.global_basis
  if motion.length_squared()>.000001:
   var screen: Vector2=battle.camera.unproject_position(at+motion.normalized()*.2)-battle.camera.unproject_position(at)
   f.node.rotate_object_local(Vector3.FORWARD,screen.angle()+sin(float(f.age)*3.)*.12)
  if f.age>=float(f.entry):
   f.tick-=delta
   if f.left>0 and f.tick<=0. and battle.shots.size()<220 and separated148(at):
    var target: Node3D=choose_target148(at,f.lock,f.target);f.target=target
    var aim: Vector3=f.lock
    if is_instance_valid(target):
     var centre: Vector3=target.hit_area.global_position
     var speed: float=f.packet.specs[0].speed
     aim=centre+(target.velocity*minf(.25,at.distance_to(centre)/speed)).limit_length(.4)
    if at.distance_squared_to(aim)>=CLEARANCE148*CLEARANCE148:
     var share := 1. if f.packet.stream else 1./float(f.count)
     battle.emit_packet146(f.packet,at,aim,float(f.gain)*share,f.generation)
     emissions148.append({"origin":at,"target":aim,"distance":at.distance_to(aim),"age":f.age,"plane":f.node.get_instance_id()})
     if emissions148.size()>64: emissions148.pop_front()
     f.left-=1;f.tick=f.interval;deliveries146+=1;last_origin146=at
  var fade_start := float(f.entry)+float(f.exit)+.45
  f.node.modulate.a=1.-smoothstep(fade_start,fade_start+.2,float(f.age))
  if f.age>=fade_start+.2: f.node.queue_free();gliders148.remove_at(i)
func _process(delta: float) -> void:
 super._process(delta)
 if battle.buffs.level("paper_plane")>0:
  hud146.text="手抛滑翔 %d/3 · 空中释放 · 飞机不碰撞伤害\n"%gliders148.size()+hud146.text.get_slice("\n",1)+"\n"+hud146.text.get_slice("\n",2)
func draw146() -> void:
 super.draw146()
 # Brief wing-release marks only; no full trajectory laid over the scenery.
 for f in gliders148:
  if f.age>=float(f.entry) and f.age<float(f.entry)+.3:
   var p: Vector2=battle.camera.unproject_position(f.node.position)
   art146.draw_arc(p,9.,.25,2.8,10,Color(1.,.93,.74,.32),1.5)
