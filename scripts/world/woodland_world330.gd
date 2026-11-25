extends "res://scripts/world/woodland_world327.gd"

const PHASES330 := ["重纸弹 · 右键瞬按弹回", "交替散射", "三连迫击炮", "斜向流星排"]
const DURATIONS330 := [6.8,5.2,6.6,8.4]
const RETURN_DAMAGE330 := 8.
var attack330 := 0
var heavies330: Array[Dictionary] = []
var reflected330 := 0

func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 330 · 重纸弹 / 迫击炮")

func stage_script314() -> Script:
 return preload("res://scripts/art/paper_stage330.gd")

func _ready() -> void:
 await super._ready()
 hint288.text = "330 重纸弹 / 迫击炮\n红星重弹可弹回 · 右键按下瞬间弹反"

func restart301() -> void:
 clear_heavy330()
 attack330 = 0
 reflected330 = 0
 super.restart301()
 pattern_left327 = DURATIONS330[0]

func boss_step314(delta: float) -> void:
 if not heavies330.is_empty(): cameo_left327 = maxf(cameo_left327,.3)
 super.boss_step314(delta)
 if not waiting_intro314: tick_heavy330(delta)

func tick_pattern327(delta: float) -> void:
 pattern_left327 -= delta
 volley_left327 -= delta
 if pattern_left327 <= 0.:
  # Give the heavy ball its full travel/return before starting the next volley.
  if not heavies330.is_empty(): return
  attack330 = (attack330+1)%PHASES330.size()
  pattern327 = [0,0,1,2][attack330]
  pattern_left327 = DURATIONS330[attack330]
  pattern_started327 = false
  volley_left327 = .85
 var source := live_device327()
 if source < 0: return
 theatre314.aim_cannon326(source,volley_left327<.55)
 if volley_left327>0.: return
 if attack330 == 0:
  if not pattern_started327:
   pattern_started327 = true
   charge_heavy330(source)
 elif attack330 == 1:
  scatter327(source)
  cannon_index326 = 1-source
  volley_left327 = 1.65
 elif not pattern_started327:
  pattern_started327 = true
  if attack330 == 2: mortar327(source)
  else: meteor_row327(source)

func charge_heavy330(source: int) -> void:
 var at: Vector3 = theatre314.muzzle330(source)
 var sprite: Sprite3D = theatre314.projectile330(true,at)
 sprite.scale = Vector3.ONE*.35
 var ring: MeshInstance3D = theatre314.make_ring327()
 heavies330.append({"sprite":sprite,"ring":ring,"at":at,"source":source,"age":0.,"state":"charge","life":4.2,"heading":Vector2.ZERO,"return_at":Vector3.ZERO,"height":at.y-floor_height(Vector2(at.x,at.z))})

func tick_heavy330(delta: float) -> void:
 for i in range(heavies330.size()-1,-1,-1):
  var ball := heavies330[i]
  ball.age += delta
  var sprite: Sprite3D = ball.sprite
  if ball.state == "charge":
   if cannon_hp326[ball.source] <= 0.:
    remove_heavy330(i)
    continue
   var t := clampf(float(ball.age)/1.15,0.,1.)
   sprite.scale = Vector3.ONE*lerpf(.35,1.,smoothstep(0.,1.,t))
   sprite.global_position = Vector3(ball.at)+Vector3(sin(float(ball.age)*42.)*.025*t,0.,0.)
   sprite.modulate = Color(1.,1.-t*.2,1.-t*.3)
   var foot := Vector2(ball.at.x,ball.at.z)
   theatre314.paint_ring327(ball.ring,foot,.25+t*.4,.2+t*.5)
   if t>=1.:
    var target: Vector3 = hero.global_position
    ball.heading = Vector2(target.x-ball.at.x,target.z-ball.at.z).normalized()
    ball.state = "incoming"
    ball.age = 0.
    sprite.modulate = Color.WHITE
    theatre314.paint_ring327(ball.ring,foot,0.,0.)
    theatre314.recoil_cannon326(ball.source)
    Audio.play("crack",.85)
   continue
  if ball.state == "return":
   var goal: Vector3 = ball.return_at
   var next: Vector3 = Vector3(ball.at).move_toward(goal,delta*12.)
   ball.at = next
   sprite.global_position = next
   sprite.rotation.z -= delta*8.
   if next.distance_to(goal)<.01:
    var blast: Dictionary = theatre314.make_blast327(Vector2(goal.x,goal.z),2.4)
    blast.boom.global_position = goal
    get_tree().create_timer(.5).timeout.connect(blast.root.queue_free)
    damage_fastener321({"fixed_damage110":RETURN_DAMAGE330,"velocity":Vector3.FORWARD},goal)
    theatre314.wall_recoil321 = .5
    impact_feedback328(Vector2(goal.x,goal.z),true)
    hitstop(.1,true)
    remove_heavy330(i)
   continue
  var from: Vector3 = cannon_start338(ball.at,float(ball.height))
  var heading: Vector2 = ball.heading
  var to := from+Vector3(heading.x,0.,heading.y)*delta*5.2
  var feet := Vector2(hero.global_position.x,hero.global_position.z)
  to.y = cannon_height338(Vector2(to.x,to.z),float(ball.height))
  ball.life -= delta
  var excluded: Array[RID] = []
  var own: Node3D = theatre314.scenery_shapes322[theatre314.cannons326[ball.source]].get_parent()
  if own is CollisionObject3D: excluded.append(own.get_rid())
  var wall := get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from,to,1|2,excluded))
  var close := aim_model.sweep_circle(Vector2(from.x,from.z),Vector2(to.x,to.z),feet,.83)<=1. and absf(hero.global_position.y-floor_height(feet))<.85
  if wall.is_empty() and close:
   if hero.can_parry():
    var count := parry_count
    parry_threat306 = 2.
    parry_success(hero.global_position+Vector3.UP*.7,-Vector3(heading.x,0.,heading.y))
    parry_threat306 = 0.
    if parry_count>count:
     ball.state = "return"
     ball.at = to
     ball.return_at = theatre314.castle.global_position+Vector3(0.,1.4,.3)
     sprite.modulate = Color(1.,1.,.65)
     reflected330 += 1
     volley_left327 = maxf(volley_left327,1.2)
     continue
   if not perfect_hazard328(): hazard_hurt332(2.,Vector2(from.x,from.z),"heavy")
   heavy_burst330(to)
   remove_heavy330(i)
   continue
  if not wall.is_empty() or ball.life<=0.:
   heavy_burst330(to)
   remove_heavy330(i)
   continue
  ball.at = to
  sprite.global_position = to
  sprite.rotation.z += delta*2.2

func heavy_burst330(at: Vector3) -> void:
 structure_contact326(at,Vector3.UP,true)
 impact_feedback328(Vector2(at.x,at.z),false)

func remove_heavy330(index: int) -> void:
 var ball := heavies330[index]
 ball.sprite.queue_free()
 ball.ring.queue_free()
 heavies330.remove_at(index)

func clear_heavy330() -> void:
 for ball in heavies330:
  if is_instance_valid(ball.sprite): ball.sprite.queue_free()
  if is_instance_valid(ball.ring): ball.ring.queue_free()
 heavies330.clear()

func clear_patterns327() -> void:
 clear_heavy330()
 super.clear_patterns327()

func interrupt327(source := -1) -> void:
 super.interrupt327(source)
 for i in range(heavies330.size()-1,-1,-1):
  var ball := heavies330[i]
  if ball.state == "charge" and (source<0 or ball.source==source): remove_heavy330(i)

func mortar327(source: int) -> void:
 var base := paper_clamp301(Vector2(hero.global_position.x,hero.global_position.z))
 var motion := Vector2(hero.velocity.x,hero.velocity.z)
 var along := motion.normalized() if motion.length()>.2 else Vector2.RIGHT
 for i in 3: add_flight327(paper_clamp301(base+along*float(i)*1.1),float(i)*1.15,1.65,source,false)

func tick_flights327(delta: float) -> void:
 for i in range(flights327.size()-1,-1,-1):
  var flight := flights327[i]
  flight.age += delta
  if flight.age<0.:
   if not flight.meteor and cannon_hp326[flight.source]<=0.: remove_flight327(i)
   continue
  if not flight.sprite.visible:
   if not flight.meteor and cannon_hp326[flight.source]<=0.:
    remove_flight327(i)
    continue
   flight.sprite.show()
   if not flight.meteor:theatre314.recoil_cannon326(flight.source)
   if not flight.meteor: Audio.play("crack",.6)
  var t := clampf(float(flight.age)/float(flight.duration),0.,1.)
  flight.sprite.global_position = theatre314.flight_position330(flight,t)
  if flight.meteor: flight.sprite.rotation.z = -.4
  else:
   theatre314.pose_mortar330(flight,t)
   theatre314.paint_ring327(flight.marker,flight.at,1.6,.2+t*.35)
  if t>=1.:
   var visual: Dictionary = theatre314.make_blast327(flight.at,4.4 if flight.meteor else 3.2)
   blasts327.append({"at":flight.at,"age":0.,"hit":false,"radius":2.2 if flight.meteor else 1.6,"meteor":flight.meteor,"visual":visual})
   impact_feedback328(flight.at,flight.meteor)
   remove_flight327(i)

func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(theatre314): return
 var phase: String = "城堡倒下了" if fall314>=0. else PHASES330[attack330]
 guide206.text = "330 城防弹幕 · 城堡 %.1f / %.0f\n%s · 已弹回 %d\nF7 重开 · F4 瞄准" % [fastener_hp321,CASTLE_HP327,phase,reflected330]
 if is_instance_valid(phase_label326): phase_label326.text = phase

func add_flight327(at: Vector2, delay: float, duration: float, source: int, meteor: bool) -> void:
 super.add_flight327(at,delay,duration,source,meteor)
 if not meteor:
  flights327.back().from = theatre314.muzzle330(source)
  flights327.back().sprite.global_position = flights327.back().from
