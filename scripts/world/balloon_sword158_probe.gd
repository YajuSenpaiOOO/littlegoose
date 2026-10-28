extends "res://scripts/world/balloon_sword153_probe.gd"
class Trial158:
 extends "res://scripts/world/woodland_world158.gd"
 var aim158 := Vector3.ZERO
 func _hero_script() -> Script: return Walker146
 func fire_input_held() -> bool: return false
 func paper_aim146() -> Vector3: return aim158
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func capture158(tag: String) -> void:
 var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/balloon_sword158_"+tag+".png")
func pad_tip158(m: Node3D,entry: Dictionary) -> Vector3:
 return entry.pad158.position+entry.pad158.basis*Vector3(m.pad_anchor158.x,m.pad_anchor158.y,0.)
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial158.new();s.memory_save116="user://sword158_probe_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.swords153): await physics_frame
 s.hill_visited136=true;s.trial152=true;s.paper_trial129=false;s.start_combat();disable_enemies(s);s.clear_standby119();s.hero.controls_enabled=true
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(0,4));await settle72(15)
 for e in s.enemies: e.hide();e.hit_area.collision_layer=0
 var enemy: CharacterBody3D=s.enemies[0];enemy.show();enemy.hp=10000.;enemy.max_hp110=10000.;enemy.hit_area.collision_layer=8
 enemy.position=s.hero.position+Vector3(0,0,-3.8);enemy.position.y=s.floor_height(Vector2(enemy.position.x,enemy.position.z))+.06
 keep153(enemy);s.rebuild_cells110();s.aim158=enemy.hit_area.global_position
 s.build153=0;s.apply_paper_build129();var m: Node3D=s.swords153;var fx: Node2D=m.contact158
 verify(m.texture153.get_width()==589 and m.pad_texture158.get_width()==668,"selected A flight art and approved no-gravity surface gel are loaded separately")
 var hp: float=enemy.hp;s.fire_at(s.aim158)
 verify(s.shots[0].sword153 and is_zero_approx(m.ink154(m.sprite153()).get_shader_parameter("clip_tip158")),"flying A keeps its complete rounded tip")
 var wait := 0
 while m.resting153.is_empty() and wait<80: keep153(enemy);await settle72(1);wait+=1
 verify(not m.resting153.is_empty() and is_equal_approx(hp-enemy.hp,.75),"real native direct hit retains the existing damage and creates adhesion")
 if m.resting153.is_empty(): quit(1);return
 await settle72(2);await capture158("pop")
 var entry: Dictionary=m.resting153[-1]
 verify(fx.played158==1 and fx.events158.size()==1 and fx.events158[0].dots.size()==4,"one physical hit emits one comic pop with four gel drops")
 verify(is_equal_approx(m.ink154(entry.node).get_shader_parameter("clip_tip158"),m.cut158),"attached blade hides its ordinary tip beneath the independent slime contact end")
 entry.squash154=.28;entry.bend154=.20;m._process(0.)
 verify(pad_tip158(m,entry).distance_to(m.anchor154(entry))<.0001,"squash and bend do not pull the glue end off the target")
 enemy.hit_left=0.;enemy.landing_left=0.;enemy.hopping=false;enemy.attack_phase="approach";enemy._render_legacy(0.)
 var body: Dictionary=m.frame154(enemy);var head: Vector3=body.origin+Vector3.UP*body.height*.86
 s._clear_combat_shots();m.attach153(enemy,head,Vector3.DOWN);entry=m.resting153[-1];m._process(0.)
 var idle := pad_tip158(m,entry)
 enemy.attack_phase="windup";enemy.phase_clock=enemy.WINDUP*.8;enemy._render_legacy(0.);m._process(0.)
 verify(pad_tip158(m,entry).y<idle.y-.18 and pad_tip158(m,entry).distance_to(m.anchor154(entry))<.0001,"approved slime pad follows the visible crouching head pose")
 await capture158("squat")
 enemy.attack_phase="approach";enemy._render_legacy(0.);m.reset153()
 var pop_before: int=fx.played158
 for i in 12: m.attach153(enemy,head,Vector3.DOWN)
 m.step153(.001)
 verify(m.layers153[enemy.get_instance_id()].size()==5 and fx.played158-pop_before==1,"a dense same-target burst keeps five control layers while merging its cosmetic and audio accents")
 var pads: Array=[]
 for item in m.resting153: pads.append(item.pad158)
 s._clear_combat_shots();await process_frame
 verify(pads.all(func(p): return not is_instance_valid(p)) and fx.events158.is_empty() and is_equal_approx(enemy.get_meta("locomotion_scale153"),1.),"reset removes all detached gel pads, effects and control layers")
 # Sideways impact uses exactly the same surface sprite, rotated with the sword.
 var pos: Vector3=s.hero.position+Vector3(-1.5,.8,-3.)
 m.attach153(null,pos,Vector3.RIGHT);entry=m.resting153[-1];m._process(0.)
 verify(entry.pad158.basis.y.normalized().dot(entry.node.basis.y.normalized())>.999 and pad_tip158(m,entry).distance_to(pos)<.0001,"horizontal adhesion shares the sword's orientation without a fixed downward flow")
 await capture158("side_contact")
 s._clear_combat_shots();s.build153=1;s.apply_paper_build129();s.aim158=enemy.hit_area.global_position
 var previous_damage: float=s.damage152;var previous_landed: int=m.landed153;pop_before=fx.played158
 s.fire_at(s.aim158);await advance153(enemy,190)
 verify(m.landed153-previous_landed==6 and s.damage152>previous_damage,"assisted six-sword airplane delivery reaches the same native hit pipeline")
 verify(fx.played158-pop_before<6 and fx.voices158.size()==3,"six-sword delivery merges rapid pops and uses bounded reusable sound voices")
 await capture158("rain")
 s._clear_combat_shots();m.attach153(enemy,head,Vector3.DOWN);var age: float=m.resting153[0].age;var effect_age: float=fx.events158[0].age
 s.combat_paused=true;m.step153(.4)
 verify(is_equal_approx(m.resting153[0].age,age) and is_equal_approx(fx.events158[0].age,effect_age),"combat pause freezes both adhesion and the new contact effects")
 s.combat_paused=false;s._clear_combat_shots()
 await key153(KEY_F4);await settle72(4);disable_enemies(s);s.clear_standby119()
 verify(s.paper_trial129 and s.buffs.level("balloon_sword")==1 and s.swords153.get_script().resource_path.ends_with("balloon_sword158.gd"),"paper encounter keeps the new A sword and selected loadout")
 var report := {"checks":checks,"failures":failures,"note":"New art, separate contact anchor, effect budget, pause and airplane integration only. No repeated map suite."}
 FileAccess.open("res://docs/balloon-sword158-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("BALLOON_SWORD158_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
