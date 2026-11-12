extends "res://scripts/world/woodland_world335.gd"
var phase_rng336:=RandomNumberGenerator.new()
var heavy_bag336: Array[int]=[]
var last_heavy_phase336:=0
var last_normal_phase336:=1
var attack_sources336: Array[int]=[0,0]

func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 336 · 逐发迫击 / 双炮调度")
func _ready() -> void:
 await super._ready()
 hint288.text="336 逐发迫击 / 双炮调度\n每发出膛锁点 · 普通纸幕与重招交替"
func restart301() -> void:
 phase_rng336.randomize()
 heavy_bag336=[3,4]
 last_heavy_phase336=0
 last_normal_phase336=1
 attack_sources336=[0,0]
 super.restart301()
func next_phase336() -> int:
 if phase331 in [0,3,4]:
  last_normal_phase336=2 if last_normal_phase336==1 else 1
  return last_normal_phase336
 if heavy_bag336.is_empty():
  heavy_bag336=[0,3,4]
 var candidates: Array[int]=[]
 for phase in heavy_bag336:
  if phase!=last_heavy_phase336: candidates.append(phase)
 if candidates.is_empty(): candidates=heavy_bag336.duplicate()
 var chosen: int=candidates[phase_rng336.randi_range(0,candidates.size()-1)]
 heavy_bag336.erase(chosen)
 last_heavy_phase336=chosen
 return chosen
func record_source336(source: int) -> void:
 attack_sources336[source]+=1
 cannon_index326=1-source
func tick_pattern327(delta: float) -> void:
 pattern_left327-=delta
 volley_left327-=delta
 tick_sweep331(delta)
 if pattern_left327<=0.:
  if not heavies330.is_empty() or not sweep331.is_empty(): return
  phase331=next_phase336()
  attack330=[0,1,1,2,3][phase331]
  pattern327=[0,0,0,1,2][phase331]
  pattern_left327=TIMES333[phase331]
  pattern_started327=false
  volley_left327=.45
 var source:=live_device327()
 if source<0: return
 theatre314.aim_cannon326(source,volley_left327<.55)
 if volley_left327>0.: return
 if phase331==2:
  scatter327(source)
  record_source336(source)
  volley_left327=.75
 elif not pattern_started327:
  pattern_started327=true
  match phase331:
   0:
    charge_heavy330(source)
    record_source336(source)
   1:
    start_sweep331(source)
    record_source336(source)
   3: mortar327(source)
   4:
    meteor_row327(source)
    record_source336(source)
func mortar327(source: int) -> void:
 cannon_index326=source
 for i in 3:
  var gun:=live_device327()
  if gun<0: return
  # Placeholder only; neither marker nor projectile is visible before launch.
  add_flight327(Vector2(hero.global_position.x,hero.global_position.z),float(i)*.85,1.65,gun,false)
  cannon_index326=1-gun
func tick_flights327(delta: float) -> void:
 for flight in flights327:
  if flight.meteor or flight.sprite.visible or float(flight.age)+delta<0. or cannon_hp326[flight.source]<=0.: continue
  var at:=paper_clamp301(Vector2(hero.global_position.x,hero.global_position.z))
  flight.at=at
  flight.ground=Vector3(at.x,floor_height(at)+.08,at.y)
  flight.from=theatre314.muzzle330(flight.source)
  flight.locked336=true
  attack_sources336[flight.source]+=1
 super.tick_flights327(delta)
func _process(delta: float) -> void:
 super._process(delta)
 if is_instance_valid(theatre314):
  guide206.text=guide206.text.replace("335 城防弹幕","336 城防弹幕")
  guide206.text+="\n出招轮次 左%d / 右%d" % [attack_sources336[0],attack_sources336[1]]
