extends "res://scripts/world/woodland_world201.gd"
var ready202 := false
var context202 := false
var original_grove202 := Vector2.ZERO
var original_navigation202: RefCounted
var forest_navigation202: RefCounted
func _init() -> void:
 super._init();memory_save116="user://forest202_preview.cfg"
func _lighting_script191() -> Script: return preload("res://scripts/art/forest_lighting202.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/forest_hud202.gd")
func _enemy_script() -> Script:
 return preload("res://scripts/combat/spider202.gd") if context202 else super._enemy_script()
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 202 · 林间蜘蛛试演 / 去除柱状树影")
func _ready() -> void:
 await super._ready()
 original_grove202=meadow.landmarks.grove;original_navigation202=navigation
 await get_tree().physics_frame
 forest_navigation202=preload("res://scripts/combat/forest_navigation202.gd").new()
 forest_navigation202.bake(get_world_3d().direct_space_state,meadow,FOREST188.CENTER)
 ready202=true
 for layer in get_children():
  if layer is CanvasLayer:
   for child in layer.get_children():
    if child is Label and child.text.begins_with("201 "):
     child.text="202 林间蜘蛛试演 / 去除柱状树影\nF7重开 / F6单只·三只 / 1—9组合\nF2结束试演看布景 / F3小院 / F10调色 / F12灯光"
 start_spider170()
func start_spider170() -> void:
 if not ready202: return
 context202=true;meadow.landmarks.grove=FOREST188.CENTER+Vector2(0,2);navigation=forest_navigation202
 super.start_spider170()
func start_combat(reposition := true) -> void:
 if not context202: super.start_combat(reposition);return
 super.start_combat(false)
 var entry: Vector2=forest_navigation202.origin+Vector2(forest_navigation202.nearest(FOREST188.CENTER+Vector2(5,6)))*forest_navigation202.CELL
 _teleport15(entry)
func _spawn_wave110(index: int) -> void:
 if not context202: super._spawn_wave110(index);return
 # Reuse the tested 173 trial lifecycle, then place its actors on real forest
 # floor/navigation cells instead of moving the original grove scenery.
 super._spawn_wave110(index)
 var seeds := [Vector2(-4,3),Vector2(4,1),Vector2(7,4)]
 for i in enemies.size():
  var actor: CharacterBody3D=enemies[i]
  var at: Vector2=navigation.origin+Vector2(navigation.nearest(FOREST188.CENTER+seeds[i]))*navigation.CELL
  actor.position=Vector3(at.x,floor_height(at)+.08,at.y);actor.velocity=Vector3.ZERO;actor.home=meadow.landmarks.grove
  actor.reset_physics_interpolation()
 rebuild_cells110();target114=null;aim_tick114=-1
func announce152() -> void:
 if not context202: super.announce152();return
 if is_instance_valid(encounter_hud): encounter_hud.announce("很吓人的森林！ · "+BUILDS170[build170].name,"小跳 / 丝球 / 脚下织网 · F6单/三只 F7重开 · F2只看布景",4.)
func _leave_encounter() -> void:
 super._leave_encounter()
 if context202:
  meadow.landmarks.grove=original_grove202;navigation=original_navigation202;context202=false;spider_trial170=false
func stop_trial202() -> void:
 active114=false;_leave_encounter();combat_paused=false;result_dismissed=true
 won119=false;trial152=false;Engine.time_scale=1.;stop_until=0.;_cancel_charge();hero.cancel_guard109()
 hero.controls_enabled=true
 if is_instance_valid(trial_ui114): trial_ui114.menu.hide()
func finish114() -> void:
 var forest_trial: bool=context202
 var victory: bool=active114 and won119 and player_hp>0.
 super.finish114()
 if forest_trial:
  # The inherited ordinary encounter queues post-win roamers and a later
  # reward reminder. Neither belongs to this repeatable, reward-free trial.
  clear_roam122();won119=false
  if victory: encounter_hud.announce("森林试演完成","F7再玩一场 · F6单/三只 · F2继续看布景",5.)
func _input(event: InputEvent) -> void:
 if ready202 and event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed:
  if event.physical_keycode==KEY_F7:
   start_spider170();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_F6:
   spider_count170=1 if spider_count170==3 else 3;start_spider170();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_F2:
   stop_trial202();get_viewport().set_input_as_handled();return
  if context202 and event.physical_keycode in [KEY_F4,KEY_F5,KEY_F8,KEY_F9,KEY_F11]:
   announce152();get_viewport().set_input_as_handled();return
 super._input(event)
