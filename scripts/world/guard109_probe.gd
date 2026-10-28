extends "res://scripts/world/woodland108_probe.gd"
class GuardHero:
 extends "res://scripts/combat/hero109.gd"
 var button := false
 var wish := Vector2.ZERO
 func parry_key_down() -> bool: return button and controls_enabled
 func movement_input() -> Vector2: return Vector2.ZERO if guarding109 else wish
 func dash_key_down() -> bool: return false
class Sample109:
 extends "res://scripts/world/woodland_world109.gd"
 func _hero_script() -> Script: return GuardHero
 func fire_input_held() -> bool: return false
 func start_combat(_reposition := true) -> void: pass
func run() -> void:
 var sample := Sample109.new();root.add_child(sample)
 while not sample.woodland_ready109: await physics_frame
 var g: Vector2=sample.meadow.landmarks.grove
 sample._teleport15(g+Vector2(0,2));sample.hero.controls_enabled=true;sample.wave_state="fighting";sample.invulnerability=0.;await settle72(20)
 var h: CharacterBody3D=sample.hero;h.set_physics_process(false);sample.set_physics_process(false)
 for direction in ["down","left","right","up"]:
  h.button=false;h.reset_actions();h.facing=direction;h.button=true;h._physics_process(1./60.)
  var start: Vector3=h.position;h.wish=Vector2.RIGHT
  for i in 120: h._physics_process(1./60.)
  verify(h.guarding109 and h.parry_cd==0. and h.parry_t==0. and h.parry_starts==1,"two-second hold stays planted, CD frozen, no perfect-window rearm: "+direction)
  verify(Vector2(h.position.x-start.x,h.position.z-start.z).length()<.02,"held guard rejects movement: "+direction)
  verify(h.visual.texture==h.parry_art[direction].texture,"authored crouch persists after perfect window: "+direction)
  verify(not h.request_dash(Vector2.RIGHT),"guard cannot dash-cancel while right is held")
  h.wish=Vector2.ZERO;h.button=false;h._physics_process(1./60.)
  verify(not h.guarding109 and h.parry_cd>.96,"release starts the miss cooldown")
 h.button=false;h.reset_actions();h.button=true;h._physics_process(1./60.)
 verify(h.can_parry() and absf(h.parry_t-.18)<.0001,"fresh press retains the original 0.18-second perfect catch")
 h.consume_parry();verify(not h.can_parry() and h.parry_cd==0.,"success is consumed once and CD still waits for release")
 for i in 90: h._physics_process(1./60.)
 verify(h.parry_starts==1 and not h.can_parry(),"holding after success never generates another perfect parry")
 h.button=false;h._physics_process(1./60.);verify(h.parry_cd>0. and h.parry_cd<=.06,"successful release retains the old short success gate")
 await settle72(3);h.button=false;h.reset_actions();h.button=true;h._physics_process(1./60.);h._physics_process(.2)
 sample.player_hp=100.;sample.invulnerability=0.;h.dodge_invulnerability=0.
 sample.hurt_player(20.,g+Vector2(0,-2))
 verify(sample.player_hp==88. and h.guard_hits109==1,"expired-window hold takes 12 of 20 damage; it is not invulnerability")
 sample.invulnerability=0.;sample.hurt_player(20.,g+Vector2(0,-2));verify(sample.player_hp==76.,"a second attack can hurt the held guard again")
 sample.combat_paused=true;h._physics_process(.016);verify(not h.guarding109 and h.parry_t==0.,"pause cancels guard without granting a new perfect window")
 sample.combat_paused=false;h.button=false;h.reset_actions();h.button=true;h._physics_process(.016);h._notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
 verify(not h.guarding109 and h.parry_t==0.,"focus loss clears the crouch state safely")
 h.button=false;h.reset_actions();h.button=true;h._physics_process(.016);sample.invulnerability=0.;sample.player_hp=1.;sample.hurt_player(20.,g)
 verify(sample.player_hp==0. and not h.guarding109 and h.knocked_down,"lethal guarded hit enters the original knocked-down pose")
 sample.player_hp=100.;sample.hurt_flash=0.;h.visual.modulate=Color.WHITE;h.controls_enabled=true;sample.wave_state="fighting";h.knocked_down=false;h.button=false;h.reset_actions();h.button=true;h._physics_process(.016);sample.hero.render_pose()
 sample.label.get_parent().hide();sample.frames66.panel.hide();sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look();await settle72(15)
 var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/guard109_held.png")
 var data := {"checks":checks,"failures":failures};var f := FileAccess.open("res://docs/guard109-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify(data,"\t"));print("GUARD109 ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
