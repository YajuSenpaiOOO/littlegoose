extends "res://scripts/combat/paper_card302.gd"
var ready303 := false
var fire303: MeshInstance3D
var fire_fraction303 := 0.
var fire_reach303 := 4.2
var phase303 := ""
var phase_clock303 := 0.
var drop_index303 := 0
var landings303 := 0
var height303 := .65
var vertical303 := 0.
var lane_start303 := Vector2.ZERO
var lane_end303 := Vector2.ZERO
var tug303 := 0
var returned303 := false
func _ready() -> void:
 super._ready()
 fire303=fire_script303().new();add_child(fire303)
 ready303=true;render301()
func fire_script303() -> Script:return preload("res://scripts/art/paper_fire303.gd")
func tab302() -> Vector3:
 var tab=super.tab302()
 if kind301=="dinosaur" and is_instance_valid(visual) and visual.flip_h:tab.x=-tab.x
 return tab
func mouth303() -> Vector3:
 var p=Vector3((260.-float(spec301.foot[0]))*visual.pixel_size,(float(spec301.foot[1])-605.)*visual.pixel_size,0.)
 if visual.flip_h:p.x=-p.x
 return to_global(visual.transform*p)
func enter301(next: String) -> void:
 super.enter301(next)
 if not ready303:return
 phase_clock303=0.;fire_fraction303=0.
 if next=="warn":
  var player=Vector2(battle.hero.position.x,battle.hero.position.z)
  if kind301=="dinosaur":
   visual.flip_h=player.x>position.x;pose302()
   var mouth=mouth303();direction301=(player-Vector2(mouth.x,mouth.z)).normalized()
  if kind301=="monster":
   locked301=bounded_goal303(player,2.4);phase303="pull";drop_index303=0;tug303=0
  if direction301.length()<.01:direction301=Vector2.DOWN
  lane_start303=attack_at301();lane_end303=lane_start303+direction301*4.3
 if next=="attack":
  phase303="drop" if kind301=="monster" else "out";returned303=false
  if kind301=="monster":vertical303=minf(vertical303,-.8)
  elif kind301=="knight":angular302=(angular302+direction301*1.8).limit_length(3.6)
  else:angular302=(angular302-direction301*.65).limit_length(3.6)
 if next in ["stunned","broken","rest","recover"]:
  phase303="";fire303.hide()
func bounded_goal303(player: Vector2,reach: float) -> Vector2:
 var at=Vector2(position.x,position.z);return battle.paper_clamp301(at+(player-at).limit_length(reach))
func lift302() -> float:
 if not ready303:return super.lift302()
 if kind301=="monster":return height303
 if kind301=="knight" and state301=="attack":return HOVER302+sin(clampf(clock301/1.18,0.,1.)*PI)*.28
 return HOVER302
func _physics_process(delta: float) -> void:
 if not ready303 or dead:
  super._physics_process(delta);return
 if battle.combat_paused:return
 if not battle.active114:cue301.hide();fire303.hide();return
 clock301+=delta;phase_clock303+=delta;age+=delta
 flash=maxf(0.,flash-delta);health_time=maxf(0.,health_time-delta);juice_gate=maxf(0.,juice_gate-delta)
 var at=Vector2(position.x,position.z);var player=Vector2(battle.hero.position.x,battle.hero.position.z);var motion=Vector2.ZERO
 match state301:
  "enter":
   if clock301>=.85:hit_area.collision_layer=8;enter301("rest")
  "rest":
   var offset=(at-player).normalized()*(2.4 if kind301!="dinosaur" else 3.2)
   if kind301=="dinosaur":offset=Vector2(-3.2 if at.x<player.x else 3.2,0.)
   motion=(battle.paper_clamp301(player+offset)-at).limit_length(1.)*1.6
   if clock301>1.25+role110*.12:enter301("warn")
  "warn":
   if kind301=="monster":motion=(locked301-at).limit_length(1.)*3.
   if kind301=="knight":angular302+=(-direction301*.40-angle302)*delta*12.
   if clock301>=.95 and can_release303():enter301("attack")
  "attack":
   if kind301=="monster":
    if phase303=="pull":
     motion=(locked301-at).limit_length(1.)*3.
     if phase_clock303>(.64 if drop_index303==2 else .42):phase303="drop";phase_clock303=0.;vertical303=-.8;connected301=false
    elif phase303=="catch":
     if phase_clock303>([.38,.30,.52][drop_index303]):
      drop_index303+=1
      if drop_index303>=3:enter301("recover")
      else:
       phase303="pull";phase_clock303=0.;tug303=0;locked301=bounded_goal303(player,1.45)
   elif kind301=="knight":
    if clock301<.58:motion=direction301*10.*sin(clampf(clock301/.58,0.,1.)*PI)
    else:
     returned303=true;motion=-direction301*3.5*sin(clampf((clock301-.58)/.60,0.,1.)*PI)
    if clock301>=1.18:enter301("recover")
   else:
    fire_fraction303=smoothstep(0.,.32,clock301)*(1.-smoothstep(1.05,1.30,clock301))
    if clock301>=1.30:enter301("recover")
  "recover","stunned":
   if clock301>(1.5 if state301=="stunned" else 1.):enter301("rest")
 var before=attack_at301()
 move301(motion,delta)
 if kind301=="monster":vertical_step303(delta)
 pose302()
 if state301=="attack":
  if kind301=="dinosaur":
   var start=mouth303();fire_reach303=obstacle_reach303(start)
   var relative=player-Vector2(start.x,start.z);var forward=relative.dot(direction301)
   var inside=clock301>=.18 and clock301<1.08 and forward>=0. and forward<minf(fire_reach303,4.2*fire_fraction303) and absf(relative.cross(direction301))<.30+forward*.20
   if inside:contact303(Vector2(start.x,start.z))
  elif kind301=="knight" and clock301<.58:
   if battle.aim_model.sweep_circle(before,attack_at301(),player,.85)<=1.:contact303(attack_at301())
 render301()
func can_release303() -> bool: return true

func vertical_step303(delta: float) -> void:
 var count=maxi(1,int(ceil(delta*120.)));var dt=delta/float(count)
 for i in count:
  if state301=="attack" and phase303=="drop":
   vertical303-=24.*dt;height303+=vertical303*dt
   if height303<=.12:
    height303=.12;vertical303=4.1-.35*drop_index303;phase303="catch";phase_clock303=0.;tug303=0;landings303+=1
    angular302=(angular302+Vector2(.11 if drop_index303%2 else -.11,.06)).limit_length(3.6)
    var player=Vector2(battle.hero.position.x,battle.hero.position.z)
    if player.distance_to(attack_at301())<1.5:contact303(attack_at301())
  else:
   var pulling=state301=="warn" or state301=="attack" and phase303=="pull"
   var catching=state301=="attack" and phase303=="catch"
   var target=1.25 if pulling else (.40 if catching else HOVER302)
   var spring=240. if catching else 65.;var damping=4.8 if catching else 9.
   vertical303+=((target-height303)*spring-vertical303*damping)*dt;height303+=vertical303*dt
   if catching and tug303==0 and phase_clock303>.11:vertical303-=.65;tug303=1
   if catching and tug303==1 and phase_clock303>.24:vertical303+=.35;tug303=2
   height303=clampf(height303,.12,1.30)
func contact303(at: Vector2) -> void:
 if connected301 or state301!="attack" or dead:return
 if absf(contact_height303()-battle.hero.position.y)>.85:return
 var ray=PhysicsRayQueryParameters3D.create(attack_origin301(),battle.hero.position+Vector3.UP*.7,1|2)
 if not get_world_3d().direct_space_state.intersect_ray(ray).is_empty():return
 connected301=true
 if battle.hero.can_parry():deflect(battle.hero.position+Vector3.UP*.7)
 else:
  var previous=battle.player_hp;battle.hurt_player(contact_damage303(),at)
  if battle.player_hp<previous:hits301+=1
func contact_height303() -> float:return position.y
func contact_damage303() -> float:return 1.5
func obstacle_reach303(start: Vector3) -> float:
 var end=start+Vector3(direction301.x,0,direction301.y)*4.2;end.y=battle.floor_height(Vector2(end.x,end.z))+.95
 var ray=PhysicsRayQueryParameters3D.create(start,end,1|2)
 var hit=get_world_3d().direct_space_state.intersect_ray(ray)
 return clampf(Vector2(hit.position.x-start.x,hit.position.z-start.z).length()-.05,0.,4.2) if not hit.is_empty() else 4.2
func render301() -> void:
 super.render301()
 if not ready303:return
 if kind301=="dinosaur" and state301=="attack" and not dead:
  var start=mouth303();var end=start+Vector3(direction301.x,0,direction301.y)*4.2;end.y=battle.floor_height(Vector2(end.x,end.z))+.95
  fire303.show303(start,end,battle.camera.global_position,minf(fire_fraction303,fire_reach303/4.2),clock301)
 else:fire303.hide()
func draw_cue301() -> void:
 if not ready303:super.draw_cue301();return
 var points: Array[Vector2]=[];var at=attack_at301()
 if kind301=="monster":
  if state301=="attack" and phase303=="catch":cue301.hide();return
  var centre=locked301 if state301=="warn" or phase303=="pull" else at
  for i in 32:points.append(centre+Vector2(cos(TAU*i/32.),sin(TAU*i/32.))*1.35)
 elif kind301=="knight":
  if returned303:cue301.hide();return
  var cross=direction301.orthogonal()*.65;points=[lane_start303-cross,lane_end303-cross,lane_end303+cross,lane_start303+cross]
 else:
  var mouth=mouth303();at=Vector2(mouth.x,mouth.z);var cross=direction301.orthogonal()
  points=[at-cross*.3,at+direction301*4.2-cross*1.14,at+direction301*4.2+cross*1.14,at+cross*.3]
 var st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var colour=Color(1.,.66,.22,.24 if state301=="warn" or phase303=="pull" else .12)
 for i in range(1,points.size()-1):
  for p in [points[0],points[i],points[i+1]]:st.set_color(colour);st.add_vertex(Vector3(p.x,battle.floor_height(p)+.08,p.y))
 cue301.mesh=st.commit();cue301.global_transform=Transform3D.IDENTITY
