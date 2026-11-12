extends "res://scripts/world/woodland_world333.gd"

const CASTLE334 := 144.
const CANNON334 := 16.
var rebuild_index334 := -1
var rebuild_age334 := 0.
var rebuild_queue334: Array[int] = []
var salvo334 := 0
var paper_queue334: Array[Dictionary] = []

func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 334 · 炮台折纸重建 / 交错纸幕")

func stage_script314() -> Script:
 return preload("res://scripts/art/paper_stage334.gd")

func _ready() -> void:
 await super._ready()
 hint288.text = "334 炮台折纸重建 / 交错纸幕\n炮台16 · 城堡144 · 回收后重新折纸"

func restart301() -> void:
 rebuild_index334 = -1
 rebuild_age334 = 0.
 rebuild_queue334.clear()
 paper_queue334.clear()
 salvo334 = 0
 if is_instance_valid(theatre314): theatre314.clear_rebuild334()
 super.restart301()
 fastener_hp321 = CASTLE334
 cannon_hp326 = [CANNON334,CANNON334]

func hurt_cannon326(index: int, damage: float) -> void:
 var was_alive := cannon_hp326[index]>0.
 super.hurt_cannon326(index,damage)
 if was_alive and cannon_hp326[index]<=0.:
  rebuild_queue334.append(index)
  repair_left331[index] = 7.*rebuild_queue334.size()+maxf(0.,7.-rebuild_age334) if rebuild_index334>=0 else 7.*rebuild_queue334.size()

func tick_repairs331(delta: float) -> void:
 if entry_clock314>=0.: return
 if rebuild_index334<0 and not rebuild_queue334.is_empty():
  rebuild_index334 = rebuild_queue334.pop_front()
  rebuild_age334 = 0.
 if rebuild_index334<0: return
 rebuild_age334 = minf(7.,rebuild_age334+delta)
 repair_left331[rebuild_index334] = maxf(.01,7.-rebuild_age334)
 for i in rebuild_queue334.size(): repair_left331[rebuild_queue334[i]] = 7.-rebuild_age334+7.*(i+1)
 if rebuild_age334>=7.:
  var index := rebuild_index334
  theatre314.clear_rebuild334()
  theatre314.repair_pose331(index,true)
  cannon_hp326[index] = CANNON334
  repair_left331[index] = 0.
  theatre314.cannon_areas326[index].set_deferred("collision_layer",8)
  theatre314.sync_scenery322()
  volley_left327 = maxf(volley_left327,.8)
  rebuild_index334 = -1

func boss_step314(delta: float) -> void:
 if rebuild_index334>=0 or not rebuild_queue334.is_empty(): cameo_left327 = maxf(cameo_left327,.3)
 tick_paper_queue334(delta)
 super.boss_step314(delta)
 # More ordinary fire, leaving special windups and flight times intact.
 if phase331==2: volley_left327 = minf(volley_left327,.75)

func scatter327(source: int) -> void:
 var mode := salvo334%3
 salvo334 += 1
 if mode==0:
  super.scatter327(source)
  return
 var at: Vector3 = theatre314.muzzle330(source)
 var aim := Vector2(hero.global_position.x-at.x,hero.global_position.z-at.z).normalized()
 if mode==1:
  for i in 3: paper_queue334.append({"source":source,"aim":aim,"delay":float(i)*.12})
 else:
  for gun in [source,1-source]:
   if cannon_hp326[gun]<=0.: continue
   var origin: Vector3 = theatre314.muzzle330(gun)
   var direction := Vector2(hero.global_position.x-origin.x,hero.global_position.z-origin.z).normalized()
   for i in 4:
    paper_queue334.append({"source":gun,"aim":direction.rotated((float(i)-1.5)*.26+(0. if gun==source else .13)),"delay":0. if gun==source else .30})

func tick_paper_queue334(delta: float) -> void:
 for i in range(paper_queue334.size()-1,-1,-1):
  var shot := paper_queue334[i]
  shot.delay -= delta
  if shot.delay>0.: continue
  if cannon_hp326[shot.source]>0.:
   var at: Vector3 = theatre314.muzzle330(shot.source)
   var sprite: Sprite3D = theatre314.make_shell326(at)
   cannon_shots326.append({"sprite":sprite,"at":at,"direction":shot.aim,"life":2.6,"speed":5.2,"source":shot.source,"height":at.y-floor_height(Vector2(at.x,at.z))})
   theatre314.recoil_cannon326(shot.source)
   Audio.play("crack",.3)
  paper_queue334.remove_at(i)

func interrupt327(source := -1) -> void:
 super.interrupt327(source)
 paper_queue334 = paper_queue334.filter(func(shot): return source>=0 and shot.source!=source)

func clear_patterns327() -> void:
 paper_queue334.clear()
 super.clear_patterns327()

func finish251(victory: bool) -> void:
 rebuild_index334 = -1
 rebuild_queue334.clear()
 if is_instance_valid(theatre314): theatre314.clear_rebuild334()
 super.finish251(victory)

func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(theatre314): return
 guide206.text = guide206.text.replace("333 城防弹幕","334 城防弹幕").replace("/ 72","/ 144")
 if is_instance_valid(boss_bar326): boss_bar326.value = fastener_hp321/CASTLE334*100.
