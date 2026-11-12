extends "res://scripts/world/woodland_world312.gd"

const FASTENER_HP321 := 12.
const LAST_ACT_HP324 := FASTENER_HP321 / 3.
const HEAVY_GAP324 := .32
const CLEAR_WINDOW322 := 3.4
const IMPACT_WINDOW322 := 2.6
const METEOR_RADIUS314 := 1.05
const METEOR_FLIGHT314 := 2.1
var theatre314: Node3D
var fastener_hp321 := FASTENER_HP321
var waiting_intro314 := true
var panel_open321 := false
var panel_left322 := 0.
var meteor_hits_panel322 := false
var fall314 := -1.
var meteor_clock314 := 0.
var meteor_at314 := Vector2.ZERO
var meteor_timer314 := 0.
var finale314 := ""
var entry_clock314 := -1.
var heavy_gap324 := 0.

func uses_card_schedule301() -> bool:
 return false

func card_type301(index: int) -> String:
 var first := index % TYPES301.size()
 if index < 3 and not last_act324():
  return super.card_type301(first)
 var live := live301()
 for offset in TYPES301.size():
  var kind := super.card_type301((first + offset) % TYPES301.size())
  if not live.any(func(card): return card.kind301 == kind):
   return kind
 return super.card_type301(first)

func last_act324() -> bool:
 return fastener_hp321 <= LAST_ACT_HP324

func heavy_active324(except: CharacterBody3D = null) -> bool:
 if meteor_clock314 > 0.:
  return true
 for card in cards301:
  if is_instance_valid(card) and card != except and not card.dead and card.state301 == "attack":
   if card.kind301 in ["knight", "monster"]:
    return true
 return false

func can_heavy324(actor: CharacterBody3D) -> bool:
 return not last_act324() or (heavy_gap324 <= 0. and not heavy_active324(actor))

func card_script301() -> Script:
 if card_type301(spawned301) == "knight":
  return preload("res://scripts/combat/paper_card321.gd")
 return preload("res://scripts/combat/paper_card323.gd")

func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 314 · 山顶纸剧场 Boss")

func stage_script314() -> Script:
 return preload("res://scripts/art/paper_stage314.gd")

func _ready() -> void:
 await super._ready()
 theatre314 = stage_script314().new()
 theatre314.battle = self
 theatre314.position = Vector3(centre301.x, floor_height(centre301 + Vector2(0., -1.)) + .03, centre301.y - 1.)
 add_child(theatre314)
 restart301()
 hint288.text = "314 纸剧场 · 城墙折页\n清场露出纸扣 · 引骑士撞左侧折页"

func restart301() -> void:
 if is_instance_valid(theatre314):
  theatre314.cancel()
  hero.controls_enabled = true
 super.restart301()
 if not is_instance_valid(theatre314):
  return
 fastener_hp321 = FASTENER_HP321
 waiting_intro314 = true
 panel_open321 = false
 panel_left322 = 0.
 meteor_hits_panel322 = false
 fall314 = -1.
 finale314 = ""
 meteor_clock314 = 0.
 meteor_timer314 = 3.8
 heavy_gap324 = 0.
 _teleport15(centre301 + Vector2(0., 2.5))
 clear_minions260()
 clear_standby119()
 boss247.process_mode = Node.PROCESS_MODE_DISABLED
 entry_clock314 = -1.
 theatre314.reset_battle314()
 theatre314.start()
 grid111.invalidate()

func _physics_process(delta: float) -> void:
 if ready301:
  pending260 = 0
  refill114 = 0.
  between_left = 0.
 super._physics_process(delta)
 if not ready301 or not is_instance_valid(theatre314) or not active114 or combat_paused or fastener_hp321 <= 0.:
  return
 boss_step314(delta)

func boss_step314(delta: float) -> void:
 if waiting_intro314:
  if not theatre314.finished:
   return
  waiting_intro314 = false
  var first := spawn301()
  var at := centre301 + Vector2(1.82, 2.55)
  first.position = Vector3(at.x, floor_height(at) + .04, at.y)
  first.enter301("rest")
  first.hit_area.collision_layer = 8
  first.render301()
  first.reset_physics_interpolation()
  theatre314.clear_demo314()
  grid111.invalidate()
  return
 if panel_open321:
  panel_left322 = maxf(0., panel_left322 - delta)
  if panel_left322 == 0.:
   close_panel324()
 if last_act324():
  heavy_gap324 = HEAVY_GAP324 if heavy_active324() else maxf(0., heavy_gap324 - delta)
 spawn_left301 -= delta
 var live := live301()
 if entry_clock314 >= 0. and theatre314.reaction_left313 <= 0.:
  entry_clock314 = maxf(0., entry_clock314 - delta)
  theatre314.sample_summon317(theatre314.SUMMON_END317 - entry_clock314)
  if entry_clock314 == 0.:
   theatre314.finish_summon317()
   live = live301()
   entry_clock314 = -1.
   spawn_left301 = 1. if last_act324() else 2.7
 var cap := 3 if last_act324() else (1 if spawned301 < 4 else 2)
 if entry_clock314 < 0. and spawn_left301 <= 0. and live.size() < cap and not panel_open321:
  spawn314()
 step_meteor314(delta, live.filter(func(card): return card != theatre314.summon_card317))

func spawn314() -> void:
 var kind := card_type301(spawned301)
 theatre314.cue_card314(kind)
 var card := spawn301()
 if kind == "knight":
  # Start close enough to the left bay for a straight, readable bait.
  var lane := Vector2(theatre314.panel321.global_position.x + .55, centre301.y + 3.35)
  card.position = Vector3(lane.x, floor_height(lane) + .04, lane.y)
  card.reset_physics_interpolation()
 elif last_act324():
  # Reinforcements enter from their own lanes even when the roster skips a kind.
  var lane := centre301 + (Vector2(2.5, 2.25) if kind == "dinosaur" else Vector2(0., 4.65))
  card.position = Vector3(lane.x, floor_height(lane) + .04, lane.y)
  card.reset_physics_interpolation()
 theatre314.begin_summon317(card)
 entry_clock314 = theatre314.SUMMON_END317

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
 if live301().is_empty() and entry_clock314 < 0.:
  open_panel321(CLEAR_WINDOW322)
  spawn_left301 = CLEAR_WINDOW322
 theatre314.reaction313(5)

func knight_wall321(wall: Dictionary) -> bool:
 if not active114 or waiting_intro314 or fastener_hp321 <= 0.:
  return false
 if wall.collider != theatre314.bodies[0].get_parent() or wall.normal.z < .6:
  return false
 var panel_at: Vector3 = theatre314.panel321.global_position
 if absf(wall.position.x - panel_at.x) > .92:
  return false
 open_panel321()
 return true

func close_panel324() -> void:
 panel_open321 = false
 panel_left322 = 0.
 theatre314.set_panel321(0)
 theatre314.panel_clock321 = .15
 Audio.play("crack", .5)

func open_panel321(duration := IMPACT_WINDOW322) -> void:
 if not active114 or waiting_intro314 or fastener_hp321 <= 0.:
  return
 panel_left322 = maxf(panel_left322, duration)
 if panel_open321:
  return
 panel_open321 = true
 theatre314.set_panel321(1)
 grid111.call_deferred("invalidate")
 theatre314.wall_recoil321 = .28
 legacy_contact_art(theatre314.panel321.global_position, Vector3.BACK, true)
 Audio.play("parry", .85)
 trauma = maxf(trauma, .14)

func hurt_player(damage: float, from: Vector2) -> void:
 var before := player_hp
 super.hurt_player(damage, from)
 if ready301 and is_instance_valid(theatre314) and active114 and player_hp < before:
  theatre314.reaction313(4)

func cursor_fastener321(cursor: Vector2) -> Vector3:
 if not panel_open321 or fastener_hp321 <= 0. or not active114:
  return Vector3.INF
 var origin := camera.project_ray_origin(cursor)
 var direction := camera.project_ray_normal(cursor)
 var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 250., 2 | 8, [hero.get_rid()])
 query.collide_with_areas = true
 var hit := get_world_3d().direct_space_state.intersect_ray(query)
 if not hit.is_empty() and hit.collider == theatre314.fastener321:
  return hit.position + direction * .04
 return Vector3.INF

func aim_at_screen(point: Vector2) -> Vector3:
 var fastener := cursor_fastener321(point)
 return fastener if fastener.is_finite() else super.aim_at_screen(point)

func fire_input_held() -> bool:
 if super.fire_input_held():
  return true
 if not auto114 or combat_paused or not is_instance_valid(hero) or not hero.controls_enabled or hero.guarding109 or hero.knocked_down:
  return false
 return Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and cursor_fastener321(get_viewport().get_mouse_position()).is_finite()

func _apply_shot_hit(shot: Dictionary, hit: Dictionary) -> void:
 if ready301 and active114 and not waiting_intro314 and is_instance_valid(theatre314):
  if hit.collider == theatre314.fastener321:
   if panel_open321 and fastener_hp321 > 0.:
    damage_fastener321(shot, hit.position)
   return
  if hit.collider == theatre314.bodies[0].get_parent():
   theatre314.wall_recoil321 = .12
 super._apply_shot_hit(shot, hit)

func bomb_impact149(packet: Dictionary, mark: Vector3, gain: float) -> void:
 super.bomb_impact149(packet, mark, gain)
 if not active114 or not panel_open321 or fastener_hp321 <= 0.:
  return
 var target: Vector3 = castle_blast_point314(mark)
 if Vector2(target.x - mark.x, target.z - mark.z).length() > 1.4 or absf(target.y - mark.y) > 3.5:
  return
 var query := PhysicsRayQueryParameters3D.create(mark + Vector3.UP * .2, target, 1 | 2, [hero.get_rid()])
 if not get_world_3d().direct_space_state.intersect_ray(query).is_empty():
  return
 var damage := 0.
 for spec in packet.specs:
  damage += float(spec.damage)
 if packet.stream:
  damage *= maxf(1., float(packet.burst_time) / float(packet.pulse_interval))
 damage_fastener321({"fixed_damage110": damage * gain, "velocity": target - mark}, target)

func castle_blast_point314(_mark: Vector3) -> Vector3:
 return theatre314.fastener321.global_position

func damage_fastener321(shot: Dictionary, at: Vector3) -> void:
 var hp_before := fastener_hp321
 fastener_hp321 = maxf(0., fastener_hp321 - maxf(0., damage_for_shot(shot)))
 if hp_before > LAST_ACT_HP324 and last_act324():
  # Give the final act a distinct start even if a burst crosses the threshold.
  fastener_hp321 = LAST_ACT_HP324
  close_panel324()
  spawn_left301 = minf(spawn_left301, .65)
 var broken := fastener_hp321 <= 0.
 theatre314.wall_recoil321 = .32 if broken else .21
 theatre314.panel_clock321 = .22
 legacy_contact_art(at, -Vector3(shot.velocity).normalized(), true, broken)
 Audio.play("crack" if broken else "hit", 1. if broken else .8)
 trauma = maxf(trauma, .22 if broken else .055)
 if broken:
  theatre314.set_panel321(2)
  hitstop(.08, true)
  call_deferred("finish251", true)

func step_meteor314(delta: float, live: Array) -> void:
 if meteor_clock314 > 0.:
  meteor_clock314 = maxf(0., meteor_clock314 - delta)
  theatre314.show_meteor314(meteor_at314, 1. - meteor_clock314 / METEOR_FLIGHT314 if meteor_clock314 > 0. else -1., meteor_hits_panel322)
  if meteor_clock314 == 0.:
   var feet := Vector2(hero.position.x, hero.position.z)
   if feet.distance_to(meteor_at314) <= METEOR_RADIUS314 and absf(hero.position.y - floor_height(meteor_at314)) < .85:
    hurt_player(1.5, meteor_at314)
   theatre314.explode_meteor314(meteor_at314)
   if meteor_hits_panel322:
    open_panel321()
    meteor_hits_panel322 = false
   trauma = maxf(trauma, .09)
  return
 if not live.any(func(card): return card.kind301 == "monster"):
  return
 meteor_timer314 -= delta
 if meteor_timer314 <= 0. and can_heavy324(null):
  meteor_timer314 = 4.4
  meteor_at314 = paper_clamp301(Vector2(hero.position.x, hero.position.z))
  meteor_clock314 = METEOR_FLIGHT314
  var panel_at: Vector3 = theatre314.panel321.global_position
  var wall_z: float = theatre314.bodies[0].global_position.z + .19
  var hero_at: Vector3 = hero.global_position
  meteor_hits_panel322 = absf(hero_at.x - panel_at.x) < .95 and absf(hero_at.z - wall_z) < 1.4
  if meteor_hits_panel322:
   meteor_at314 = Vector2(panel_at.x, wall_z)
  theatre314.show_meteor314(meteor_at314, 0., meteor_hits_panel322)

func finish251(victory: bool) -> void:
 if ready301 and is_instance_valid(theatre314):
  theatre314.cancel()
  theatre314.clear_summon317()
  theatre314.clear_demo314()
  theatre314.fastener321.set_deferred("collision_layer", 0)
  entry_clock314 = -1.
  theatre314.fold_clock314 = -1.
  theatre314.burst_clock314 = -1.
  theatre314.burst_root314.hide()
  theatre314.show_meteor314(Vector2.ZERO, -1.)
  for card in cards301:
   if is_instance_valid(card):
    enemies.erase(card)
    card.queue_free()
  cards301.clear()
  rebuild_cells110()
  if victory:
   fall314 = 0.
   theatre314.begin_collapse314()
  finale314 = "城堡倒下 · F7 重开" if victory else "本轮结束 · F7 重开"
 super.finish251(victory)

func _process(delta: float) -> void:
 super._process(delta)
 if not ready301 or not is_instance_valid(theatre314):
  return
 camera.v_offset = shake_offset.y + (1.25 if waiting_intro314 else .8)
 if fall314 >= 0.:
  fall314 += delta
  theatre314.collapse314(fall314)
  hero.controls_enabled = fall314 >= 4.5
  if fall314 < 4.5:
   hero.velocity = Vector3.ZERO
   hero.locomotion = Vector2.ZERO
 if fall314 < 0. and not combat_paused:
  theatre314.tick_panel321(delta)
 var objective := "清场露出纸扣 · 骑士冲锋或陨石也能撞开"
 if fastener_hp321 <= 0.:
  objective = "纸扣已打掉 · 折页撕裂"
 elif panel_open321:
  objective = "纸扣已露出 · %.1f 秒后合拢" % panel_left322
 guide206.text = "314 纸剧场 · 纸扣 %.1f / %.0f · 在场 %d\n%s\n%s"%[fastener_hp321, FASTENER_HP321, live301().size(), objective, finale314]
 if last_act324() and fastener_hp321 > 0. and active114:
  guide206.text += "\n终幕 · 三只纸偶错峰入场"
 guide206.text += "\nF11 整组对照 · " + ("318 统一动作" if theatre314.use_pixel315 else "旧版帧")

func _input(event: InputEvent) -> void:
 if ready301 and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode == KEY_F11 and is_instance_valid(theatre314):
   theatre314.toggle_pixel315()
   get_viewport().set_input_as_handled()
   return
  if event.physical_keycode in [KEY_F2, KEY_F5, KEY_F8, KEY_F9, KEY_F10] or (waiting_intro314 and event.physical_keycode == KEY_F6):
   get_viewport().set_input_as_handled()
   return
  if event.physical_keycode == KEY_F3 and is_instance_valid(theatre314):
   theatre314.hide()
   theatre314.sync_scenery322()
   boss247.process_mode = Node.PROCESS_MODE_INHERIT
 super._input(event)

func _spawn_wave110(index: int) -> void:
 if not ready301:
  super._spawn_wave110(index)

func spawn_minion260() -> CharacterBody3D:
 if ready301:
  return null
 return super.spawn_minion260()