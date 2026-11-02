extends "res://scripts/combat/tuantuan121.gd"
var rig220: Node3D
var index220 := 0
var enabled220 := false
var flash220 := 0.
func _ready() -> void:
 super._ready()
 collision_layer=0;collision_mask=0
 cue.set_process(false);cue.hide();small_cue.set_process(false);small_cue.hide();shadow.hide();health_fill.hide()
 var old=visual;visual=rig220.bats[index220];old.queue_free()
 var capsule: CapsuleShape3D=hit_area.get_child(0).shape;capsule.radius=.32;capsule.height=.64;hit_area.position=Vector3.ZERO
 max_hp110=32.;hp=32.;dead=true;hit_area.collision_layer=0
 poses={"idle":{"visible_width":20.,"visible_height":18.}};textures={"idle":visual.texture}
func set_enabled220(value: bool) -> void:
 enabled220=value and hp>0.;dead=not enabled220;hit_area.collision_layer=8 if enabled220 else 0
func receive_hit(damage: float,_direction: Vector3) -> void:
 if not enabled220 or hp<=0.:return
 var before=hp
 hp=maxf(0.,hp-damage);hit_count+=1;flash220=.12
 if battle.has_method("record_enemy_damage226"):battle.record_enemy_damage226(self,before-hp)
 var contact=impact_contact if impact_contact.is_finite() else visual.global_position
 battle.on_legacy_contact(self,contact,_direction,false);impact_contact=Vector3.INF
 if hp<=0.:
  set_enabled220(false);battle.bat_down220(index220)
func attachment_frame154() -> Dictionary:
 return preload("res://scripts/combat/plush_surface221.gd").frame(visual)
func _physics_process(delta: float) -> void:
 if not is_instance_valid(rig220):return
 global_position=visual.global_position+battle.camera.global_basis.y*.18
 velocity=Vector3.ZERO;flash220=maxf(0.,flash220-delta)
 visual.modulate=Color(1.2,.8,.8) if flash220>0. else Color.WHITE
