extends "res://scripts/world/woodland_world266.gd"
var heading267 := Vector2.ZERO
var planning_wait267 := 0.
var wing267 := 1.
var tactics267 := {}
var tactics_enabled267 := true
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 267 · 团团侧翼 / 前路拦截")
func minion_script260() -> Script:return preload("res://scripts/combat/tuantuan_minion267.gd")
func ordinary264() -> void:
 heading267=Vector2.ZERO;planning_wait267=0.;wing267=1.
 tactics267={"assignments":0,"front_entries":0,"max_flankers":0,"arrived":0,"hit_breaks":0,"timeouts":0,"intercepts":0,"staggered_attacks":0}
 super.ordinary264()
func flank_event267(kind: String,details: Dictionary) -> void:
 if kind=="flank_end":
  var key={"arrived":"arrived","hit":"hit_breaks","timeout":"timeouts","intercept":"intercepts"}.get(details.reason,"")
  if key!="":tactics267[key]=int(tactics267.get(key,0))+1
 telemetry260.event(kind,details)
func late267() -> bool:
 return tactics_enabled267 and ready264 and mode264=="ordinary" and roster264.wave>=2 and roster264.spawned>=7
func entry_lanes261() -> Array:
 var lanes=super.entry_lanes261().duplicate()
 if not late267() or heading267.length()<.5:return lanes
 var player=Vector2(hero.position.x,hero.position.z);var centre: Vector2=meadow.landmarks.grove
 # Parent rotates by serial: put the preferred route at that slot, retaining all physical fallback checks.
 lanes.sort_custom(func(a,b):return (centre+a.gate-player).dot(heading267)>(centre+b.gate-player).dot(heading267))
 var ordered: Array=[]
 for i in lanes.size():ordered.append(lanes[posmod(i-serial260,lanes.size())])
 return ordered
func spawn_minion260() -> CharacterBody3D:
 var late=late267();var m=super.spawn_minion260()
 if late and is_instance_valid(m) and heading267.length()>.5:
  var relative=Vector2(m.position.x-hero.position.x,m.position.z-hero.position.z)
  if relative.dot(heading267)>0.:
   tactics267.front_entries+=1;telemetry260.event("front_entry",{"lane":m.entry_name261})
 return m
func flank_plan267() -> void:
 if not late267() or heading267.length()<.5:return
 var live=live_minions260();var count=live.filter(func(m):return m.flanking267()).size()
 var limit=2 if roster264.wave>=3 and live.size()>=4 else 1
 tactics267.max_flankers=maxi(int(tactics267.max_flankers),count)
 if count>=limit or live.size()<3:return
 if count==0:wing267=-wing267
 var player=Vector2(hero.position.x,hero.position.z);var side=heading267.orthogonal()*wing267
 var candidates=live.filter(func(m):return m.state260=="ground" and m.attack_phase=="approach" and m.play_state123=="" and m.parry_stun<=0. and m.flank_cooldown267<=0. and not m.flanking267())
 var desired=player+heading267*(2.2 if count==0 else .4)+side*(1.9 if count==0 else 3.)
 candidates.sort_custom(func(a,b):return Vector2(a.position.x,a.position.z).distance_squared_to(desired)<Vector2(b.position.x,b.position.z).distance_squared_to(desired))
 for m in candidates:
  var at=Vector2(m.position.x,m.position.z)
  # Do not send a slow rear chaser on an impossible lap around a faster player.
  if at.distance_to(desired)>4.5 or at.distance_to(player)<1.5:continue
  var path: PackedVector2Array=entry_navigation261.path(at,desired)
  if path.is_empty() or path[-1].distance_to(desired)>.8:continue
  var goal=path[-1];var length=0.
  for i in range(1,path.size()):length+=path[i].distance_to(path[i-1])
  if length>5. or goal.distance_to(player)<1.6 or (goal-player).dot(side)<1.2:continue
  m.assign_flank267(goal,"front" if count==0 else "side")
  tactics267.assignments+=1;tactics267.max_flankers=maxi(int(tactics267.max_flankers),count+1)
  telemetry260.event("flank_start",{"actor":m.role110,"role":m.flank_role267,"goal":[goal.x,goal.y],"wave":roster264.wave,"wing":wing267})
  break
func reserve_attack(enemy: CharacterBody3D) -> bool:
 if mode264=="ordinary" and enemy in minions260 and enemy.flanking267():return false
 if late267() and enemy in minions260 and enemy.intercept_left267<=0.:
  # Give a front-side interceptor one brief turn before a rear chaser spends the shared attack slot.
  for m in live_minions260():
   if m==enemy or m.intercept_left267<=0. or m.state260!="ground" or m.attack_phase!="approach" or m.hopping or m.parry_stun>0. or m.play_state123!="":continue
   if Vector2(m.position.x-hero.position.x,m.position.z-hero.position.z).length()<4.6:return false
 var allowed=super.reserve_attack(enemy)
 if allowed and late267() and enemy in minions260:
  # Existing one-attacker rule stays intact; shorten idle between the late-wave turns.
  attack_gate260=.95 if roster264.wave==2 else .85
  tactics267.staggered_attacks+=1
 return allowed
func _physics_process(delta: float) -> void:
 if ready264 and mode264=="ordinary" and active114 and not combat_paused:
  var motion=Vector2(hero.velocity.x,hero.velocity.z)
  if motion.length()>1.:heading267=heading267.lerp(motion.normalized(),minf(1.,delta*4.)).limit_length(1.)
  else:heading267=heading267.move_toward(Vector2.ZERO,delta*2.)
  planning_wait267-=delta
  if planning_wait267<=0.:flank_plan267();planning_wait267=.45
 super._physics_process(delta)
func report_stats226() -> Dictionary:
 var report=super.report_stats226()
 report["tactics267"]=tactics267.duplicate(true)
 return report
func _process(delta: float) -> void:
 super._process(delta)
 if ready264:guide206.text=guide206.text.replace("266 林间空地","267 林间空地").replace("266 大团团挑战","267 大团团挑战")
