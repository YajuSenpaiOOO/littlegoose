extends "res://scripts/world/paper_memories146_probe.gd"
class Input146:
 extends Current146
 var held146 := false
 func fire_input_held() -> bool:
  return held146 and active114 and hero.controls_enabled and not paper_memories146.writing146
 func aim_at_screen(_p: Vector2) -> Vector3: return aim146
func key146(key: Key) -> void:
 var event := InputEventKey.new();event.physical_keycode=key;event.pressed=true;Input.parse_input_event(event)
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Input146.new();s.memory_save116="user://memory146_input_tmp.cfg";root.add_child(s)
 while not s.hill_ready146: await physics_frame
 s.hill_visited136=true;s.paper_trial129=true;s.start_combat();disable_enemies(s)
 s.hero.controls_enabled=true;s.camera_distance=11.
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(-24,-18));await settle72(5)
 for enemy in s.enemies: enemy.hit_area.collision_layer=0;enemy.hide()
 s.aim146=s.hero.position+Vector3(3.,.7,-2.)
 set146(s,{"paper_plane":1,"homework":1});s.fire_needs_release=false
 var before: int=s.paper_memories146.planes_launched146;s.held146=true;await settle72(150);s.held146=false
 var launches: int=s.paper_memories146.planes_launched146-before
 verify(launches>=2 and launches<=3,"holding primary fire respects the one-second plane launch rhythm")
 key146(KEY_Q);await settle72(5)
 verify(s.paper_memories146.writing146,"physical Q input starts homework without toggling the old shadow-quality shortcut")
 var pages: int=s.paper_memories146.pages146.size();s.hero.request_dash(Vector2.RIGHT);await settle72(2)
 verify(not s.paper_memories146.writing146 and s.paper_memories146.pages146.size()==pages,"actual dash action triggers cancellation and retains drafts")
 await settle72(45)
 set146(s,{"paper_plane":1,"homework":1,"slingshot":1});s.fire_needs_release=false
 s.held146=true;await settle72(90);var ratio: float=s.charge_ratio();s.held146=false;await settle72(2)
 verify(ratio>.99 and s.paper_memories146.pages146.size()==1 and s.paper_memories146.pages146[0].specs[0].charged,"holding and releasing primary fire launches the fully charged payload")
 await settle72(15);await shot146(s,"charged_glide")
 key146(KEY_3);await settle72(3)
 verify(s.paper_build146==2 and s.buffs.level("snack")==1 and s.paper_memories146.pages146.is_empty(),"number-key preset switch updates effects and clears old transient packets")
 key146(KEY_5);await settle72(3)
 s.fire_needs_release=false;s.held146=true;await settle72(1);s.held146=false
 await settle72(44);await shot146(s,"water_delivery_live")
 s.combat_paused=true
 var times: Array=[]
 for f in s.paper_memories146.flights146: times.append(f.time)
 await settle72(15)
 var frozen := true
 for i in times.size(): frozen=frozen and is_equal_approx(times[i],s.paper_memories146.flights146[i].time)
 verify(frozen,"pausing combat freezes paper flights and delivery")
 s.combat_paused=false;s.home116();await settle72(2)
 verify(s.paper_memories146.pages146.is_empty() and s.paper_memories146.flights146.is_empty(),"returning home removes all encounter-only paper states")
 FileAccess.open("res://docs/paper-memories146-input-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"held_fire_launches":launches},"\t"))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("MEMORY146_INPUT_DONE ",JSON.stringify({"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
