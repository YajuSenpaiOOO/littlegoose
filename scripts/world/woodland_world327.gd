extends "res://scripts/world/woodland_world326.gd"

const CASTLE_HP327 := 72.
const DEVICE_HP327 := 5.
const PATTERNS327 := ["交替散射", "三连迫击炮", "斜向流星排"]
var paper_hits329: Array[Node3D] = []
var paper_at329 := Vector3.INF
var paper_time329 := -1
var pattern327 := 0
const PATTERN_TIMES328 := [5.2, 5.8, 8.4]
var pattern_left327 := 5.2
var volley_left327 := .65
var pattern_started327 := false
var cameo_left327 := 7.
var flights327: Array[Dictionary] = []
var blasts327: Array[Dictionary] = []
var impact_sounds328: Dictionary = {}
var impact_voices328: Array[AudioStreamPlayer] = []
var impact_voice328 := 0
var last_impact328 := ""
var shake_left328 := 0.
var shake_duration328 := .24
var shake_amp328 := 0.

func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 329 · 城防弹幕纸剧场")

func stage_script314() -> Script:
 return preload("res://scripts/art/paper_stage327.gd")

func _ready() -> void:
 await super._ready()
 for key in ["mortar","meteor"]:
  impact_sounds328[key] = load("res://assets/paper_stage328/" + key + ".wav")
 for i in 4:
  var voice := AudioStreamPlayer.new()
  voice.volume_db = -7.
  add_child(voice)
  impact_voices328.append(voice)
 hint288.text = "329 城防弹幕纸剧场\n城堡随时可打 · 打坏炮台中断弹幕"

func restart301() -> void:
 clear_paper329()
 clear_patterns327()
 for voice in impact_voices328: voice.stop()
 last_impact328 = ""
 shake_left328 = 0.
 shake_amp328 = 0.
 pattern327 = 0
 pattern_left327 = PATTERN_TIMES328[0]
 volley_left327 = .65
 pattern_started327 = false
 cameo_left327 = 7.
 super.restart301()
 fastener_hp321 = CASTLE_HP327
 cannon_hp326 = [DEVICE_HP327, DEVICE_HP327]

func card_type301(index: int) -> String:
 return ["knight", "dinosaur", "monster"][index % 3]

func boss_step314(delta: float) -> void:
 impact_slot326 = maxf(0., impact_slot326 - delta)
 if waiting_intro314:
  if not theatre314.finished:
   return
  waiting_intro314 = false
  core_phase326 = true
  panel_open321 = true
  theatre314.set_panel321(1)
  theatre314.enable_cannons326(true)
  theatre314.enable_castle327(true)
  grid111.call_deferred("invalidate")
  return
 tick_pattern327(delta)
 tick_cannon_shots326(delta)
 tick_flights327(delta)
 tick_blasts327(delta)
 if entry_clock314 >= 0.:
  entry_clock314 = maxf(0., entry_clock314 - delta * SUMMON_RATE326)
  theatre314.sample_summon317(theatre314.SUMMON_END317 - entry_clock314)
  if entry_clock314 == 0.:
   theatre314.finish_summon317()
   entry_clock314 = -1.
 else:
  cameo_left327 -= delta
  var quiet := flights327.is_empty() and blasts327.is_empty() and cannon_shots326.is_empty() and pattern_left327 < 1.2
  if cameo_left327 <= 0. and live301().is_empty() and quiet:
   spawn314()
   var card: CharacterBody3D = theatre314.summon_card317
   card.max_hp110 = 8.
   card.hp = 8.
   theatre314.fold_clock314 = -1.
   cameo_left327 = 11.

func enemy_defeated(actor: CharacterBody3D) -> void:
 if not ready301 or not cards301.has(actor):
  super.enemy_defeated(actor)
  return
 if actor.get_meta("counted301", false):
  return
 actor.set_meta("counted301", true)
 enemies.erase(actor)
 defeated301 += 1
 defeated_count = defeated301
 if target114 == actor:
  target114 = null
 aim_tick114 = -1
 volley_left327 = maxf(volley_left327, 1.4)
 interrupt327()
 theatre314.reaction313(5)
 damage_fastener321({"fixed_damage110":2., "velocity":Vector3.BACK}, theatre314.panel321.global_position)

func cursor_fastener321(cursor: Vector2) -> Vector3:
 if not core_phase326 or not active114:
  return Vector3.INF
 var origin := camera.project_ray_origin(cursor)
 var ray := camera.project_ray_normal(cursor)
 var query := PhysicsRayQueryParameters3D.create(origin, origin + ray * 250., 2 | 8, [hero.get_rid()])
 query.collide_with_areas = true
 var hit := get_world_3d().direct_space_state.intersect_ray(query)
 if hit.is_empty():
  return Vector3.INF
 var castle_body: Node = theatre314.bodies[0].get_parent()
 if hit.collider == castle_body or hit.collider == theatre314.castle_target327 or hit.collider == theatre314.fastener321:
  return hit.position + ray * .04
 if hit.collider is Area3D and theatre314.cannon_areas326.has(hit.collider):
  return hit.position + ray * .04
 return Vector3.INF

func _apply_shot_hit(shot: Dictionary, hit: Dictionary) -> void:
 if active114 and not waiting_intro314 and is_instance_valid(theatre314):
  if hit.collider == theatre314.bodies[0].get_parent() or hit.collider == theatre314.castle_target327:
   damage_fastener321(shot, hit.position)
   return
 super._apply_shot_hit(shot, hit)

func castle_blast_point314(mark: Vector3) -> Vector3:
 var wall: Vector3 = theatre314.bodies[0].global_position
 return Vector3(clampf(mark.x,wall.x-5.1,wall.x+5.1),wall.y+.25,wall.z+.32)

func structure_contact326(at: Vector3, normal: Vector3, broken := false) -> void:
 var now := Time.get_ticks_msec()
 if now-paper_time329 < 50 and paper_at329.distance_squared_to(at) < .16:
  return
 paper_time329 = now
 paper_at329 = at
 paper_hits329 = paper_hits329.filter(func(effect): return is_instance_valid(effect))
 if paper_hits329.size() >= 12:
  var oldest: Node3D = paper_hits329.pop_front()
  oldest.queue_free()
 paper_hits329.append(preload("res://scripts/art/paper_hit329.gd").spawn(self,at,normal,broken))

func clear_paper329() -> void:
 for effect in paper_hits329:
  if is_instance_valid(effect): effect.queue_free()
 paper_hits329.clear()
 paper_time329 = -1
 paper_at329 = Vector3.INF

func hurt_cannon326(index: int, damage: float) -> void:
 if cannon_hp326[index] <= 0. or not active114:
  return
 cannon_hp326[index] = maxf(0., cannon_hp326[index] - damage)
 theatre314.recoil_cannon326(index)
 if cannon_hp326[index] > 0.:
  structure_contact326(theatre314.cannon_areas326[index].global_position,Vector3.BACK)
 if cannon_hp326[index] == 0.:
  theatre314.break_cannon326(index)
  volley_left327 = maxf(volley_left327, 1.4)
  interrupt327(index)
  damage_fastener321({"fixed_damage110":8., "velocity":Vector3.BACK}, theatre314.cannon_areas326[index].global_position)

func live_device327() -> int:
 if cannon_hp326[cannon_index326] > 0.:
  return cannon_index326
 return 1 - cannon_index326 if cannon_hp326[1 - cannon_index326] > 0. else -1

func tick_pattern327(delta: float) -> void:
 pattern_left327 -= delta
 volley_left327 -= delta
 if pattern_left327 <= 0.:
  pattern327 = (pattern327 + 1) % PATTERNS327.size()
  pattern_left327 = PATTERN_TIMES328[pattern327]
  pattern_started327 = false
  volley_left327 = .85
 var source := live_device327()
 if source < 0:
  return
 theatre314.aim_cannon326(source, volley_left327 < .55)
 if volley_left327 > 0.:
  return
 if pattern327 == 0:
  scatter327(source)
  cannon_index326 = 1 - source
  volley_left327 = 1.65
 elif not pattern_started327:
  pattern_started327 = true
  if pattern327 == 1:
   mortar327(source)
  else:
   meteor_row327(source)

func scatter327(source: int) -> void:
 var from: Vector3 = theatre314.cannon_areas326[source].global_position + Vector3.UP * .25
 var target: Vector3 = hero.global_position + hero.velocity.limit_length(4.) * .15
 var aim := Vector2(target.x-from.x, target.z-from.z).normalized()
 for i in 5:
  var direction := aim.rotated((i - 2) * .22)
  var sprite: Sprite3D = theatre314.make_shell326(from)
  cannon_shots326.append({"sprite":sprite, "at":from, "direction":direction, "life":2.6,"speed":4.8,"source":source})
 theatre314.recoil_cannon326(source)
 Audio.play("crack", .65)

func mortar327(source: int) -> void:
 var base: Vector2 = paper_clamp301(Vector2(hero.global_position.x, hero.global_position.z))
 var motion := Vector2(hero.velocity.x, hero.velocity.z)
 var along := motion.normalized() if motion.length() > .2 else Vector2.RIGHT
 for i in 3:
  add_flight327(paper_clamp301(base + along * float(i) * 1.1), float(i) * .95, 1.15, source, false)

func meteor_row327(source: int) -> void:
 var base := paper_clamp301(Vector2(hero.global_position.x, hero.global_position.z))
 for i in 4:
  var across := Vector2(1.65, .5) * (float(i) - 1.5)
  add_flight327(paper_clamp301(base + across), float(i) * 1.55, 1.4, source, true)

func add_flight327(at: Vector2, delay: float, duration: float, source: int, meteor: bool) -> void:
 var ground := Vector3(at.x, floor_height(at) + .08, at.y)
 var from: Vector3 = ground + Vector3(6.,7.,0.) if meteor else theatre314.cannon_areas326[source].global_position + Vector3.UP * .3
 var sprite: Sprite3D = theatre314.make_flight327(from, meteor)
 sprite.hide()
 var marker: MeshInstance3D = theatre314.make_ring327()
 flights327.append({"at":at, "from":from, "ground":ground, "age":-delay, "duration":duration, "source":source, "meteor":meteor, "sprite":sprite, "marker":marker})

func tick_flights327(delta: float) -> void:
 for i in range(flights327.size()-1,-1,-1):
  var flight := flights327[i]
  flight.age += delta
  if flight.age < 0.:
   if cannon_hp326[flight.source] <= 0.:
    remove_flight327(i)
   continue
  if not flight.sprite.visible:
   if cannon_hp326[flight.source] <= 0.:
    remove_flight327(i)
    continue
   flight.sprite.show()
   theatre314.recoil_cannon326(flight.source)
  var t := clampf(float(flight.age) / float(flight.duration), 0., 1.)
  var at: Vector3 = Vector3(flight.from).lerp(flight.ground,t)
  if not flight.meteor:
   at.y += sin(PI*t) * 3.2
   theatre314.paint_ring327(flight.marker,flight.at,1.6,.2 + t*.35)
  flight.sprite.global_position = at
  flight.sprite.rotation.z = -.4 if flight.meteor else t * TAU
  if t >= 1.:
   var visual: Dictionary = theatre314.make_blast327(flight.at, 4.4 if flight.meteor else 3.2)
   blasts327.append({"at":flight.at, "age":0., "hit":false, "radius":2.2 if flight.meteor else 1.6, "meteor":flight.meteor, "visual":visual})
   impact_feedback328(flight.at,flight.meteor)
   remove_flight327(i)

func remove_flight327(index: int) -> void:
 flights327[index].sprite.queue_free()
 flights327[index].marker.queue_free()
 flights327.remove_at(index)

func tick_blasts327(delta: float) -> void:
 for i in range(blasts327.size()-1,-1,-1):
  var blast := blasts327[i]
  blast.age += delta
  var t := clampf(float(blast.age) / .45, 0., 1.)
  var radius := lerpf(.35, float(blast.radius), t)
  theatre314.paint_ring327(blast.visual.ring,blast.at,radius,maxf(0.,1.-float(blast.age)/.7))
  blast.visual.boom.scale = Vector3.ONE * lerpf(.65,1.,smoothstep(0.,.12,blast.age))
  blast.visual.boom.transparency = smoothstep(.4,.7,blast.age)
  var player := Vector2(hero.global_position.x,hero.global_position.z)
  if not blast.hit and player.distance_to(blast.at) <= radius and absf(hero.global_position.y-floor_height(player)) < .85:
   if not perfect_hazard328():
    hazard_hurt332(1.5,blast.at,"meteor" if blast.get("meteor",false) else "mortar")
   blast.hit = true
  if blast.age >= .7:
   blast.visual.root.queue_free()
   blasts327.remove_at(i)

func perfect_hazard328() -> bool:
 if hero.dodge_invulnerability <= 0.:
  return false
 if hero.dash_eligible:
  hero.dash_eligible = false
  perfect_dodge()
 return true

func shell_defense326(from: Vector3, to: Vector3) -> bool:
 if hero.dodge_invulnerability <= 0.:
  return false
 var feet := Vector2(hero.global_position.x,hero.global_position.z)
 if absf(hero.global_position.y-floor_height(feet)) > .85:
  return false
 var crossing: float = aim_model.sweep_circle(Vector2(from.x,from.z),Vector2(to.x,to.z),feet,.72)
 return crossing <= 1. and perfect_hazard328()

func impact_feedback328(at: Vector2, meteor: bool) -> void:
 var distance := Vector2(hero.global_position.x,hero.global_position.z).distance_to(at)
 var strength := clampf(1. - distance / 12.,.2,1.)
 trauma = maxf(trauma,(.28 if meteor else .20)*strength)
 punch = maxf(punch,(.45 if meteor else .28)*strength)
 shake_duration328 = .24 if meteor else .18
 shake_left328 = shake_duration328
 shake_amp328 = (.09 if meteor else .055) * strength
 last_impact328 = "meteor" if meteor else "mortar"
 if impact_voices328.is_empty():
  return
 var voice := impact_voices328[impact_voice328 % impact_voices328.size()]
 impact_voice328 += 1
 voice.stream = impact_sounds328[last_impact328]
 voice.volume_db = -7. + linear_to_db(strength)
 voice.play()

func interrupt327(source := -1) -> void:
 for i in range(flights327.size()-1,-1,-1):
  if flights327[i].age < 0. and (source < 0 or flights327[i].source == source):
   remove_flight327(i)
 for i in range(cannon_shots326.size()-1,-1,-1):
  if source < 0 or cannon_shots326[i].get("source",-1) == source:
   cannon_shots326[i].sprite.queue_free()
   cannon_shots326.remove_at(i)

func clear_patterns327() -> void:
 for flight in flights327:
  if is_instance_valid(flight.sprite): flight.sprite.queue_free()
  if is_instance_valid(flight.marker): flight.marker.queue_free()
 flights327.clear()
 for blast in blasts327:
  if is_instance_valid(blast.visual.root): blast.visual.root.queue_free()
 blasts327.clear()

func finish251(victory: bool) -> void:
 clear_patterns327()
 shake_left328 = 0.
 for voice in impact_voices328: voice.stop()
 if is_instance_valid(theatre314):
  theatre314.enable_castle327(false)
 super.finish251(victory)

func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(theatre314):
  return
 var phase: String = "城堡倒下了" if fall314 >= 0. else PATTERNS327[pattern327]
 guide206.text = "329 城防弹幕 · 城堡 %.1f / %.0f\n%s · 纸偶干扰 %d\nF7 重开 · F4 瞄准" % [fastener_hp321,CASTLE_HP327,phase,live301().size()]
 if is_instance_valid(boss_bar326):
  boss_bar326.value = fastener_hp321 / CASTLE_HP327 * 100.
  phase_label326.text = phase


 if shake_left328 > 0. and not combat_paused:
  shake_left328 = maxf(0., shake_left328-delta)
  var envelope := pow(shake_left328/shake_duration328,2.)
  var age := shake_duration328-shake_left328
  camera.h_offset = shake_offset.x + sin(age*65.)*shake_amp328*envelope
  camera.v_offset += cos(age*51.)*shake_amp328*.6*envelope


func hazard_hurt332(damage: float, from: Vector2, _kind: String) -> void:
 hurt_player(damage,from)

func cannon_height338(at: Vector2, clearance: float) -> float:
 return floor_height(at)+clearance

func cannon_start338(at: Vector3, _clearance: float) -> Vector3:
 return at
