extends "res://scripts/world/woodland_world173.gd"
const ARENA174=preload("res://scripts/world/arena_layout174.gd")
var arena174: Node3D
var arena_ready174 := false
var original_trees174: Array[Vector3]=[]
var original_grove174 := Vector2.ZERO
func _init() -> void:
 super._init();memory_save116="user://forest_arena174_preview.cfg"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 174 · 独立森林试场 / 双路线与输出空地")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/arena_hud174.gd")
func _trial_ui_script114() -> Script: return preload("res://scripts/combat/arena_result174.gd")
func floor_height(at: Vector2) -> float:
 if ARENA174.BOUNDS.grow(8.).has_point(at-ARENA174.CENTER): return ARENA174.HEIGHT
 return super.floor_height(at)
func _teleport15(at: Vector2) -> void:
 if not ARENA174.BOUNDS.grow(4.).has_point(at-ARENA174.CENTER): super._teleport15(at);return
 hero.position=Vector3(at.x,ARENA174.HEIGHT+.06,at.y);hero.velocity=Vector3.ZERO;hero.combat_impulse=Vector2.ZERO;hero.locomotion=Vector2.ZERO;hero.reset_physics_interpolation();_update_camera(0.,true)
func _ready() -> void:
 super._ready()
 while not is_instance_valid(arc_shadows167): await get_tree().physics_frame
 original_grove174=meadow.landmarks.grove
 for tree in trees: original_trees174.append(tree.root.position)
 arena174=preload("res://scripts/art/forest_arena174.gd").new();arena174.world=self;add_child(arena174)
 await get_tree().physics_frame;await get_tree().physics_frame
 navigation=preload("res://scripts/combat/arena_navigation174.gd").new();navigation.bake(get_world_3d().direct_space_state,meadow,ARENA174.CENTER)
 arena_ready174=true;start_spider170()
func start_combat(reposition := true) -> void:
 if not arena_ready174: super.start_combat(reposition);return
 super.start_combat(false);_teleport15(ARENA174.CENTER+ARENA174.ENTRY)
func _spawn_wave110(index: int) -> void:
 if not arena_ready174: super._spawn_wave110(index);return
 for actor in reuse119:
  if is_instance_valid(actor): actor.queue_free()
 reuse119.clear();clear_standby119()
 for actor in enemies:
  if is_instance_valid(actor): remove_child(actor);actor.queue_free()
 _prune_actor_shadows();enemies.clear();retired119.clear();round_index=0;between_left=0.;_clear_combat_shots();packs114=1;created120=spider_count170;total_enemies=spider_count170
 for i in spider_count170:
  var at: Vector2=ARENA174.CENTER+ARENA174.SPAWNS[i]
  var actor := make_actor119(i,at);actor.hp=24.;actor.max_hp110=24.;actor.touch110=12.;actor.home=ARENA174.CENTER;enemies.append(actor);actor.play119()
 rebuild_cells110();target114=null;aim_tick114=-1
func announce152() -> void:
 if not arena_ready174: super.announce152();return
 if is_instance_valid(encounter_hud): encounter_hud.announce("林间双路线 · "+BUILDS170[build170].name,"左侧宽外圈 / 右侧近路 · 南侧入口可喘息 · F6单/三只 F7重开 1—9组合",4.)
func home116() -> void:
 if arena_ready174: start_spider170();return
 super.home116()
func _input(event: InputEvent) -> void:
 if arena_ready174 and event is InputEventKey and event.pressed and not event.ctrl_pressed and not event.alt_pressed and event.physical_keycode in [KEY_F4,KEY_F5]:
  announce152();get_viewport().set_input_as_handled();return
 super._input(event)
func _unhandled_input(event: InputEvent) -> void:
 if arena_ready174 and event is InputEventKey and (event.ctrl_pressed or event.alt_pressed or event.physical_keycode in [KEY_F2,KEY_F3,KEY_F8,KEY_F10,KEY_F11,KEY_TAB,KEY_R]):
  get_viewport().set_input_as_handled();return
 super._unhandled_input(event)
