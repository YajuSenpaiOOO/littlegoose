extends "res://scripts/world/woodland_world332.gd"

const TIMES333 := [4.8,6.6,4.1,4.9,7.]

func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 333 · 落地冲击 / 紧凑城防")

func _ready() -> void:
 await super._ready()
 hint288.text = "333 落地冲击 / 紧凑城防\n爆炸落地瞬间判定 · 残留特效无伤害"

func restart301() -> void:
 super.restart301()
 pattern_left327 = TIMES333[0]
 volley_left327 = .45

func tick_pattern327(delta: float) -> void:
 pattern_left327 -= delta
 volley_left327 -= delta
 tick_sweep331(delta)
 if pattern_left327<=0.:
  if not heavies330.is_empty() or not sweep331.is_empty(): return
  phase331 = (phase331+1)%PHASES331.size()
  attack330 = [0,1,1,2,3][phase331]
  pattern327 = [0,0,0,1,2][phase331]
  pattern_left327 = TIMES333[phase331]
  pattern_started327 = false
  volley_left327 = .45
 var source := live_device327()
 if source<0: return
 theatre314.aim_cannon326(source,volley_left327<.55)
 if volley_left327>0.: return
 if phase331==2:
  scatter327(source)
  cannon_index326 = 1-source
  volley_left327 = 1.25
 elif not pattern_started327:
  pattern_started327 = true
  match phase331:
   0: charge_heavy330(source)
   1: start_sweep331(source)
   3: mortar327(source)
   4: meteor_row327(source)

func mortar327(source: int) -> void:
 var base := paper_clamp301(Vector2(hero.global_position.x,hero.global_position.z))
 var motion := Vector2(hero.velocity.x,hero.velocity.z)
 var along := motion.normalized() if motion.length()>.2 else Vector2.RIGHT
 for i in 3: add_flight327(paper_clamp301(base+along*float(i)*1.1),float(i)*.85,1.65,source,false)

func meteor_row327(source: int) -> void:
 var base := paper_clamp301(Vector2(hero.global_position.x,hero.global_position.z))
 for i in 4:
  add_flight327(paper_clamp301(base+Vector2(1.65,.5)*(float(i)-1.5)),float(i)*1.45,1.4,source,true)

func resolve_impact333(blast: Dictionary) -> void:
 if blast.get("resolved333",false): return
 blast.resolved333 = true
 blast.hit = true
 # A landing is one instantaneous event, regardless of the lifetime of its art.
 if float(blast.age)>0.: return
 var feet := Vector2(hero.global_position.x,hero.global_position.z)
 if feet.distance_to(blast.at)<=float(blast.radius) and absf(hero.global_position.y-floor_height(feet))<.85:
  if not perfect_hazard328():
   hazard_hurt332(1.5,blast.at,"meteor" if blast.get("meteor",false) else "mortar")

func tick_flights327(delta: float) -> void:
 super.tick_flights327(delta)
 for blast in blasts327: resolve_impact333(blast)

func tick_blasts327(delta: float) -> void:
 for i in range(blasts327.size()-1,-1,-1):
  var blast := blasts327[i]
  resolve_impact333(blast)
  blast.age += delta
  var t := clampf(float(blast.age)/.45,0.,1.)
  theatre314.paint_ring327(blast.visual.ring,blast.at,lerpf(.35,float(blast.radius),t),maxf(0.,1.-float(blast.age)/.7))
  blast.visual.boom.scale = Vector3.ONE*lerpf(.65,1.,smoothstep(0.,.12,blast.age))
  blast.visual.boom.transparency = smoothstep(.4,.7,blast.age)
  if blast.age>=.7:
   blast.visual.root.queue_free()
   blasts327.remove_at(i)

func _process(delta: float) -> void:
 super._process(delta)
 if is_instance_valid(theatre314): guide206.text = guide206.text.replace("332 城防弹幕","333 城防弹幕")
