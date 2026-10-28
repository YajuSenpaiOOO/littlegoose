extends "res://scripts/world/woodland_world130.gd"
var paper_count131 := 6
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 131 · 纸怪气流侧翻 / 可靠掠过")
func _enemy_script() -> Script: return preload("res://scripts/combat/paper131.gd") if paper_trial129 else preload("res://scripts/combat/tuantuan128.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/paper_hud131.gd")
func _unhandled_input(event: InputEvent) -> void:
 if paper_trial129 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F6:
  paper_count131=10 if paper_count131==6 else 6;start_combat();return
 super._unhandled_input(event)
func start_combat(reposition := true) -> void:
 super.start_combat(reposition)
 if paper_trial129 and active114:
  total_enemies=paper_count131
  encounter_hud.announce("作业纸 · %d张"%paper_count131,"F6切换6/10张 · 漂流时会被弹幕气流推开；绷直、掠过后可抓机会。",3.)
func _spawn_wave110(index: int) -> void:
 super._spawn_wave110(index)
 if not paper_trial129 or paper_count131<=6: return
 var occupied: Array[Vector2]=[]
 for actor in enemies:
  if is_instance_valid(actor): occupied.append(Vector2(actor.position.x,actor.position.z))
 for i in range(6,paper_count131):
  var angle := TAU*float(i-6)/4.
  var at := _pick_spawn114(meadow.landmarks.grove+Vector2(cos(angle),sin(angle))*7.,occupied);occupied.append(at)
  var actor := make_actor119(i,at);enemies.append(actor);actor.play119()
 rebuild_cells110()
func enemy_defeated(actor: CharacterBody3D) -> void:
 if not paper_trial129: super.enemy_defeated(actor);return
 if not active114 or retired119.has(actor.get_instance_id()): return
 retired119[actor.get_instance_id()]=true;defeated_count+=1
 if steering_indices113.has(actor): steering_alive113[int(steering_indices113[actor])]=0
 if target114==actor: target114=null;aim_tick114=-1
 if defeated_count>=paper_count131: ending119=.6

