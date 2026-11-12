extends "res://scripts/art/paper_stage314.gd"

const CANNON326 := preload("res://assets/paper_stage326/cannon.png")
var cannons326: Array[Sprite3D] = []
var cannon_areas326: Array[Area3D] = []
var cannon_frames326: Array[AtlasTexture] = []
var cannon_flash326: Array[float] = [0., 0.]
var shock326: MeshInstance3D
var shock_mesh326 := ImmediateMesh.new()

func _ready() -> void:
 super._ready()
 for i in 2:
  var frame := AtlasTexture.new()
  frame.atlas = CANNON326
  frame.region = Rect2(i * 887., 0., 887., 887.)
  frame.filter_clip = true
  cannon_frames326.append(frame)
 for i in 2:
  var foot := Vector3(-3.45 if i == 0 else 3.2, 0., 1.15)
  foot.y = ground298(foot.x, foot.z)
  var cannon := card298(cannon_frames326[0], {"span":[694.], "foot":[454.,825.]}, 1.5, self)
  cannon.material_override.albedo_texture = CANNON326
  cannon.position = foot
  cannon.rotation.x = deg_to_rad(-25.)
  cannons326.append(cannon)
  shadow298(cannon, self)
  add_scenery_body322(cannon, foot, Vector3(1., .4, .7))
  var area := Area3D.new()
  area.collision_mask = 0
  area.monitoring = false
  area.position = foot + Vector3(0., .65, .12)
  var holder := CollisionShape3D.new()
  var box := BoxShape3D.new()
  box.size = Vector3(.85, 1.1, .5)
  holder.shape = box
  area.add_child(holder)
  add_child(area)
  cannon_areas326.append(area)
 shock326 = MeshInstance3D.new()
 shock326.mesh = shock_mesh326
 shock326.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var ink := StandardMaterial3D.new()
 ink.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 ink.vertex_color_use_as_albedo = true
 ink.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
 ink.cull_mode = BaseMaterial3D.CULL_DISABLED
 shock326.material_override = ink
 add_child(shock326)
 enable_cannons326(false)
 boom314.pixel_size *= 4.4 / 2.6

func reset_battle314() -> void:
 super.reset_battle314()
 enable_cannons326(false)
 for cannon in cannons326:
  cannon.texture = cannon_frames326[0]
  cannon.offset = Vector2(443.5 - 454., 825. - 443.5)
  cannon.scale = Vector3.ONE
 cannon_flash326 = [0., 0.]
 draw_shock326(Vector2.ZERO, 0., 0.)

func _process(delta: float) -> void:
 super._process(delta)
 if battle.combat_paused:
  return
 if battle.entry_clock314 >= 0. and reaction_left313 <= 0.:
  var t: float = SUMMON_END317 - battle.entry_clock314
  director_pose313(0 if t < .27 else (1 if t < .7 else (2 if t < 1.05 else 3)))
 for i in cannons326.size():
  cannon_flash326[i] = maxf(0., cannon_flash326[i] - delta)
  var recoil := sin(cannon_flash326[i] / .2 * PI)
  cannons326[i].scale = Vector3.ONE * (1. - recoil * .1)
  cannons326[i].material_override.albedo_color = Color(.95,.8,.65) if cannon_flash326[i] > 0. else Color(.7,.7,.7)

func enable_cannons326(enabled: bool) -> void:
 for i in cannons326.size():
  cannons326[i].visible = enabled
  cannon_areas326[i].set_deferred("collision_layer", 8 if enabled and battle.cannon_hp326[i] > 0. else 0)
 sync_scenery322()

func recoil_cannon326(index: int) -> void:
 cannon_flash326[index] = .2

func break_cannon326(index: int) -> void:
 var cannon := cannons326[index]
 cannon.texture = cannon_frames326[1]
 cannon.offset.x = 443.5 - 410.
 cannon_areas326[index].set_deferred("collision_layer", 0)
 battle.grid111.call_deferred("invalidate")
 battle.structure_contact326(cannon.global_position + Vector3.UP * .7, Vector3.UP, true)

func aim_cannon326(index: int, aiming: bool) -> void:
 if index >= cannons326.size() or battle.cannon_hp326[index] <= 0.:
  return
 cannons326[index].rotation.z = sin(Time.get_ticks_msec() * .018) * .035 if aiming else 0.

func make_shell326(at: Vector3) -> Sprite3D:
 var shell := card298(preload("res://assets/paper_stage313/folded_packet.png"), {"span":[772.],"foot":[767.,265.]}, .38, self)
 shell.global_position = at
 return shell

func draw_shock326(at: Vector2, radius: float, alpha: float) -> void:
 if not is_instance_valid(shock326):
  return
 shock326.visible = alpha > 0.
 shock_mesh326.clear_surfaces()
 if alpha <= 0.:
  return
 shock_mesh326.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 48:
  var a := TAU * float(i) / 48.
  var b := TAU * float(i + 1) / 48.
  var corners: Array[Vector3] = []
  for spec in [Vector2(a,radius), Vector2(b,radius), Vector2(a,maxf(0.,radius-.14)), Vector2(b,maxf(0.,radius-.14))]:
   var p: Vector2 = at + Vector2(cos(spec.x), sin(spec.x)) * spec.y
   corners.append(to_local(Vector3(p.x, battle.floor_height(p) + .045, p.y)))
  for corner in [0,1,2,2,1,3]:
   shock_mesh326.surface_set_color(Color(1.,.76,.43,alpha))
   shock_mesh326.surface_add_vertex(corners[corner])
 shock_mesh326.surface_end()
