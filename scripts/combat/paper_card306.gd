extends "res://scripts/combat/paper_card305.gd"

var operator_frames306: Dictionary = {}
var operator_pose306 := ""
var operator_anchor306 := Vector3.ZERO

func _ready() -> void:
 super._ready()
 var animation: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/paper134/animation.json"))
 for group in ["drift", "attack"]:
  for index in animation[group].size():
   var frame: Dictionary = animation[group][index]
   operator_frames306[group + str(index)] = {"texture": load(frame.texture), "foot": frame.foot, "scale": frame.scale / animation.base.scale}

 render301()

func draw_cue301() -> void:
 if ground_cue306():
  super.draw_cue301()
 else:
  cue301.hide()

func ground_cue306() -> bool:
 return battle.ground_cues306

func pose302() -> void:
 super.pose302()
 if operator_frames306.is_empty():
  return
 var sequence := [0, 1, 2, 3, 2, 1]
 var drift_frame: int = sequence[int((age + role110 * .31) / .22) % sequence.size()]
 var key := "drift" + str(drift_frame)
 var bank := sin(age * 4. + role110) * .12
 if kind301 == "knight":
  if state301 == "warn":
   var brace := smoothstep(charge_duration304() - .20, charge_duration304() - .07, clock301)
   var side := -1. if direction301.x < 0. else 1.
   key = charge_pose306(key)
   if key.begins_with("attack"):bank = -side * lerpf(.14, .32, brace)
   visual.rotation.z = side * .23 * brace
   hit_area.position = visual.transform * Vector3(0, height301 * .5, 0)
   hit_area.rotation.z = visual.rotation.z
  elif state301 == "attack" and clock301 < .28:
   key = "attack2"
  elif state301 == "stunned" or (state301 == "attack" and clock301 < .56):
   key = "attack3"
 if key != operator_pose306:
  operator_pose306 = key
  var frame: Dictionary = operator_frames306[key]
  operator301.texture = frame.texture
  operator301.material_override.albedo_texture = frame.texture
  operator301.pixel_size = frame.scale / 1019.
  var size: Vector2 = frame.texture.get_size()
  operator301.offset = Vector2(size.x * .5 - frame.foot[0], frame.foot[1] - size.y * .5)
 operator301.rotation.z = bank
 operator_anchor306 = operator301.transform * (Vector3.UP * .08)

func thread_support302() -> Vector3:
 if operator_frames306.is_empty():
  return super.thread_support302()
 return operator_anchor306

func contact_damage303() -> float:
 if kind301 == "knight" and state301 == "attack" and clock301 < .28 and ring_velocity304.dot(direction301) > 0.:
  return 2.
 return super.contact_damage303()

func deflect(contact: Vector3) -> void:
 var previous: float = battle.parry_threat306
 battle.parry_threat306 = contact_damage303()
 super.deflect(contact)
 battle.parry_threat306 = previous

func charge_pose306(_drift_pose: String) -> String:
 return "attack1" if clock301 >= 1.15 else "attack0"
