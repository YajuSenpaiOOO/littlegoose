extends "res://scripts/world/balloon_sword153_probe.gd"
class Walker160:
 extends "res://scripts/combat/hero146.gd"
 var guard160 := false
 func movement_input() -> Vector2: return Vector2.ZERO
 func parry_key_down() -> bool: return guard160 and controls_enabled
 func dash_key_down() -> bool: return false
class Trial160:
 extends "res://scripts/world/woodland_world160.gd"
 func _hero_script() -> Script: return Walker160
 func fire_input_held() -> bool: return false
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial160.new();s.memory_save116="user://pillow160_probe_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.pillow160): await physics_frame
 s.hill_visited136=true;s.trial152=true;s.paper_trial129=false;s.start_combat();disable_enemies(s);s.clear_standby119();s.hero.controls_enabled=true
 var g: Vector2=s.meadow.landmarks.grove
 s._teleport15(g+Vector2(0.,4.));await settle72(10)
 for e in s.enemies: e.hide();e.hit_area.collision_layer=0
 var m: Node3D=s.pillow160
 verify(s.memory_kit116.owned.pillow_hut==1 and s.memory_kit116.valid(["pillow_hut","paper_plane","balloon_sword","homework"]),"free prototype and four-slot mixed loadout available")
 s.hero.guard160=true;await settle72(12)
 verify(not m.ready160 and m.build160>0.,"real held guard starts gradual build")
 s.hero.guard160=false;await settle72(3)
 verify(not m.ready160 and m.build160==0.,"releasing early cancels incomplete build")
 await settle72(60)
 s.hero.guard160=true;await settle72(40)
 verify(m.ready160,"stationary crouch completes invulnerable fort")
 s.hero.guard160=false;await settle72(4)
 verify(not s.hero.guarding109 and m.protects160(),"release guard keeps fort available for counterattack")
 var img := await snapshot();img.save_png("res://docs/captures/world_restart/pillow_hut160_ready.png")
 s.set_physics_process(false);s.hero.set_physics_process(false)
 s.player_hp=100.;s.invulnerability=0.;s.hero.dodge_invulnerability=0.;s.wave_state="fighting"
 s.hero.combat_impulse=Vector2.ZERO
 var hurts: int=s.hurt_count
 for i in 12: s.hurt_player(15.,Vector2(s.hero.position.x+2.,s.hero.position.z))
 verify(s.player_hp==100. and m.ready160 and m.hits160==12,"twelve native damage calls are fully blocked without consuming durability")
 verify(s.hero.combat_impulse==Vector2.ZERO and s.invulnerability==0. and s.hurt_count==hurts,"blocked hits do not knock back, trigger hurt, or grant lingering invulnerability")
 verify(m.hit160==0.,"blocked hit triggers fort wobble")
 var hit_img := await snapshot();hit_img.save_png("res://docs/captures/world_restart/pillow_hut160_hit.png")
 var anchor: Vector3=m.anchor160
 var right: Vector2=m.opening_basis160()
 s.hero.position=anchor+Vector3(right.x*.59,0.,right.y*.59)
 verify(m.inside160(),"inner opening includes its horizontal safe edge")
 s.hero.position=anchor+Vector3(right.x*.65,0.,right.y*.65)
 verify(not m.protects160(),"pillow side stacks outside middle third do not protect")
 s.hurt_player(15.,Vector2.ZERO)
 verify(s.player_hp==85.,"outside opening real damage resumes even before next fort tick")
 s.hero.position=anchor;s.invulnerability=0.
 m.reset160();s.hero.velocity=Vector3.ZERO;s.hero.guarding109=true;m.step160(.46)
 s.combat_paused=true;var life: float=m.life160;m.step160(2.)
 verify(m.life160==life,"pause freezes lifetime")
 s.combat_paused=false;s.hero.guarding109=false;m.step160(.01);s.hero.position.x+=1.2;m.step160(.01)
 verify(m.ready160 and not m.protects160() and m.cooldown160==0.,"leaving keeps fort but removes protection and does not start cooldown")
 m.step160(.5);s.hero.position=m.anchor160
 verify(m.protects160() and m.life160<2.5,"returning restores protection without refreshing lifetime")
 s.hero.dash_left=.1;m.step160(.1)
 verify(m.ready160 and not m.protects160(),"dash keeps fort and follows existing dodge invulnerability")
 s.hero.dash_left=0.;verify(m.protects160(),"fort protects again after dash ends inside opening")
 m.step160(m.life160-.3)
 await process_frame;await process_frame
 verify(m.protects160() and m.visual160.scale.y<.9,"ending warning visibly slumps while protection remains active")
 var end_img := await snapshot();end_img.save_png("res://docs/captures/world_restart/pillow_hut160_ending.png")
 m.step160(.31)
 await process_frame;await process_frame
 verify(not m.ready160 and not m.visual160.visible and m.cooldown160==10.,"expiry hides fort and starts full ten-second cooldown")
 s.invulnerability=0.;s.hero.combat_impulse=Vector2.ZERO
 var expired_hp: float=s.player_hp;s.hurt_player(15.,Vector2.ZERO)
 verify(s.player_hp==expired_hp-15.,"damage resumes immediately after fort disappears")
 s.hero.velocity=Vector3.ZERO;s.hero.guarding109=true;m.step160(9.5)
 verify(not m.ready160 and m.build160==0.,"guard cannot rebuild during ten-second cooldown")
 m.reset160();s.hero.guarding109=true;m.step160(.46);m.step160(3.1);m.step160(10.1)
 verify(not m.ready160 and m.build160==0.,"lifetime expires and uninterrupted held guard cannot auto-renew")
 s.hero.guarding109=false;m.step160(.01);s.hero.guarding109=true;m.step160(.46)
 verify(m.ready160,"release rearms rebuilding after cooldown")
 s.hero.guarding109=false;s.hero.combat_impulse=Vector2.ZERO;s.invulnerability=0.
 var at: Vector3=s.projectile_origin()+Vector3(0.,0.,-4.)
 s.fire_at(at)
 verify(m.ready160 and not s.paper_memories146.pages146.is_empty(),"shooting from fort records current projectile normally")
 verify(s.paper_memories146.request146(),"Q notebook can prepare while protected after releasing guard")
 s._clear_combat_shots();verify(not m.ready160 and m.cooldown160==0.,"combat cleanup clears fort and transient state")
 s.hero.guard160=false;s.hero.set_physics_process(true);s.set_physics_process(true)
 await key153(KEY_F4);await settle72(4);disable_enemies(s);s.clear_standby119();await key153(KEY_3)
 verify(s.paper_trial129 and s.build160==2 and s.buffs.level("pillow_hut")==1 and s.buffs.level("balloon_sword")==1,"paper encounter and sword-airplane-fort loadout keys work")
 await key153(KEY_F5);await settle72(3);disable_enemies(s);await key153(KEY_6)
 verify(not s.paper_trial129 and s.build160==5 and s.buffs.level("pillow_hut")==0,"native Tuantuan and no-fort comparison keys work")
 var report := {"checks":checks,"failures":failures,"note":"Targeted actual guard/damage lifecycle and trial controls; balance still requires playtesting."}
 FileAccess.open("res://docs/pillow-hut160-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("PILLOW160_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
