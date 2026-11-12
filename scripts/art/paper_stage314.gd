extends "res://scripts/art/paper_stage313.gd"

var mills314: Array[Sprite3D] = []
var scenery_shapes322: Dictionary[Sprite3D, CollisionShape3D] = {}
var mill_slots314: Array[Vector3] = []
var mill_clock314 := -1.
var meteor314: Sprite3D
const PANEL321 := preload("res://assets/paper_stage314/weakpoint320.png")
var panel321: Sprite3D
var fastener321: Area3D
var panel_frames321: Array[AtlasTexture] = []
var panel_clock321 := 0.
var wall_recoil321 := 0.
var fold_clock314 := -1.
var burst_clock314 := -1.
var burst_root314: Node3D
var boom314: Sprite3D
var ruins314: Sprite3D
var ending_at314 := Vector3.ZERO
var landing_shadow314: MeshInstance3D
const IDLE_PIXEL315 := preload("res://assets/paper_girl315/idle_pixel_v3.png")
const ACTIONS316 := preload("res://assets/paper_girl316/actions318.png")
const GRIP319 := preload("res://assets/paper_girl316/grip319.png")
var summon_card317: CharacterBody3D
var summon_preview317: Sprite3D
var frames316: Array[AtlasTexture] = []
var frame316 := 0
var use_pixel315 := true
var sister_height314 := 1.6
var reaction_index314 := 3
var reaction_anchor314 := Vector3.ZERO
var smoke314: Array[Sprite3D] = []
var rescue_frames314: Array[AtlasTexture] = []
var defeat_frames314: Array[AtlasTexture] = []
var terrace314: Node3D
var terrace_floor314: CollisionShape3D
var terrace_shadow314: MeshInstance3D

func _ready() -> void:
 setup_frames316()
 super._ready()
 var hero_sprite: Sprite3D = battle.hero.visual
 var image := hero_sprite.texture.get_image()
 var top := image.get_height()
 var bottom := -1
 for y in image.get_height():
  for x in image.get_width():
   if image.get_pixel(x, y).a >= .5:
    top = mini(top, y)
    bottom = y
    break
 sister_height314 = maxf(1., bottom - top + 1.) * hero_sprite.pixel_size * hero_sprite.global_basis.y.length()
 setup_terrace314()
 setup_panel321()
 landing_shadow314 = terrace_shadow314.duplicate()
 add_child(landing_shadow314)
 var mill := preload("res://assets/paper_stage314/windmill.png")
 for i in 2:
  var slot := Vector2(-4.15, .75) if i == 0 else Vector2(-5.15, 2.7)
  var panel := card298(mill, {"span": [784.], "foot": [769., 961.]}, 2.1 if i == 0 else 1.48, self)
  panel.rotation.x = deg_to_rad(-25.)
  mills314.append(panel)
  mill_slots314.append(Vector3(slot.x, ground298(slot.x, slot.y), slot.y))
  shadow298(panel, self)
  add_scenery_body322(panel, mill_slots314[i], Vector3(.87, 1.5, .55) if i == 0 else Vector3(.65, 1.1, .46))
 add_scenery_body322(wings298[0], backdrop_slots313[0], Vector3(2.25, 1.05, .46))
 add_scenery_body322(wings298[1], backdrop_slots313[1], Vector3(1.95, 1.1, .7))
 meteor314 = card298(preload("res://assets/paper_stage314/meteor.png"), {"span": [806.], "foot": [587., 896.]}, 1.9, self)
 meteor314.rotation.x = deg_to_rad(-25.)
 setup_burst314()
 setup_defeat314()
 setup_rescue_effects314()
 reset_battle314()

func reset_battle314() -> void:
 clear_summon317()
 for shape in scenery_shapes322.values():
  shape.set_deferred("disabled", true)
 mill_clock314 = -1.
 fold_clock314 = -1.
 burst_clock314 = -1.
 burst_root314.hide()
 ruins314.hide()
 landing_shadow314.hide()
 castle.scale = Vector3.ONE
 castle.position.x = 0.
 for puff in smoke314:
  puff.hide()
 terrace314.scale = Vector3.ONE
 girl.rotation = Vector3.ZERO
 terrace314.rotation = Vector3.ZERO
 terrace314.show()
 terrace_floor314.set_deferred("disabled", false)
 for mill in mills314:
  mill.hide()
 meteor314.hide()
 wall_recoil321 = 0.
 set_panel321(0)
 castle.rotation = Vector3(deg_to_rad(-25.), 0., 0.)
 castle.material_override.albedo_color = material(Color.WHITE).albedo_color
 girl.show()

func clear_demo314() -> void:
 dinosaur313.hide()
 handler313.hide()
 packet313.hide()
 line313.hide()

func cue_card314(kind: String) -> void:
 if kind == "knight" and mill_clock314 < 0.:
  mill_clock314 = 0.
  wings298[0].hide()
  sync_scenery322()
 fold_clock314 = 0.

func _process(delta: float) -> void:
 if battle.fall314 >= 0.:
  return
 super._process(delta)
 if battle.combat_paused:
  return
 if reaction_left313 > 0.:
  director_pose313(reaction_index314)
  var beat := sin(reaction_left313 * 19.)
  girl.rotation.z = beat * .09 if reaction_index314 == 5 else 0.
  girl.position.y = reaction_anchor314.y + absf(beat) * .065
 else:
  girl.rotation.z = 0.
  if finished:
   girl.position = balcony313
 if fold_clock314 >= 0. and reaction_left313 <= 0.:
  fold_clock314 += delta
  director_pose313(0 if fold_clock314 < .27 else (1 if fold_clock314 < .70 else 2))
  if use_pixel315 and fold_clock314 >= .49 and fold_clock314 < .70:
   pose316(5)
  if fold_clock314 >= 1.05:
   director_pose313(3)
   fold_clock314 = -1.
 if finished and fold_clock314 < 0. and reaction_left313 <= 0.:
  idle_compare315()
 if mill_clock314 >= 0. and mill_clock314 < 1.5:
  mill_clock314 += delta
  for i in mills314.size():
   var delay := .16 * i
   var panel := mills314[i]
   panel.visible = mill_clock314 >= delay
   panel.position = mill_slots314[i] + Vector3.UP * drop313(mill_clock314, delay, .66, 8.)
 sync_scenery322()
 if burst_clock314 >= 0.:
  burst_clock314 += delta
  burst_root314.visible = burst_clock314 < .7
  if burst_clock314 >= .7:
   burst_clock314 = -1.
  else:
   var pop := smoothstep(0., .10, burst_clock314)
   boom314.scale = Vector3.ONE * lerpf(.65, 1., pop)
   boom314.rotation.z = sin(burst_clock314 * 14.) * .045
   boom314.transparency = smoothstep(.46, .7, burst_clock314)

func add_scenery_body322(panel: Sprite3D, foot: Vector3, size: Vector3) -> void:
 var shape := collider298(foot + Vector3.UP * (size.y * .5 - .1), size)
 shape.disabled = true
 scenery_shapes322[panel] = shape

func sync_scenery322() -> void:
 for panel in scenery_shapes322:
  var shape := scenery_shapes322[panel]
  var box := shape.shape as BoxShape3D
  var foot_y := (shape.get_parent() as Node3D).position.y - box.size.y * .5 + .1
  var grounded := panel.is_visible_in_tree() and absf(panel.position.y - foot_y) < .045
  if grounded and shape.disabled:
   # Wait for the player to step off the footprint before solidifying.
   var gap: Vector3 = battle.hero.global_position - shape.global_position
   grounded = absf(gap.x) > box.size.x * .5 + .35 or absf(gap.z) > box.size.z * .5 + .35
  if shape.disabled == grounded:
   shape.set_deferred("disabled", not grounded)
   battle.grid111.call_deferred("invalidate")

func reaction313(index: int) -> void:
 if battle.waiting_intro314 or battle.fall314 >= 0.:
  return
 if index == 4 and reaction_left313 > 0. and reaction_index314 == 5:
  return
 director_pose313(index)
 reaction_index314 = index
 reaction_anchor314 = girl.position
 reaction_left313 = 1.8 if index == 5 else .85

func show_meteor314(at: Vector2, progress: float, hits_panel := false) -> void:
 meteor314.visible = progress >= 0.
 if not meteor314.visible:
  return
 var contact := to_local(Vector3(at.x, battle.floor_height(at) + (.9 if hits_panel else .09), at.y))
 meteor314.position = contact + Vector3(5.8, 5.8, 0.) * (1. - progress)

func setup_panel321() -> void:
 for i in 3:
  var cell := AtlasTexture.new()
  cell.atlas = PANEL321
  cell.region = Rect2(i * 724, 0, 724, 724)
  cell.filter_clip = true
  panel_frames321.append(cell)
 panel321 = card298(panel_frames321[0], {"span": [476.], "foot": [378., 363.]}, 1.56, castle)
 panel321.material_override.albedo_texture = PANEL321
 panel321.position = Vector3((563. - 837.5) * castle.pixel_size, (928. - 784.) * castle.pixel_size, .02)
 fastener321 = Area3D.new()
 fastener321.collision_mask = 0
 fastener321.monitoring = false
 fastener321.monitorable = false
 var shape := CollisionShape3D.new()
 var box := BoxShape3D.new()
 box.size = Vector3(.77, .77, .2)
 shape.shape = box
 fastener321.add_child(shape)
 add_child(fastener321)

func set_panel321(state: int) -> void:
 var center_x: float = [378., 362.5, 348.5][state]
 panel321.texture = panel_frames321[state]
 panel321.offset = Vector2(362. - center_x, 1.)
 panel321.rotation = Vector3.ZERO
 panel321.scale = Vector3.ONE
 panel_clock321 = .28 if state > 0 else 0.
 if state == 1:
  # Project the visible fastener in front of the castle's flat collision wall.
  # The painted facade leans back, so its art position is behind the wall.
  var painted := castle.to_global(panel321.position + Vector3(0., -.056, 0.))
  var camera: Camera3D = battle.camera
  var view_ray := camera.project_ray_normal(camera.unproject_position(painted))
  var front_z := bodies[0].global_position.z + .29
  fastener321.global_position = painted + view_ray * ((front_z - painted.z) / view_ray.z)
 fastener321.set_deferred("collision_layer", 8 if state == 1 else 0)

func tick_panel321(delta: float) -> void:
 wall_recoil321 = maxf(0., wall_recoil321 - delta)
 panel_clock321 = maxf(0., panel_clock321 - delta)
 castle.rotation.z = sin(wall_recoil321 * 37.) * wall_recoil321 * .14
 panel321.rotation.x = -sin(panel_clock321 / .28 * PI) * .30
 panel321.scale = Vector3.ONE * (1. + sin(panel_clock321 / .28 * PI) * .095)

func begin_collapse314() -> void:
 var hero_at: Vector3 = to_local(battle.hero.global_position)
 var best := -1.
 for x in [-2.1, 2.1]:
  var candidate := Vector3(x, ground298(x, 2.1), 2.1)
  var distance := candidate.distance_squared_to(hero_at)
  if distance > best:
   best = distance
   ending_at314 = candidate

func collapse314(elapsed: float) -> void:
 bodies[0].set_deferred("disabled", true)
 terrace_floor314.set_deferred("disabled", true)
 var fold := smoothstep(1.12, 1.9, elapsed)
 var shake := sin(elapsed * 34.) * .045 + sin(elapsed * 51.) * .018
 castle.visible = elapsed < 1.9
 castle.scale.y = lerpf(1., .13, fold)
 castle.rotation.z = shake * (1. - fold)
 castle.position.x = shake * .7 * (1. - fold)
 terrace314.visible = elapsed < 1.82
 terrace314.position.y = balcony313.y * (1. - fold)
 terrace314.rotation.z = castle.rotation.z
 terrace314.scale.y = lerpf(1., .25, fold)
 ruins314.visible = elapsed >= 1.78
 ruins314.scale = Vector3.ONE * lerpf(.86, 1., smoothstep(1.78, 2.1, elapsed))
 var lower := smoothstep(2.25, 4.5, elapsed)
 var clear := smoothstep(1.25, 2.12, elapsed)
 var sag := -.22 * smoothstep(.64, .92, elapsed)
 var yank := .55 * smoothstep(.92, 1.09, elapsed)
 var recoil := .10 * sin(maxf(0., elapsed - 1.09) * 15.) * exp(-maxf(0., elapsed - 1.09) * 3.)
 var hang := balcony313.y + sag + yank + (recoil if elapsed >= 1.09 else 0.)
 var swing := (1. - lower) * sin(maxf(0., elapsed - .92) * 8.) * exp(-maxf(0., elapsed - .92) * 1.25) * .23 if elapsed >= .92 else 0.
 girl.show()
 girl.position = Vector3(lerpf(balcony313.x, ending_at314.x, clear) + swing, lerpf(hang, ending_at314.y, lower), lerpf(balcony313.z, ending_at314.z, clear))
 girl.rotation.z = -shake * 2. if elapsed < .92 else -swing * .8
 if elapsed < 4.45:
  if use_pixel315 and elapsed >= 2.25:
   pose316(14)
  else:
   rescue_pose314(0 if elapsed < .92 else 1)
 else:
  defeat_pose314(1)
 landing_shadow314.visible = elapsed >= 4.4
 landing_shadow314.position = ending_at314 + Vector3.UP * .012
 handler313.visible = elapsed >= .12
 var tether := girl.transform * Vector3(279.5 * actor_height313() / 816., 623. * actor_height313() / 816., 0.)
 var rope_gap := 1.05
 if use_pixel315:
  tether = girl.transform * (Vector3(41., 174., 0.) * visual.pixel_size)
 if use_pixel315 and frame316 in [13, 14]:
  var strap_x := 210. if frame316 == 13 else 211.
  var hook := Vector3(strap_x - 169., 297. - 25., 0.) * visual.pixel_size
  # Swing around the visible strap tip so the rope stays pinned as she turns.
  girl.rotation.z += .085 * sin(maxf(0., elapsed - 2.12) * 5.) * (1. - lower)
  girl.position += hook - girl.basis * hook
  tether = girl.transform * hook
  rope_gap -= (123. - 25.) * visual.pixel_size
 var support := tether + Vector3.UP * (rope_gap - .30 * sin(PI * smoothstep(.92, 1.32, elapsed)))
 var approach := 1. - pow(1. - clampf((elapsed - .12) / .8, 0., 1.), 2.)
 handler313.position = offscreen_support313(balcony313 + Vector3.UP * 2.2).lerp(support, approach)
 handler313.rotation.z = .35 * (1. - approach) + swing
 drift_handler313(HANDLER_ENTER313 + elapsed)
 line313.visible = elapsed >= .92 and elapsed < 4.45
 if line313.visible:
  line_mesh313.clear_surfaces()
  line_mesh313.surface_begin(Mesh.PRIMITIVE_LINES)
  line_mesh313.surface_add_vertex(tether)
  line_mesh313.surface_add_vertex(handler313.transform * (Vector3.UP * .08))
  line_mesh313.surface_end()
 for i in smoke314.size():
  var puff := smoke314[i]
  var phase := elapsed - float(i) * .13
  puff.visible = phase >= 0. and elapsed < 2.7
  puff.position = Vector3(-2.1 + i * 2., 1.1 + maxf(0., phase) * .35, .25)
  puff.scale = Vector3.ONE * lerpf(.35, 1.15, smoothstep(0., .65, phase))
  puff.rotation.z = sin(phase * 6. + i) * .10
  puff.transparency = smoothstep(2., 2.7, elapsed)

func setup_defeat314() -> void:
 var texture := preload("res://assets/paper_stage314/defeat_poses.png")
 for i in 2:
  var frame := AtlasTexture.new()
  frame.atlas = texture
  frame.region = Rect2(i * 768., 0., 768., 1024.)
  frame.filter_clip = true
  defeat_frames314.append(frame)

func defeat_pose314(index: int) -> void:
 if use_pixel315:
  pose316(10 + index)
  return
 balcony_pose313(defeat_frames314[index], Vector2(438.5 if index == 0 else 326.5, 937.), 841.)
 visual.material_override.albedo_texture = defeat_frames314[index].atlas

func setup_burst314() -> void:
 burst_root314 = Node3D.new()
 add_child(burst_root314)
 boom314 = card298(preload("res://assets/paper_stage314/boom.png"), {"span": [1308.], "foot": [768., 995.]}, 2.6, burst_root314)
 boom314.material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 boom314.material_override.albedo_color = Color.WHITE
 ruins314 = card298(preload("res://assets/paper_stage314/castle_folded.png"), {"span": [2004.], "foot": [1095., 670.]}, 5.6, self)
 ruins314.rotation.x = deg_to_rad(-25.)
 ruins314.position.y = ground298(0., 0.)

func explode_meteor314(at: Vector2) -> void:
 burst_clock314 = 0.
 burst_root314.position = to_local(Vector3(at.x, battle.floor_height(at) + .08, at.y))
 burst_root314.show()
 boom314.transparency = 0.

func setup_terrace314() -> void:
 castle.texture = preload("res://assets/paper_stage314/castle_body.png")
 castle.material_override.albedo_texture = castle.texture
 castle.pixel_size = 10.5 / 1309.
 castle.offset = Vector2(castle.texture.get_width() * .5 - 837.5, 928. - castle.texture.get_height() * .5)
 balcony313.z += .68
 lift_floor313 = ground298(balcony313.x, balcony313.z)
 terrace314 = Node3D.new()
 terrace314.position = balcony313
 add_child(terrace314)
 var texture := preload("res://assets/paper_stage314/terrace.png")
 var back_texture := AtlasTexture.new()
 back_texture.atlas = texture
 back_texture.region = Rect2(0., 0., 1774., 458.)
 back_texture.filter_clip = true
 var deck := card298(back_texture, {"span": [1268.], "foot": [887., 430.]}, 4.25, terrace314)
 deck.material_override.albedo_texture = texture
 deck.rotation.x = deg_to_rad(-25.)
 # The painted deck is independent of the facade. Give it a horizontal floor.
 var floor := MeshInstance3D.new()
 var plane := PlaneMesh.new()
 plane.size = Vector2(2.5, .52)
 floor.mesh = plane
 floor.position = Vector3(0., -.025, -.36)
 var ink := material(Color.WHITE)
 ink.albedo_texture = texture
 ink.uv1_scale = Vector3(750. / 1774., 125. / 887., 1.)
 ink.uv1_offset = Vector3(510. / 1774., 319. / 887., 0.)
 ink.cull_mode = BaseMaterial3D.CULL_DISABLED
 floor.material_override = ink
 terrace314.add_child(floor)
 var front_texture := AtlasTexture.new()
 front_texture.atlas = texture
 front_texture.region = Rect2(0., 458., 1774., 429.)
 front_texture.filter_clip = true
 var front := card298(front_texture, {"span": [1268.], "foot": [887., -28.]}, 4.25, terrace314)
 front.material_override.albedo_texture = texture
 front.rotation.x = deg_to_rad(-25.)
 front.position.z = .025
 terrace_floor314 = collider298(balcony313 + Vector3(0., -.10, -.09), Vector3(3.2, .16, 1.))
 terrace_shadow314 = MeshInstance3D.new()
 var ellipse := CylinderMesh.new()
 ellipse.top_radius = .25
 ellipse.bottom_radius = .25
 ellipse.height = .008
 terrace_shadow314.mesh = ellipse
 var shade := StandardMaterial3D.new()
 shade.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 shade.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
 shade.albedo_color = Color(.22, .13, .10, .35)
 terrace_shadow314.material_override = shade
 terrace_shadow314.position.y = .012
 terrace_shadow314.scale.z = .55
 terrace314.add_child(terrace_shadow314)
 for projection in battle.actor_shadows:
  if is_instance_valid(projection) and projection.visual == visual:
   projection.enabled = false
 sample(SHOW_END313)

func sample(t: float) -> void:
 super.sample(t)
 sync_scenery322()
 if use_pixel315 and t >= 4.60 and t < 4.88:
  pose316(5)
 if is_instance_valid(terrace314):
  girl.position.z = lerpf(balcony313.z - .72, balcony313.z, smoothstep(3.68, 4.02, t))
  terrace314.visible = castle.visible
  terrace314.position = balcony313 + Vector3.UP * castle.position.y
  terrace_shadow314.visible = t > 3.9
  terrace_floor314.get_parent().position.y = balcony313.y + castle.position.y - .1
  terrace_floor314.set_deferred("disabled", t < CASTLE_LAND313)
func actor_height313() -> float:
 return sister_height314

func pose(throwing: bool) -> void:
 if use_pixel315 and not frames316.is_empty():
  pose316(1 if throwing else 0)
  return
 super.pose(throwing)
 visual.pixel_size *= sister_height314 / 1.6

func setup_rescue_effects314() -> void:
 var texture := preload("res://assets/paper_stage314/rescue_poses.png")
 for i in 2:
  var frame := AtlasTexture.new()
  frame.atlas = texture
  frame.region = Rect2(i * 887., 0., 887., 887.)
  frame.filter_clip = true
  rescue_frames314.append(frame)
 for i in 3:
  var puff := card298(preload("res://assets/paper_stage314/black_smoke.png"), {"span": [524.], "foot": [766., 897.]}, 1.6, self)
  smoke314.append(puff)

func rescue_pose314(index: int) -> void:
 if use_pixel315:
  pose316(12 if index == 0 else 13)
  return
 balcony_pose313(rescue_frames314[index], Vector2(465. if index == 0 else 398.5, 854. if index == 0 else 841.), 827. if index == 0 else 816.)
 visual.material_override.albedo_texture = rescue_frames314[index].atlas


func pixel_pose315() -> void:
 if use_pixel315:
  pose316(0)
  return
 balcony_pose313(IDLE_PIXEL315, Vector2(541., 1375.), 1273.)
 visual.pixel_size *= .90

func idle_compare315() -> void:
 if use_pixel315:
  pixel_pose315()
 else:
  director_pose313(3)

func toggle_pixel315() -> void:
 use_pixel315 = not use_pixel315
 if battle.fall314 >= 4.45:
  collapse314(battle.fall314)
 elif finished and not playing and fold_clock314 < 0. and reaction_left313 <= 0.:
  idle_compare315()

# All poses share one pixel scale, calibrated to the approved smaller idle.
# Art frames stay intact; AtlasTexture selects cells without resampling PNGs.
func setup_frames316() -> void:
 for i in 16:
  var x := roundi(float(i % 4) * 313.5)
  var y := roundi(float(floori(i / 4.0)) * 313.5)
  var right := roundi(float(i % 4 + 1) * 313.5)
  var bottom := roundi(float(floori(i / 4.0) + 1) * 313.5)
  var frame := AtlasTexture.new()
  frame.atlas = GRIP319 if i in [13, 14] else ACTIONS316
  frame.region = Rect2(x, y, right - x, bottom - y)
  frame.filter_clip = true
  frames316.append(frame)

func pose316(index: int) -> void:
 frame316 = index
 var frame := frames316[index]
 var foot_x: float = [170., 168.5, 167.5, 159., 168.5, 168.5, 168.5, 162.5, 169., 168.5, 169.5, 169.5, 171., 169., 169., 170.][index]
 visual.texture = frame
 visual.pixel_size = .9 * actor_height313() / 288.
 visual.offset = Vector2(frame.get_width() * .5 - foot_x, 297. - frame.get_height() * .5)
 visual.material_override.albedo_texture = frame.atlas

func director_pose313(index: int) -> void:
 if use_pixel315:
  pose316([3, 4, 6, 7, 8, 9][index])
 else:
  super.director_pose313(index)

func balcony_pose313(texture: Texture2D, foot: Vector2, height: float) -> void:
 if use_pixel315 and texture == LEAN313:
  pose316(2)
 else:
  super.balcony_pose313(texture, foot, height)

func sample_entry313(t: float) -> void:
 super.sample_entry313(t)
 if use_pixel315 and t >= RELEASE313 and t < CATCH313:
  # The folded triangle leaves the new raised-paper hands, not the old art's hand.
  var old_hand := girl.position + Vector3(-.37, .86 * actor_height313() / 1.6, .29)
  var hand := girl.transform * Vector3(0., (297. - 172.) * visual.pixel_size, .29)
  packet313.position += (hand - old_hand) * (1. - smoothstep(RELEASE313, CATCH313, t))

const SUMMON_END317 := 3.6

func clear_summon317() -> void:
 if is_instance_valid(summon_preview317):
  summon_preview317.queue_free()
 summon_preview317 = null
 summon_card317 = null

func begin_summon317(card: CharacterBody3D) -> void:
 clear_summon317()
 summon_card317 = card
 card.enter301("rest")
 card.render301()
 card.set_physics_process(false)
 card.hit_area.collision_layer = 0
 card.hide()
 battle.enemies.erase(card)
 for projection in battle.actor_shadows:
  if is_instance_valid(projection) and projection.visual == card.visual:
   projection.enabled = false
 summon_preview317 = card.visual.duplicate() as Sprite3D
 add_child(summon_preview317)
 sample_summon317(0.)

func sample_summon317(t: float) -> void:
 if not is_instance_valid(summon_card317):
  return
 var card := summon_card317
 var hand := girl.transform * Vector3(0., 125. * .9 * actor_height313() / 288., .29)
 var target := to_local(card.to_global(card.visual.transform * card.tab302()))
 var caught := target + Vector3.UP * .85
 var flight := smoothstep(1.05, 1.72, t)
 var lower := smoothstep(1.72, SUMMON_END317, t)
 var attachment := hand.lerp(caught, flight) + Vector3.UP * sin(PI * flight) * .55
 if t >= 1.72:
  attachment = caught.lerp(target, lower) + Vector3.RIGHT * sin(PI * lower * 2.) * .15 * (1. - lower)
 var unfold := smoothstep(2.02, 2.85, t)
 packet313.visible = t >= 1.05 and t < 2.02
 packet313.position = attachment
 packet313.rotation = Vector3(0., 0., sin(flight * PI) * .3)
 summon_preview317.visible = t >= 2.02
 summon_preview317.basis = card.visual.global_basis.scaled(Vector3.ONE * lerpf(.06, 1., unfold))
 summon_preview317.position = attachment - summon_preview317.basis * card.tab302()
 var final_support := to_local(card.operator301.global_position)
 var support := (caught + Vector3.UP * .86).lerp(final_support, lower)
 var descent := smoothstep(.08, 1.72, t)
 handler313.show()
 handler313.position = offscreen_support313(caught + Vector3.UP * .86).lerp(support, descent)
 handler313.rotation.z = sin(descent * TAU) * .12 * (1. - lower)
 drift_handler313(HANDLER_ENTER313 + t)
 line313.visible = t >= 1.72
 if line313.visible:
  line_mesh313.clear_surfaces()
  line_mesh313.surface_begin(Mesh.PRIMITIVE_LINES)
  line_mesh313.surface_add_vertex(attachment)
  line_mesh313.surface_add_vertex(handler313.transform * (Vector3.UP * .08))
  line_mesh313.surface_end()

func finish_summon317() -> void:
 if is_instance_valid(summon_card317):
  var card := summon_card317
  card.show()
  card.hit_area.collision_layer = 8
  card.set_physics_process(true)
  if not battle.enemies.has(card):
   battle.enemies.append(card)
  for projection in battle.actor_shadows:
   if is_instance_valid(projection) and projection.visual == card.visual:
    projection.enabled = true
  card.reset_physics_interpolation()
 clear_summon317()
 clear_demo314()
