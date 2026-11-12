extends "res://scripts/world/woodland_world330.gd"

const PHASES331 := ["重纸弹 · 右键瞬按弹回","防空连射 · 沿箭头扫过","交替散射","三连迫击炮","斜向流星排"]
const TIMES331 := [6.8,8.,5.2,6.6,8.4]
const REPAIR331 := 7.
var phase331 := 0
var sweep331: Dictionary = {}
var sweep_side331 := 1.
var repair_left331: Array[float] = [0.,0.]
var disabled_once331: Array[bool] = [false,false]
var finale_cannons331 := false

func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 331 · 防空扫射 / 炮台压制")

func stage_script314() -> Script:
 return preload("res://scripts/art/paper_stage331.gd")

func _ready() -> void:
 await super._ready()
 hint288.text = "331 防空扫射 / 炮台压制\n看箭头躲扫射 · 炮台打瘫停火7秒"

func restart301() -> void:
 phase331 = 0
 sweep331.clear()
 sweep_side331 = 1.
 repair_left331 = [0.,0.]
 disabled_once331 = [false,false]
 finale_cannons331 = false
 super.restart301()

func boss_step314(delta: float) -> void:
 if not waiting_intro314 and active114 and fastener_hp321>0.: tick_repairs331(delta)
 super.boss_step314(delta)

func tick_pattern327(delta: float) -> void:
 pattern_left327 -= delta
 volley_left327 -= delta
 tick_sweep331(delta)
 if pattern_left327<=0.:
  if not heavies330.is_empty() or not sweep331.is_empty(): return
  phase331 = (phase331+1)%PHASES331.size()
  attack330 = [0,1,1,2,3][phase331]
  pattern327 = [0,0,0,1,2][phase331]
  pattern_left327 = TIMES331[phase331]
  pattern_started327 = false
  volley_left327 = .85
 var source := live_device327()
 if source<0: return
 theatre314.aim_cannon326(source,volley_left327<.55)
 if volley_left327>0.: return
 if phase331==2:
  scatter327(source)
  cannon_index326 = 1-source
  volley_left327 = 1.65
 elif not pattern_started327:
  pattern_started327 = true
  match phase331:
   0: charge_heavy330(source)
   1: start_sweep331(source)
   3: mortar327(source)
   4: meteor_row327(source)

func start_sweep331(source: int) -> void:
 var at: Vector3 = theatre314.muzzle330(source)
 var target: Vector3 = hero.global_position
 var aim := Vector2(target.x-at.x,target.z-at.z).normalized()
 sweep331 = {"source":source,"at":at,"aim":aim,"side":sweep_side331,"age":-.8,"next":0.,"fired":0}
 sweep_side331 *= -1.
 cannon_index326 = 1-source
 theatre314.sweep_cue331(sweep331)

func tick_sweep331(delta: float) -> void:
 if sweep331.is_empty(): return
 var source: int = sweep331.source
 if cannon_hp326[source]<=0.:
  cancel_sweep331()
  return
 sweep331.age += delta
 # Fixed aim and angular order, never retarget the player mid-burst.
 while sweep331.fired<24 and sweep331.age>=sweep331.next:
  var angle := lerpf(-.48,.48,float(sweep331.fired)/23.)*float(sweep331.side)
  var direction: Vector2 = Vector2(sweep331.aim).rotated(angle)
  var at: Vector3 = theatre314.muzzle330(source)
  var sprite: Sprite3D = theatre314.shell331(at,direction)
  cannon_shots326.append({"sprite":sprite,"at":at,"direction":direction,"life":2.6,"speed":6.,"source":source,"aa331":true,"height":at.y-floor_height(Vector2(at.x,at.z))})
  theatre314.recoil_cannon326(source)
  Audio.play("crack",.30)
  sweep331.fired += 1
  sweep331.next += .16
 theatre314.sweep_cue331(sweep331)
 if sweep331.fired>=24: cancel_sweep331()

func cancel_sweep331() -> void:
 sweep331.clear()
 if is_instance_valid(theatre314): theatre314.sweep_cue331({})

func hurt_cannon326(index: int, damage: float) -> void:
 if cannon_hp326[index]<=0. or not active114: return
 cannon_hp326[index] = maxf(0.,cannon_hp326[index]-maxf(0.,damage))
 theatre314.recoil_cannon326(index)
 if cannon_hp326[index]>0.:
  structure_contact326(theatre314.cannon_areas326[index].global_position,Vector3.BACK)
  return
 repair_left331[index] = REPAIR331
 theatre314.break_cannon326(index)
 interrupt327(index)
 volley_left327 = maxf(volley_left327,1.4)
 if not disabled_once331[index]:
  disabled_once331[index] = true
  damage_fastener321({"fixed_damage110":3.,"velocity":Vector3.BACK},theatre314.cannon_areas326[index].global_position)

func tick_repairs331(delta: float) -> void:
 for i in repair_left331.size():
  if repair_left331[i]<=0.: continue
  repair_left331[i] = maxf(0.,repair_left331[i]-delta)
  if repair_left331[i]==0.:
   cannon_hp326[i] = DEVICE_HP327
   theatre314.repair_pose331(i,true)
   theatre314.cannon_areas326[i].set_deferred("collision_layer",8)
   volley_left327 = maxf(volley_left327,.9)

func interrupt327(source := -1) -> void:
 super.interrupt327(source)
 if not sweep331.is_empty() and (source<0 or sweep331.source==source): cancel_sweep331()

func clear_patterns327() -> void:
 cancel_sweep331()
 super.clear_patterns327()

func tick_cannon_shots326(delta: float) -> void:
 for i in range(cannon_shots326.size()-1,-1,-1):
  var shot := cannon_shots326[i]
  var from: Vector3 = cannon_start338(shot.at,float(shot.get("height",.7)))
  var heading: Vector2 = shot.direction
  var to := from+Vector3(heading.x,0.,heading.y)*delta*float(shot.get("speed",6.5))
  to.y = cannon_height338(Vector2(to.x,to.z),float(shot.get("height",.7)))
  var feet := Vector2(hero.global_position.x,hero.global_position.z)
  var contact: float = aim_model.sweep_circle(Vector2(from.x,from.z),Vector2(to.x,to.z),feet,.42 if shot.get("aa331",false) else .55)
  var excluded: Array[RID] = []
  if shot.has("source"):
   var own: Node3D = theatre314.scenery_shapes322[theatre314.cannons326[shot.source]].get_parent()
   if own is CollisionObject3D: excluded.append(own.get_rid())
  var hit := get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from,to,1|2,excluded))
  var blocked := not hit.is_empty()
  var defended := not blocked and shell_defense326(from,to)
  shot.life -= delta
  if defended: shot.life = 0.
  if contact<=1. and not defended and not blocked and absf(hero.global_position.y-floor_height(feet))<.85:
   if hero.can_parry(): parry_success(hero.global_position+Vector3.UP*.7,-Vector3(heading.x,0.,heading.y))
   else: hurt_player(1.,Vector2(from.x,from.z))
   shot.life = 0.
  if blocked or shot.life<=0.:
   shot.sprite.queue_free()
   cannon_shots326.remove_at(i)
  else:
   shot.at = to
   shot.sprite.global_position = to
   if shot.get("aa331",false): theatre314.orient_shell331(shot.sprite,to,heading)
   else: shot.sprite.rotation.z += delta*5.

func finish251(victory: bool) -> void:
 finale_cannons331 = victory
 repair_left331 = [0.,0.]
 super.finish251(victory)
 if victory: cannon_hp326 = [0.,0.]

func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(theatre314): return
 var phase: String = "城堡与炮台倒下了" if fall314>=0. else PHASES331[phase331]
 var status: Array[String] = []
 for i in 2:
  status.append(("左" if i==0 else "右")+("炮 %.1f秒恢复" % repair_left331[i] if repair_left331[i]>0. else "炮可压制"))
 guide206.text = "331 城防弹幕 · 城堡 %.1f / %.0f\n%s\n%s · %s\nF7 重开 · F4 瞄准" % [fastener_hp321,CASTLE_HP327,phase,status[0],status[1]]
 if is_instance_valid(phase_label326): phase_label326.text = phase
