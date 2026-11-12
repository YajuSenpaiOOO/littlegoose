extends "res://scripts/world/woodland_world331.gd"

var last_heavy332 := ""
var landing_rings332: Array[Node3D] = []

func _hero_script() -> Script:
 return preload("res://scripts/combat/hero332.gd")

func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 332 · 纸屑往返扫射 / 爆破击退")

func stage_script314() -> Script:
 return preload("res://scripts/art/paper_stage332.gd")

func _ready() -> void:
 await super._ready()
 hint288.text = "332 纸屑往返扫射 / 爆破击退\n固定扇区来回摆 · 重攻击短促炸起"

func restart301() -> void:
 clear_landing332()
 last_heavy332 = ""
 super.restart301()

func start_sweep331(source: int) -> void:
 var at: Vector3 = theatre314.muzzle330(source)
 # World-space arena landmark, never the player's position or velocity.
 var fixed: Vector3 = theatre314.to_global(Vector3(0.,0.,6.5))
 var aim := Vector2(fixed.x-at.x,fixed.z-at.z).normalized()
 sweep331 = {"source":source,"at":at,"aim":aim,"side":sweep_side331,"age":-.8,"next":0.,"fired":0}
 sweep_side331 *= -1.
 cannon_index326 = 1-source
 theatre314.sweep_cue331(sweep331)

func sweep_fraction332(index: int) -> float:
 return float(index if index<=12 else 24-index)/12.

func tick_sweep331(delta: float) -> void:
 if sweep331.is_empty(): return
 var source: int = sweep331.source
 if cannon_hp326[source]<=0.:
  cancel_sweep331()
  return
 sweep331.age += delta
 while sweep331.fired<25 and sweep331.age>=sweep331.next:
  var angle := lerpf(-.48,.48,sweep_fraction332(sweep331.fired))*float(sweep331.side)
  var heading: Vector2 = Vector2(sweep331.aim).rotated(angle)
  var at: Vector3 = theatre314.muzzle330(source)
  var sprite: Sprite3D = theatre314.shell331(at,heading)
  cannon_shots326.append({"sprite":sprite,"at":at,"direction":heading,"life":2.6,"speed":6.,"source":source,"aa331":true,"height":at.y-floor_height(Vector2(at.x,at.z))})
  theatre314.recoil_cannon326(source)
  Audio.play("crack",.30)
  sweep331.fired += 1
  sweep331.next += .16
 if sweep331.fired>=25: cancel_sweep331()
 else: theatre314.sweep_cue331(sweep331)

func hazard_hurt332(damage: float, from: Vector2, kind: String) -> void:
 var hp := player_hp
 var guarded: bool = hero.guarding109
 super.hazard_hurt332(damage,from,kind)
 if player_hp>=hp or player_hp<=0.: return
 last_heavy332 = kind
 var feet := Vector2(hero.global_position.x,hero.global_position.z)
 var direction := (feet-from).normalized()
 if direction==Vector2.ZERO: direction = Vector2.DOWN
 if guarded:
  hero.combat_impulse = direction*3.
  hitstop(.045,true)
  punch = maxf(punch,.4)
  return
 var lift: float = {"heavy":4.8,"mortar":4.5,"meteor":5.6}.get(kind,4.5)
 var push: float = {"heavy":7.,"mortar":6.,"meteor":8.}.get(kind,6.)
 hero.combat_impulse = direction*push
 hero.locomotion = Vector2.ZERO
 hero.pending_lift332 = lift
 hero.blast_air332 = true
 hero.blast_tilt332 = -.16 if direction.x<0. else .16
 invulnerability = maxf(invulnerability,1.1)
 hitstop(.09 if kind=="meteor" else .065,true)
 punch = maxf(punch,.85 if kind=="meteor" else .65)
 trauma = maxf(trauma,.35)
 shake_duration328 = .20
 shake_left328 = .20
 shake_amp328 = .10 if kind=="meteor" else .07

func hero_landed332() -> void:
 if not active114 or player_hp<=0.: return
 var at := Vector2(hero.global_position.x,hero.global_position.z)
 var ring: MeshInstance3D = theatre314.make_ring327()
 landing_rings332 = landing_rings332.filter(func(node): return is_instance_valid(node))
 landing_rings332.append(ring)
 var stage: Node3D = theatre314
 var tween := ring.create_tween()
 tween.tween_method(func(t: float): stage.paint_ring327(ring,at,lerpf(.3,.7,t),.3*(1.-t)),0.,1.,.2)
 tween.tween_callback(ring.queue_free)
 punch = maxf(punch,.14)
 Audio.play("hit",.3)

func clear_landing332() -> void:
 for ring in landing_rings332:
  if is_instance_valid(ring): ring.queue_free()
 landing_rings332.clear()
 if is_instance_valid(hero) and hero.get("pending_lift332")!=null:
  hero.pending_lift332 = 0.
  hero.blast_air332 = false
  hero.landing_left332 = 0.

func finish251(victory: bool) -> void:
 clear_landing332()
 super.finish251(victory)

func _process(delta: float) -> void:
 super._process(delta)
 if is_instance_valid(theatre314):
  guide206.text = guide206.text.replace("331 城防弹幕","332 城防弹幕").replace("沿箭头扫过","固定扇区往返")
  if phase331==1 and is_instance_valid(phase_label326): phase_label326.text = "纸屑连射 · 固定扇区往返"
