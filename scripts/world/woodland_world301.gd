extends "res://scripts/world/woodland_world291.gd"
## Combat-first hanging-card test. No castle, cutscene or formal rewards.
var ready301 := false
var centre301 := Vector2.ZERO
var spawned301 := 0
var defeated301 := 0
var spawn_left301 := 0.
var result301 := ""
var cards301: Array[CharacterBody3D]=[]
const TYPES301=["dinosaur","knight","monster","knight","dinosaur","monster"]
func _init() -> void:
 super._init();memory_save116="user://paper_cards301_preview.cfg"
func _encounter_hud_script37() -> Script:return preload("res://scripts/combat/paper_hud301.gd")
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 301 · 吊线纸偶 / 基础战斗")
func _ready() -> void:
 await super._ready()
 centre301=meadow.landmarks.grove+Vector2(-24,-25.)
 if is_instance_valid(cushion265):cushion265.hide()
 boss247.hide();boss247.set_physics_process(false);boss247.collision_layer=0;boss247.hit_area.collision_layer=0
 clear_minions260();enemies.clear();ready301=true;restart301()
 hint288.text="301 吊线纸偶\n恐龙喷火 / 骑士突刺 / 怪兽砸地"
func live301() -> Array:
 return cards301.filter(func(c):return is_instance_valid(c) and not c.dead)
func paper_clamp301(at: Vector2) -> Vector2:
 return centre301+Vector2(clampf(at.x-centre301.x,-5.,5.),clampf(at.y-centre301.y,0.,8.5))
func restart301() -> void:
 for c in cards301:
  if is_instance_valid(c):enemies.erase(c);c.queue_free()
 cards301.clear();enemies.clear();_clear_combat_shots();reset_skill288();reset_impact248();speech112.dismiss()
 close_dialog264();mode264="paper301";active114=true;wave_state="fighting";stage225="battle";battle_phase220="fight";pending260=0;refill114=0.;ending119=-1.;result251=""
 spawned301=0;defeated301=0;spawn_left301=1.8;result301="";defeated_count=0;total_enemies=6;reward_offered=true;trial152=true;between_left=0.;result_open=false;result_dismissed=true;result_at=-1.;won119=false
 reset_player264();_teleport15(centre301+Vector2(0,6.5));target114=null;aim_tick114=-1;rebuild_cells110()
 if uses_card_schedule301():spawn301()
func uses_card_schedule301() -> bool:return true
func spawn301() -> CharacterBody3D:
 var c=card_script301().new();c.battle=self;c.poses=combat_poses;c.textures=combat_textures;c.kind301=card_type301(spawned301);c.role110=spawned301%3;c.home=centre301
 c.max_hp110=18.;c.hp=18.;c.touch110=1.5
 var offsets=[Vector2(-2.7,1.5),Vector2(2.7,2.),Vector2(0,.7)];var at=centre301+offsets[spawned301%3]
 c.position=Vector3(at.x,floor_height(at)+.04,at.y);add_child(c);cards301.append(c);enemies.append(c);_add_actor_shadow(c,c.visual);c.reset_physics_interpolation();spawned301+=1;rebuild_cells110();return c
func card_script301() -> Script:return preload("res://scripts/combat/paper_card301.gd")
func card_type301(index: int) -> String:return TYPES301[index]
func active_cap301() -> int:return 2
func begin251() -> void:
 if ready301:restart301()
 else:super.begin251()
func enemy_defeated(actor: CharacterBody3D) -> void:
 if ready301 and actor in cards301:
  if actor.get_meta("counted301",false):return
  actor.set_meta("counted301",true);defeated301+=1;defeated_count=defeated301;target114=null;aim_tick114=-1;spawn_left301=minf(spawn_left301,.8)
  if defeated301>=6:call_deferred("finish251",true)
  return
 super.enemy_defeated(actor)
func record_enemy_damage226(actor: Node,damage: float) -> void:
 if ready301 and actor in cards301:return
 super.record_enemy_damage226(actor,damage)
func finish251(victory: bool) -> void:
 if not ready301:super.finish251(victory);return
 active114=false;wave_state="waiting";stage225="waiting";combat_paused=false;hero.controls_enabled=true;hero.cancel_guard109();_cancel_charge();_clear_combat_shots();target114=null;reset_impact248()
 result301="六张纸偶清场 · F7再试" if victory else "本轮结束 · F7再试"
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 if not ready301 or not active114 or combat_paused or not uses_card_schedule301():return
 spawn_left301-=delta
 if spawned301<6 and live301().size()<active_cap301() and spawn_left301<=0.:spawn301();spawn_left301=3.
func _process(delta: float) -> void:
 super._process(delta)
 if ready301:
  guide206.text="301 吊线纸偶 · 已击落 %d / 6 · 场上 %d\nC装配 / F7重开 / F4瞄准 / F6暂停 / F3回院\n%s"%[defeated301,live301().size(),result301]
func _input(event: InputEvent) -> void:
 if ready301 and event is InputEventKey and event.pressed and not event.echo and (not is_instance_valid(console226) or not console226.visible):
  if event.physical_keycode in [KEY_F7,KEY_F12]:restart301();get_viewport().set_input_as_handled();return
  if event.physical_keycode in [KEY_F8,KEY_F9,KEY_F10,KEY_F11,KEY_E]:get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_F3:finish251(false);ready301=false
 super._input(event)
