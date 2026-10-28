extends "res://scripts/combat/hero36.gd"
const GUARD_DAMAGE109 := .60
var guarding109 := false
var guard_hits109 := 0
func movement_input() -> Vector2:
 return Vector2.ZERO if guarding109 else super.movement_input()
func request_parry() -> bool:
 if guarding109: return false
 if not super.request_parry(): return false
 guarding109=true;parry_cd=0.;locomotion=Vector2.ZERO
 velocity.x=combat_impulse.x;velocity.z=combat_impulse.y;render_pose();return true
func release_guard109() -> void:
 if not guarding109: return
 guarding109=false;parry_cd=PARRY_GATE if parried else PARRY_CD
 render_pose()
func cancel_guard109() -> void:
 release_guard109();parry_t=0.;parry_previous=parry_key_down()
func request_dash(direction := Vector2.ZERO) -> bool:
 if guarding109: return false
 return super.request_dash(direction)
func can_parry() -> bool:
 return not parried and super.can_parry()
func consume_parry() -> void:
 super.consume_parry()
 if guarding109: parry_cd=0.
func reset_actions() -> void:
 guarding109=false;super.reset_actions();guard_hits109=0
func _notification(what: int) -> void:
 super._notification(what)
 if what==NOTIFICATION_WM_WINDOW_FOCUS_OUT and is_instance_valid(battle): cancel_guard109()
func _physics_process(delta: float) -> void:
 var pressed := parry_key_down()
 var fresh := false
 if battle.combat_paused or not controls_enabled or knocked_down or story_knocked or battle.player_hp<=0.:
  if guarding109: cancel_guard109()
  parry_previous=pressed
  if battle.combat_paused: return
 else:
  if guarding109 and not pressed: release_guard109()
  if pressed and not parry_previous: fresh=request_parry()
 # Parent still owns the original 0.18s perfect window, whiff, spring and dash.
 # Feed it the sampled edge once so holding cannot start a second window.
 parry_previous=pressed
 if guarding109: parry_cd=0.;locomotion=Vector2.ZERO
 # The old controller opens its window AFTER decrementing timers on this tick.
 if fresh: parry_t+=delta
 super._physics_process(delta)
 if guarding109: parry_cd=0.
func render_pose() -> void:
 super.render_pose()
 if not guarding109 or knocked_down or story_knocked or not is_instance_valid(battle) or battle.player_hp<=0. or not parry_art.has(parry_facing): return
 var pose: Dictionary=parry_art[parry_facing]
 visual.texture=pose.texture;visual.flip_h=false
 visual.pixel_size=float(pose.world_height)/float(pose.body_height)/motion_pixels_per_m
 visual.offset=Vector2(visual.texture.get_width()*.5-float(pose.foot[0]),float(pose.foot[1])-visual.texture.get_height()*.5)
 visual.position=Vector3.ZERO;visual.rotation=Vector3.ZERO
 var breath := sin(body_clock*PI*1.8)*.006
 visual.scale=Vector3(1.+parry_squash.x-breath,1.+parry_squash.y+breath,1.)
