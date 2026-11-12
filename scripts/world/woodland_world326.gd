extends "res://scripts/world/woodland_world314.gd"

const CORE_HP326 := 8.
const CANNON_HP326 := 3.
const SUMMON_RATE326 := 1.8
const SHOCK_RADIUS326 := 2.2
var core_phase326 := false
var puppet_loss326 := {"dinosaur": 0., "knight": 0., "monster": 0.}
var cannon_hp326: Array[float] = [CANNON_HP326, CANNON_HP326]
var cannon_clock326 := 0.
var cannon_index326 := 0
var cannon_shots326: Array[Dictionary] = []
var impact_slot326 := 0.
var shock_clock326 := -1.
var shock_hit326 := false
var boss_bar326: ProgressBar
var phase_label326: Label

func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 326 · 纸剧场两段战")

func stage_script314() -> Script:
 return preload("res://scripts/art/paper_stage326.gd")

func _ready() -> void:
 await super._ready()
 var layer := CanvasLayer.new()
 add_child(layer)
 boss_bar326 = ProgressBar.new()
 boss_bar326.position = Vector2(get_viewport().get_visible_rect().size.x * .5 - 180., 155.)
 boss_bar326.size = Vector2(360., 18.)
 boss_bar326.show_percentage = false
 var background := StyleBoxFlat.new()
 background.bg_color = Color(.13, .09, .14, .88)
 background.set_corner_radius_all(4)
 var fill := StyleBoxFlat.new()
 fill.bg_color = Color(.91, .38, .52)
 fill.set_corner_radius_all(4)
 boss_bar326.add_theme_stylebox_override("background", background)
 boss_bar326.add_theme_stylebox_override("fill", fill)
 layer.add_child(boss_bar326)
 phase_label326 = Label.new()
 phase_label326.position = boss_bar326.position + Vector2(0., -24.)
 phase_label326.size.x = 360.
 phase_label326.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 phase_label326.add_theme_color_override("font_outline_color", Color(.13,.08,.12))
 phase_label326.add_theme_constant_override("outline_size", 3)
 layer.add_child(phase_label326)
 hint288.text = "326 山顶纸剧场\n打倒纸偶拆掉结构，再迎着城防拆城堡"

func restart301() -> void:
 core_phase326 = false
 puppet_loss326 = {"dinosaur": 0., "knight": 0., "monster": 0.}
 cannon_hp326 = [CANNON_HP326, CANNON_HP326]
 cannon_clock326 = .8
 cannon_index326 = 0
 impact_slot326 = 0.
 shock_clock326 = -1.
 clear_cannon_shots326()
 super.restart301()
 fastener_hp321 = CORE_HP326

func card_type301(index: int) -> String:
 return TYPES301[index % 3]

func can_heavy324(actor: CharacterBody3D) -> bool:
 if actor == null:
  return true
 if impact_slot326 > 0.:
  return false
 impact_slot326 = .6
 return true

func boss_step314(delta: float) -> void:
 impact_slot326 = maxf(0., impact_slot326 - delta)
 update_progress326()
 if waiting_intro314:
  super.boss_step314(delta)
  if not waiting_intro314:
   spawn_left301 = .15
  return
 if not core_phase326:
  if entry_clock314 >= 0.:
   entry_clock314 = maxf(0., entry_clock314 - delta * SUMMON_RATE326)
   theatre314.sample_summon317(theatre314.SUMMON_END317 - entry_clock314)
   if entry_clock314 == 0.:
    theatre314.finish_summon317()
    entry_clock314 = -1.
    spawn_left301 = .15
  else:
   spawn_left301 -= delta
   if spawned301 < 3 and spawn_left301 <= 0.:
    spawn314()
    theatre314.fold_clock314 = -1.
  step_meteor314(delta, live301())
 else:
  tick_cannons326(delta)
 tick_cannon_shots326(delta)
 tick_shock326(delta)

func spawn314() -> void:
 super.spawn314()
 spawn_left301 = INF

func update_progress326() -> void:
 for card in cards301:
  if is_instance_valid(card):
   puppet_loss326[card.kind301] = maxf(puppet_loss326[card.kind301], clampf(1. - card.hp / card.max_hp110, 0., 1.))

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
 puppet_loss326[actor.kind301] = 1.
 if target114 == actor:
  target114 = null
 aim_tick114 = -1
 theatre314.wall_recoil321 = .28
 theatre314.reaction313(5)
 if defeated301 == 3:
  begin_core326()

func begin_core326() -> void:
 core_phase326 = true
 meteor_clock314 = 0.
 theatre314.show_meteor314(Vector2.ZERO, -1.)
 theatre314.clear_demo314()
 panel_open321 = true
 theatre314.set_panel321(1)
 grid111.call_deferred("invalidate")
 cannon_clock326 = .8
 theatre314.enable_cannons326(true)

func open_panel321(_duration := IMPACT_WINDOW322) -> void:
 # Knocking a puppet into the wall still rewards the action with a shorter enemy fight.
 if core_phase326:
  return
 theatre314.wall_recoil321 = .3
 impact_slot326 = maxf(impact_slot326, .45)

func structure_contact326(at: Vector3, normal: Vector3, broken := false) -> void:
 legacy_contact_art(at, normal, true, broken)

func damage_fastener321(shot: Dictionary, at: Vector3) -> void:
 if not core_phase326 or not active114:
  return
 fastener_hp321 = maxf(0., fastener_hp321 - maxf(0., damage_for_shot(shot)))
 theatre314.panel_clock321 = .23
 theatre314.wall_recoil321 = .25
 structure_contact326(at, -Vector3(shot.velocity).normalized(), fastener_hp321 == 0.)
 Audio.play("crack" if fastener_hp321 == 0. else "hit")
 if fastener_hp321 == 0.:
  theatre314.set_panel321(2)
  hitstop(.08, true)
  call_deferred("finish251", true)

func cursor_fastener321(cursor: Vector2) -> Vector3:
 if not core_phase326 or not active114:
  return Vector3.INF
 var origin := camera.project_ray_origin(cursor)
 var direction := camera.project_ray_normal(cursor)
 var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 250., 2 | 8, [hero.get_rid()])
 query.collide_with_areas = true
 var hit := get_world_3d().direct_space_state.intersect_ray(query)
 if not hit.is_empty() and (hit.collider == theatre314.fastener321 or (hit.collider is Area3D and theatre314.cannon_areas326.has(hit.collider))):
  return hit.position + direction * .04
 return Vector3.INF

func _apply_shot_hit(shot: Dictionary, hit: Dictionary) -> void:
 if is_instance_valid(theatre314) and core_phase326 and active114 and hit.collider is Area3D:
  var index: int = theatre314.cannon_areas326.find(hit.collider)
  if index >= 0:
   hurt_cannon326(index, maxf(0., damage_for_shot(shot)))
   return
 super._apply_shot_hit(shot, hit)

func bomb_impact149(packet: Dictionary, mark: Vector3, gain: float) -> void:
 super.bomb_impact149(packet, mark, gain)
 if not core_phase326 or not active114:
  return
 var damage := 0.
 for spec in packet.specs:
  damage += float(spec.damage) * gain
 if packet.stream:
  damage *= maxf(1., packet.burst_time / packet.pulse_interval)
 for i in 2:
  if cannon_hp326[i] <= 0.:
   continue
  var target: Vector3 = theatre314.cannon_areas326[i].global_position
  if Vector2(target.x - mark.x, target.z - mark.z).length() <= 1.4:
   var query := PhysicsRayQueryParameters3D.create(mark + Vector3.UP * .2, target, 1 | 2)
   if get_world_3d().direct_space_state.intersect_ray(query).is_empty():
    hurt_cannon326(i, damage)

func hurt_cannon326(index: int, damage: float) -> void:
 if cannon_hp326[index] <= 0. or not active114:
  return
 cannon_hp326[index] = maxf(0., cannon_hp326[index] - damage)
 theatre314.recoil_cannon326(index)
 if cannon_hp326[index] == 0.:
  theatre314.break_cannon326(index)
  cannon_clock326 = maxf(cannon_clock326, 1.)
  damage_fastener321({"fixed_damage110": 3., "velocity": Vector3.BACK}, theatre314.cannon_areas326[index].global_position)

func tick_cannons326(delta: float) -> void:
 cannon_clock326 -= delta
 if cannon_clock326 > 0.:
  theatre314.aim_cannon326(cannon_index326, cannon_clock326 < .55)
  return
 var index := cannon_index326
 cannon_index326 = 1 - cannon_index326
 cannon_clock326 = 1.25
 if cannon_hp326[index] <= 0.:
  return
 var from: Vector3 = theatre314.cannon_areas326[index].global_position + Vector3.UP * .25
 var lead: Vector3 = hero.global_position + hero.velocity.limit_length(4.) * .2
 var direction := Vector2(lead.x - from.x, lead.z - from.z).normalized()
 for angle in [-.18, 0., .18]:
  var heading := direction.rotated(angle)
  var sprite: Sprite3D = theatre314.make_shell326(from)
  cannon_shots326.append({"sprite": sprite, "at": from, "direction": heading, "life": 2.})
 theatre314.recoil_cannon326(index)
 Audio.play("crack", .65)

func tick_cannon_shots326(delta: float) -> void:
 for i in range(cannon_shots326.size() - 1, -1, -1):
  var shot := cannon_shots326[i]
  var from: Vector3 = shot.at
  var heading: Vector2 = shot.direction
  var to := from + Vector3(heading.x, 0., heading.y) * delta * float(shot.get("speed",6.5))
  to.y = floor_height(Vector2(to.x, to.z)) + .7
  var player := Vector2(hero.global_position.x, hero.global_position.z)
  var contact := aim_model.sweep_circle(Vector2(from.x, from.z), Vector2(to.x, to.z), player, .55) <= 1.
  var blocked := not get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to, 1 | 2)).is_empty()
  var defended := not blocked and shell_defense326(from,to)
  if defended: shot.life = 0.
  shot.life -= delta
  if contact and not defended and not blocked and absf(hero.global_position.y - floor_height(player)) < .85:
   if hero.can_parry():
    parry_success(hero.global_position + Vector3.UP * .7, -Vector3(heading.x, 0., heading.y))
   else:
    hurt_player(1., Vector2(from.x, from.z))
   shot.life = 0.
  if blocked or shot.life <= 0.:
   shot.sprite.queue_free()
   cannon_shots326.remove_at(i)
  else:
   shot.at = to
   shot.sprite.global_position = to
   shot.sprite.rotation.z += delta * 5.

func shell_defense326(_from: Vector3, _to: Vector3) -> bool:
 return false

func clear_cannon_shots326() -> void:
 for shot in cannon_shots326:
  if is_instance_valid(shot.sprite):
   shot.sprite.queue_free()
 cannon_shots326.clear()

func step_meteor314(delta: float, live: Array) -> void:
 if meteor_clock314 > 0.:
  meteor_clock314 = maxf(0., meteor_clock314 - delta)
  theatre314.show_meteor314(meteor_at314, 1. - meteor_clock314 / 1.25 if meteor_clock314 > 0. else -1.)
  if meteor_clock314 == 0.:
   shock_clock326 = 0.
   shock_hit326 = false
   theatre314.explode_meteor314(meteor_at314)
  return
 if not live.any(func(card): return card.kind301 == "monster" and card != theatre314.summon_card317):
  return
 meteor_timer314 -= delta
 if meteor_timer314 <= 0.:
  meteor_timer314 = 2.8
  var lead: Vector3 = hero.global_position + hero.velocity.limit_length(4.) * .45
  meteor_at314 = paper_clamp301(Vector2(lead.x, lead.z))
  meteor_clock314 = 1.25
  theatre314.show_meteor314(meteor_at314, 0.)

func tick_shock326(delta: float) -> void:
 if shock_clock326 < 0.:
  return
 shock_clock326 += delta
 var radius := lerpf(.45, SHOCK_RADIUS326, clampf(shock_clock326 / .45, 0., 1.))
 theatre314.draw_shock326(meteor_at314, radius, maxf(0., 1. - shock_clock326 / .65))
 var feet := Vector2(hero.global_position.x, hero.global_position.z)
 if not shock_hit326 and feet.distance_to(meteor_at314) <= radius and absf(hero.global_position.y - floor_height(feet)) < .85:
  hurt_player(1.5, meteor_at314)
  shock_hit326 = true
 if shock_clock326 >= .65:
  shock_clock326 = -1.

func finish251(victory: bool) -> void:
 clear_cannon_shots326()
 if is_instance_valid(theatre314):
  theatre314.enable_cannons326(false)
  theatre314.draw_shock326(Vector2.ZERO, 0., 0.)
 shock_clock326 = -1.
 super.finish251(victory)

func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(theatre314):
  return
 var progress: float = (puppet_loss326.dinosaur + puppet_loss326.knight + puppet_loss326.monster) * 25.
 progress += (1. - fastener_hp321 / CORE_HP326) * 25.
 var phase := "城堡倒下了" if fall314 >= 0. else ("迎着城防拆城堡" if core_phase326 else "打倒三只纸偶，拆掉城堡结构")
 guide206.text = "326 纸剧场 · 已拆 %.0f%%\n%s\n纸偶 %d / 3 · 城堡 %.1f / %.0f\nF7 重开 · F4 瞄准" % [progress, phase, defeated301, fastener_hp321, CORE_HP326]
 if is_instance_valid(boss_bar326):
  boss_bar326.value = 100. - progress
  phase_label326.text = phase
