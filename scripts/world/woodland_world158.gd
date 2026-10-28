extends "res://scripts/world/woodland_world154.gd"
func _sword_manager153() -> Script: return preload("res://scripts/combat/balloon_sword158.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 158 · A气球剑 / 黏液摊开 / 啵与回弹")
func _ready() -> void:
 super._ready()
 while not is_instance_valid(swords153): await get_tree().physics_frame
 if "--sword158" in OS.get_cmdline_user_args(): trial152=true;paper_trial129=false;start_combat()
func _apply_shot_hit(shot: Dictionary,hit: Dictionary) -> void:
 if shot.get("sword153",false) and not hit.collider.has_meta("enemy"):
  blocks+=1;notify_miss();swords153.attach153(null,hit.position,shot.velocity.normalized(),float(shot.get("sword_gain153",1.)),hit);return
 super._apply_shot_hit(shot,hit)
 if shot.get("sword153",false) and hit.collider.has_meta("enemy"):
  var enemy: Variant=hit.collider.get_meta("enemy")
  if is_instance_valid(enemy) and enemy.dead:
   swords153.contact158.pop158(hit.position,shot.velocity.normalized(),enemy.get_instance_id(),float(shot.get("sword_gain153",1.)))
func on_legacy_contact(enemy: CharacterBody3D,at: Vector3,direction: Vector3,juice: bool) -> void:
 if not sword_contact154: super.on_legacy_contact(enemy,at,direction,juice);return
 feedback_count+=1
 if is_instance_valid(feedback): feedback.marker=.13
 if not cup_contact_active: notify_hit()
 if enemy.dead: Audio.play_tuantuan("down")
