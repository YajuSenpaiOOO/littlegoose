extends "res://scripts/combat/silk_ball171.gd"
var dodged172 := false
var previous172 := Vector3.ZERO
func _ready() -> void:
 super._ready();previous172=position
func _physics_process(delta: float) -> void:
 if not battle.combat_paused: previous172=position
 super._physics_process(delta)
func defense171(before: Vector3) -> bool:
 var hero: CharacterBody3D=battle.hero
 if absf(position.y-hero.position.y)>.65: return false
 var player := Vector2(hero.position.x,hero.position.z)
 if hero.can_parry():
  var contact: float=battle.aim_model.sweep_circle(Vector2(before.x,before.z),Vector2(position.x,position.z),player,hero.PARRY_REACH)
  if contact<INF:
   retire171("parry")
   battle.parry_success(hero.position+Vector3.UP*.5,Vector3(-direction171.x,0.,-direction171.y));return true
 if hero.dodge_invulnerability>0.:
  var crossed: float=battle.aim_model.sweep_circle(Vector2(before.x,before.z),Vector2(position.x,position.z),player,.70)
  if crossed<INF:
   if hero.dash_eligible and not dodged172:
    hero.dash_eligible=false;dodged172=true;battle.perfect_dodge()
   retire171("dodge");return true
 return false
