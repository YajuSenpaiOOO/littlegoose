extends "res://scripts/combat/paper131.gd"
func _ready() -> void:
 super._ready()
 # Paper sheets cross each other. Terrain/props/player and projectile hit areas remain.
 collision_mask=1|2
func separation132(at: Vector2) -> Vector2:
 if paper_state129 not in ["drift","coast"]: return Vector2.ZERO
 var force := Vector2.ZERO
 for other in battle.enemies:
  if other==self or not is_instance_valid(other) or other.dead or not other.active_ai: continue
  if not other.has_method("separation132") or absf(paper_lift129-other.paper_lift129)>.60: continue
  var away: Vector2= at-Vector2(other.position.x,other.position.z)+(drift130-other.drift130)*.20
  var distance: float= away.length()
  if distance>=1.45: continue
  var direction: Vector2= away/distance if distance>.025 else Vector2.ZERO
  if direction==Vector2.ZERO:
   # Stable opposing directions also separate exactly coincident sheets.
   var low := mini(get_instance_id(),other.get_instance_id())
   var high := maxi(get_instance_id(),other.get_instance_id())
   direction=Vector2.from_angle(float((low*31+high*17)%628)/100.)
   if get_instance_id()>other.get_instance_id(): direction=-direction
  force+=direction*pow(1.-distance/1.45,2.)*.95
 return force.limit_length(.72)
func _wind_motion130(at: Vector2,player: Vector2) -> Vector2:
 return (super._wind_motion130(at,player)+separation132(at)).limit_length(2.7)

