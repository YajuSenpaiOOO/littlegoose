extends "res://scripts/art/paper_stage298.gd"

const FOOT313 := Vector2(837.5, 927.)
const BALCONY313 := Vector2(887., 603.)

const CASTLE_DROP313 := 1.60
const CASTLE_LAND313 := 2.42
const SHOW_END313 := 7.65
const RELEASE313 := 5.12
const CATCH313 := 5.76
const HANDLER_ENTER313 := 3.42
const DRIFT_SEQUENCE313 := [0, 1, 2, 3, 2, 1]
const UNFOLD313 := 6.02
const LEAN313 := preload("res://assets/paper_stage300/lean.png")
const DIRECTOR313 := preload("res://assets/paper_stage313/director_poses.png")
var director_frames313: Array[AtlasTexture] = []
var reaction_left313 := 0.
var balcony313 := Vector3.ZERO
var lift_floor313 := 0.
var backdrop_slots313: Array[Vector3] = []
var packet313: Sprite3D
var handler313: Sprite3D
var handler_drift313: Array[Dictionary] = []
var handler_frame313 := -1
var dinosaur313: Sprite3D
var line313: MeshInstance3D
var line_mesh313 := ImmediateMesh.new()

func _ready() -> void:
 castle = card298(preload("res://assets/paper_stage313/castle.png"), {"span": [1307.], "foot": [FOOT313.x, FOOT313.y]}, 10.5, self)
 castle.rotation.x = deg_to_rad(-25.)
 shadow298(castle, self)
 # The closed facade has a shallow footprint. The drawn terrace is scenery.
 bodies.append(collider298(Vector3(0., .75, 0.), Vector3(10.3, 1.7, .35)))
 girl = Girl.new()
 add_child(girl)
 visual = Sprite3D.new()
 visual.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
 visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var receiver := battle.hero.visual.material_override.duplicate() as StandardMaterial3D
 receiver.next_pass = null
 # The elevated paper actor gets more direct sun than the hero on the grass.
 receiver.albedo_color = Color(.68, .68, .68)
 visual.material_override = receiver
 girl.add_child(visual)
 var foot_offset := Vector3(BALCONY313.x - FOOT313.x, FOOT313.y - BALCONY313.y, 0.)
 balcony313 = castle.transform * (foot_offset * castle.pixel_size) + Vector3(0., 0., -.035)
 lift_floor313 = ground298(balcony313.x, balcony313.z)
 battle._add_actor_shadow(girl, visual)
 add_backdrop313(preload("res://assets/paper_stage298/scenery.png"), layout298.scenery, 3.1, Vector2(-4.15, 1.15))
 add_backdrop313(preload("res://assets/paper_stage313/volcano.png"), {"span": [1283.], "foot": [767.5, 930.]}, 2.9, Vector2(4.55, 1.55))
 for i in 6:
  var frame := AtlasTexture.new()
  frame.atlas = DIRECTOR313
  frame.region = Rect2(float(i % 3) * 512., 512. if i >= 3 else 0., 512., 512.)
  frame.filter_clip = true
  director_frames313.append(frame)
 setup_entry313()
 sample(SHOW_END313)

func add_backdrop313(texture: Texture2D, spec: Dictionary, width: float, at: Vector2) -> void:
 var panel := card298(texture, spec, width, self)
 panel.rotation.x = deg_to_rad(-25.)
 wings298.append(panel)
 backdrop_slots313.append(Vector3(at.x, ground298(at.x, at.y), at.y))
 shadow298(panel, self)

func drop313(t: float, start_at: float, duration: float, height: float) -> float:
 var progress := clampf((t - start_at) / duration, 0., 1.)
 var elapsed := maxf(0., t - start_at - duration)
 return height * (1. - progress * progress * progress) - .045 * sin(elapsed * 24.) * exp(-elapsed * 11.)

func sample(t: float) -> void:
 age = t
 castle.visible = t >= CASTLE_DROP313
 castle.position.y = drop313(t, CASTLE_DROP313, CASTLE_LAND313 - CASTLE_DROP313, 11.)
 bodies[0].set_deferred("disabled", t < CASTLE_LAND313)
 for i in wings298.size():
  var begin := .72 + float(i) * .37
  var panel := wings298[i]
  panel.visible = t >= begin
  panel.position = backdrop_slots313[i] + Vector3.UP * drop313(t, begin, .49, 9.)
 # She casts from the lift's ground position. The descending facade masks the
 # change of pose, and the opaque wall masks the lower part of the lift.
 # Keep the sprite present throughout. The actual facade depth hides it.
 var rise := .79 * smoothstep(2.65, 3.38, t) + .21 * smoothstep(3.68, 4.02, t)
 girl.position = Vector3(balcony313.x, lerpf(lift_floor313, balcony313.y, rise), balcony313.z)
 if t < CASTLE_LAND313:
  pose(t >= .48)
 elif t < 4.02:
  balcony_pose313(LEAN313, Vector2(541.5, 1391.), 1284.)
 elif t < 4.31:
  director_pose313(0)
 elif t < 4.88:
  director_pose313(1)
 elif t < RELEASE313:
  director_pose313(2)
 else:
  director_pose313(3)
 sample_entry313(t)

func balcony_pose313(texture: Texture2D, foot: Vector2, height: float) -> void:
 visual.texture = texture
 visual.pixel_size = actor_height313() / height
 visual.offset = Vector2(texture.get_width() * .5 - foot.x, foot.y - texture.get_height() * .5)
 visual.material_override.albedo_texture = texture

func director_pose313(index: int) -> void:
 var foot_x: float = [287., 256., 224.][index % 3]
 balcony_pose313(director_frames313[index], Vector2(foot_x, 470.), 461.)
 visual.material_override.albedo_texture = DIRECTOR313

func reaction313(index: int) -> void:
 if finished and not playing:
  director_pose313(index)
  reaction_left313 = .85

func start() -> void:
 reaction_left313 = 0.
 super.start()

func _process(delta: float) -> void:
 if not playing:
  if finished and handler313.visible:
   age += delta
   drift_handler313(age)
  if reaction_left313 > 0.:
   reaction_left313 = maxf(0., reaction_left313 - delta)
   if reaction_left313 == 0.:
    director_pose313(3)
  return
 var before := age
 sample(minf(age + delta, SHOW_END313))
 if before < CASTLE_LAND313 and age >= CASTLE_LAND313:
  battle.trauma = maxf(battle.trauma, .07)
 if age >= SHOW_END313:
  cancel()
  finished = true

func setup_entry313() -> void:
 var specs: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/paper_cards301/layout.json"))
 var spec: Dictionary = specs.dinosaur
 var texture := preload("res://assets/paper_cards301/dinosaur.png")
 dinosaur313 = card298(texture, {"span": spec.span, "foot": spec.tab}, 2.1 * float(spec.span[0]) / float(spec.span[1]), self)
 dinosaur313.material_override = battle.hero.visual.material_override.duplicate()
 dinosaur313.material_override.next_pass = null
 dinosaur313.material_override.albedo_color = Color(.7, .7, .7)
 dinosaur313.material_override.albedo_texture = texture
 shadow298(dinosaur313, self)
 var operator_texture := preload("res://assets/paper134/base_C.png")
 handler313 = card298(operator_texture, {"span": [1019.], "foot": [593.5, 1205.]}, 1., self)
 var animation: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/paper134/animation.json"))
 for frame in animation.drift:
  handler_drift313.append({"texture": load(frame.texture), "foot": frame.foot, "pixel_size": float(frame.scale) / float(animation.base.scale) / 1019.})
 var ink := StandardMaterial3D.new()
 ink.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 ink.albedo_color = Color("f1d8a7")
 ink.cull_mode = BaseMaterial3D.CULL_DISABLED
 packet313 = card298(preload("res://assets/paper_stage313/folded_packet.png"), {"span": [772.], "foot": [767., 265.]}, .44, self)
 line313 = MeshInstance3D.new()
 line313.mesh = line_mesh313
 line313.material_override = ink
 line313.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 add_child(line313)

func sample_entry313(t: float) -> void:
 var hand := girl.position + Vector3(-.37, .86 * actor_height313() / 1.6, .29)
 var caught := Vector3(1.62, 3.25, 2.12)
 var settled := Vector3(1.82, ground298(1.82, 3.55) + 2.62, 3.55)
 var flight := smoothstep(RELEASE313, CATCH313, t)
 var lower := smoothstep(CATCH313, 7.32, t)
 var attachment := hand.lerp(caught, flight) + Vector3.UP * sin(PI * flight) * .63
 if t >= CATCH313:
  var swing := sin(lower * TAU) * .23
  attachment = caught.lerp(settled, lower) + Vector3(swing, 0., 0.)
 var unfold := smoothstep(UNFOLD313, 6.72, t)
 packet313.visible = t >= RELEASE313 and t < UNFOLD313
 packet313.position = attachment
 packet313.rotation = Vector3(-.32, 0., .15 + sin(flight * PI) * .48)
 dinosaur313.visible = t >= UNFOLD313
 dinosaur313.position = attachment
 dinosaur313.scale = Vector3(lerpf(.12, 1., unfold), lerpf(.17, 1., unfold), 1.)
 dinosaur313.rotation.z = sin(lower * TAU) * .12
 handler313.visible = t >= HANDLER_ENTER313
 var descent := smoothstep(HANDLER_ENTER313, CATCH313, t)
 var support := (caught if t < CATCH313 else attachment) + Vector3.UP * .86
 var start := offscreen_support313(caught + Vector3.UP * .86)
 var sway := sin(descent * TAU * 1.5) * sin(descent * PI) * .23
 handler313.position = start.lerp(support, descent) + Vector3.RIGHT * sway
 handler313.rotation.z = sway * .55 + dinosaur313.rotation.z * .45
 if handler313.visible:
  drift_handler313(t)
 line313.visible = t >= CATCH313
 if line313.visible:
  line_mesh313.clear_surfaces()
  line_mesh313.surface_begin(Mesh.PRIMITIVE_LINES)
  line_mesh313.surface_add_vertex(attachment)
  line_mesh313.surface_add_vertex(handler313.transform * (Vector3.UP * .08))
  line_mesh313.surface_end()

func offscreen_support313(catch_point: Vector3) -> Vector3:
 var camera: Camera3D = battle.camera
 var viewport := camera.get_viewport().get_visible_rect().size
 var depth := -camera.to_local(to_global(catch_point)).z
 var screen_x := camera.unproject_position(to_global(catch_point)).x + viewport.x * .035
 return to_local(camera.project_position(Vector2(screen_x, -viewport.y * .14), depth))

func drift_handler313(t: float) -> void:
 var phase := int((t - HANDLER_ENTER313) / .22) % DRIFT_SEQUENCE313.size()
 var index: int = DRIFT_SEQUENCE313[phase]
 if index == handler_frame313:
  return
 handler_frame313 = index
 var frame := handler_drift313[index]
 handler313.texture = frame.texture
 handler313.material_override.albedo_texture = frame.texture
 handler313.pixel_size = frame.pixel_size
 var size := handler313.texture.get_size()
 handler313.offset = Vector2(size.x * .5 - frame.foot[0], frame.foot[1] - size.y * .5)
func actor_height313() -> float:
 return 1.6
