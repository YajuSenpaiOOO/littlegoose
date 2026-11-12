extends "res://scripts/combat/tuantuan_minion264.gd"
var entry_origin266 := Vector2.ZERO
func _ready() -> void:
 super._ready();entry_origin266=Vector2(position.x,position.z)
func targetable260() -> bool:
 return super.targetable260() or (not dead and battle.mode264=="ordinary" and state260=="arrive")
func _physics_process(delta: float) -> void:
 if not battle.combat_paused and battle.active114 and battle.mode264=="ordinary" and state260=="rustle":clock260+=delta*1.5
 if dead and state260 in ["rustle","arrive"]:state260="ground"
 super._physics_process(delta)
 if dead or battle.combat_paused or battle.mode264!="ordinary" or state260!="arrive":return
 hit_area.collision_layer=8
 if self not in battle.enemies:battle.target_minion260(self,true)
 health_fill.visible=health_time>0.
 var at=Vector2(position.x,position.z);var player=Vector2(battle.hero.position.x,battle.hero.position.z)
 # Real travel only: become a normal combatant at the field edge instead of finishing a long ceremonial route.
 if at.distance_to(entry_origin266)>=.9 and (at.distance_to(player)<=4.6 or at.distance_to(battle.meadow.landmarks.grove)<=6.):
  ground260();battle.entry_complete261(self)
