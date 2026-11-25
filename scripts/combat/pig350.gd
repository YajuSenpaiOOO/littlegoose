extends "res://scripts/combat/tuantuan110.gd"
var kind301:="pig"
var model350: Node3D
var cotton350: Node3D
var death350:=0.
func _ready() -> void:
 super._ready()
 visual.hide()
 model350=preload("res://scripts/art/pig_model350.gd").new();model350.world=battle;model350.manual219=true
 var heading: Vector3=battle.hero.global_position-global_position
 model350.direction219=Vector2(heading.x,heading.z).normalized()
 add_child(model350)
 model350.body.collision_layer=0;model350.body.collision_mask=0
 visual=model350.visual
 cotton350=preload("res://scripts/combat/cotton350.gd").new();cotton350.world=battle;cotton350.pig=model350;cotton350.manual219=true
 add_child(cotton350);model350.stream=cotton350
 var target:=CapsuleShape3D.new();target.radius=.65;target.height=1.3
 hit_area.get_child(0).shape=target;hit_area.position.y=.6
 # Fixed lane chosen at placement, never tracks the player during spray.

func _physics_process(delta: float) -> void:
 if battle.combat_paused or not battle.active114:return
 if dead:
  death350+=delta;model350.age219=death350;model350.update_pose219()
  cotton350.advance219(delta)
  if death350>1.9:queue_free()
  return
 health_time=maxf(0.,health_time-delta)
 model350.advance219(delta);cotton350.advance219(delta)
func receive_hit(damage: float,direction: Vector3) -> void:
 if dead:return
 hp=maxf(0.,hp-damage);health_time=1.5
 battle.on_legacy_contact(self,global_position+Vector3.UP*.5,direction,false)
 if hp<=0.:
  dead=true;hit_area.set_deferred("collision_layer",0);collision_layer=0
  model350.flatten219();model350.running219=false
  battle.enemy_defeated(self)
