extends "res://scripts/world/paper_hill145_probe.gd"
class Walker146:
 extends "res://scripts/combat/hero146.gd"
 var wish := Vector2.ZERO
 func movement_input() -> Vector2: return wish
 func parry_key_down() -> bool: return false
 func dash_key_down() -> bool: return false
class Current146:
 extends "res://scripts/world/woodland_world146.gd"
 var aim146 := Vector3.ZERO
 func _hero_script() -> Script: return Walker146
 func fire_input_held() -> bool: return false
 func paper_aim146() -> Vector3: return aim146
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func shot146(s: Node3D,tag: String) -> void:
 await process_frame
 var img := await snapshot();img.save_png("res://docs/captures/world_restart/paper_memories146_%s.png"%tag)
func set146(s: Node3D,levels: Dictionary) -> void:
 s._clear_combat_shots();s.buffs.levels=levels.duplicate();s.beam_left110=0.;s._apply_owned_buffs();s.stop_until=0.;s.cooldown=0.
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Current146.new();s.memory_save116="user://memory146_probe_tmp.cfg";root.add_child(s)
 while not s.hill_ready146: await physics_frame
 s.hill_visited136=true;s.paper_trial129=true;s.start_combat();disable_enemies(s);s.hero.controls_enabled=true;s.camera_distance=12.
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(-24.,-17.));await settle72(10)
 var target: CharacterBody3D=s.enemies[0]
 for enemy in s.enemies:
  enemy.hit_area.collision_layer=0;enemy.hide()
 target.show();target.hit_area.collision_layer=8;target.hp=10000.;target.max_hp110=10000.
 target.position=s.hero.position+Vector3(0,0,-4.);target.position.y=s.floor_height(Vector2(target.position.x,target.position.z))+.06
 s.aim146=target.hit_area.global_position;s.rebuild_cells110();await settle72(5)
 verify(s.memory_kit116.card("paper_plane").id=="paper_plane" and s.memory_kit116.owned.paper_plane>=1 and s.memory_kit116.owned.homework>=1,"new memories are available in the notebook without spending crafting materials")
 set146(s,{"paper_plane":1,"homework":1})
 var hp: float=target.hp;s.fire_at(s.aim146)
 verify(s.shots.is_empty() and s.paper_memories146.flights146.size()==1 and target.hp==hp,"one attack becomes one plane with no immediate duplicate projectile")
 await settle72(18);await shot146(s,"plane_glide")
 await settle72(75)
 verify(s.paper_memories146.deliveries146>=1 and target.hp<hp,"plane payload actually hits a native enemy after its flight")
 var recorded: int=s.paper_memories146.records146
 verify(recorded==1 and s.paper_memories146.pages146.size()==1,"delivery does not recursively add another homework page")
 for i in 4: s.fire_at(s.aim146)
 verify(s.paper_memories146.pages146.size()==3,"homework retains only the three most recent attack packets")
 await settle72(90)
 var pages: int=s.paper_memories146.pages146.size();var base_speed: float=s.hero.movement_speed()
 verify(s.paper_memories146.request146() and s.hero.movement_speed()<base_speed*.5,"Q preparation enters writing and slows walking")
 await settle72(12);await shot146(s,"writing")
 s.on_dash_started();verify(not s.paper_memories146.writing146 and s.paper_memories146.pages146.size()==pages,"dash cancels writing without losing drafts")
 var prior: int=s.paper_memories146.replayed146;var prior_records: int=s.paper_memories146.records146
 s.paper_memories146.request146();await settle72(130)
 verify(s.paper_memories146.replayed146-prior==3 and s.paper_memories146.pages146.is_empty() and s.paper_memories146.records146==prior_records,"submission replays exactly three weakened packets without recording itself")
 set146(s,{"paper_plane":1,"homework":1,"slingshot":1});s._release_charged(s.aim146,1.)
 var packet: Dictionary=s.paper_memories146.pages146[0]
 verify(packet.specs[0].charged and is_equal_approx(packet.specs[0].damage,s.damage_for_shot({"charged":true,"damage_multiplier":12.})),"charged plane stores full charge power and piercing instead of a normal shot")
 s.emit_packet146(packet,s.projectile_origin(),s.projectile_origin()+Vector3(5,0,0),.45)
 verify(is_equal_approx(s.damage_for_shot(s.shots[-1]),float(packet.specs[0].damage)*.45),"charged replay uses captured final damage once, without a second legacy scaling")
 await settle72(90)
 set146(s,{"paper_plane":1,"homework":1,"snack":1,"distract":1});s.fire_at(s.aim146)
 packet=s.paper_memories146.pages146[0]
 verify(s.paper_memories146.flights146.size()==1 and packet.specs.size()==2 and packet.specs[0].snack==1,"multiple lanes and split behavior travel inside a single plane")
 var split_before: int=s.pool110.births;await settle72(90)
 var plane_rate: float=s.attack_cooldown();s.buffs.levels.eye_exercise=1
 verify(s.attack_cooldown()<plane_rate*.8,"attack speed shortens plane launch interval")
 set146(s,{"paper_plane":1,"homework":1,"flashlight":1});s.fire_at(s.aim146)
 verify(s.paper_memories146.pages146[0].stream and s.paper_memories146.flights146.size()==1,"continuous flashlight is captured as one finite burst payload")
 await settle72(90);await shot146(s,"stream_delivery")
 set146(s,{"homework":1,"slingshot":1});s._release_charged(s.aim146,.7)
 verify(not s.paper_memories146.pages146[0].plane and not s.shots.is_empty(),"homework also records direct charged attacks without a plane")
 s._clear_combat_shots();verify(s.paper_memories146.pages146.is_empty() and s.paper_memories146.flights146.is_empty() and s.paper_memories146.bursts146.is_empty(),"reset clears flights, drafts, queued copies and stream bursts")
 s.home116();s._teleport15(Vector2(-5.,-2.));await settle72(5)
 s.memory_ui116.open116();await shot146(s,"notebook")
 verify(s.memory_ui116.working_owned.has("paper_plane"),"notebook UI can display and equip the new memory")
 s.memory_ui116.hide()
 var kit := preload("res://scripts/combat/memory_kit146.gd").new()
 verify(kit.commit(["paper_plane","homework"]) and kit.used(kit.equipped)==2,"new memories fit the existing four-slot equipment rules")
 var save_path := "user://kit146_roundtrip_tmp.cfg";kit.save_to(save_path)
 var loaded := preload("res://scripts/combat/memory_kit146.gd").new();loaded.load_from(save_path)
 verify(loaded.equipped==kit.equipped and loaded.owned.paper_plane==1 and loaded.unlocked.homework,"new catalog and stock round-trip without touching the old progression file")
 DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
 FileAccess.open("res://docs/paper-memories146-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"launched":s.paper_memories146.planes_launched146,"delivered":s.paper_memories146.deliveries146,"replayed":s.paper_memories146.replayed146},"\t"))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("PAPER_MEMORIES146_DONE ",JSON.stringify({"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
