extends "res://scripts/world/woodland_world121.gd"
# Original lines from godot_yard/scripts/slime_play.gd, ROAM_LINES.
const ROAM_LINES122 := [
 "这次是我没吃早饭，下次一定打败你！",
 "哼哼，今天就让你们看看我的厉害！",
 "刚才那下不算！重来重来！",
 "我们可是很很强的哦！大概！",
 "再来再来再来！不要跑呀！",
]
var roamers122: Array[CharacterBody3D]=[]
var roam_left122 := 0
var roam_spawn122 := -1.
var talk_wait122 := 1.2
var talk_index122 := 0
var bubble122: Node2D
var bubble_layer122: CanvasLayer
var talk_history122: Array[String]=[]
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 122 · 团团退场 / 闲逛狠话")
func _enemy_script() -> Script: return preload("res://scripts/combat/tuantuan122.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time122.gd")
func start_combat(reposition := true) -> void:
 super.start_combat(reposition)
 if active114: clear_roam122()
func finish114() -> void:
 var completed := active114 and won119 and player_hp>0.
 super.finish114()
 if completed:
  roam_left122=3;roam_spawn122=.9;talk_wait122=1.2
func clear_roam122() -> void:
 roam_left122=0;roam_spawn122=-1.
 if is_instance_valid(bubble122): bubble122.queue_free()
 bubble122=null
 for actor in roamers122:
  if is_instance_valid(actor): remove_child(actor);actor.queue_free()
 roamers122.clear()
func _leave_encounter() -> void:
 clear_roam122();super._leave_encounter()
func say_roam122(actor: CharacterBody3D) -> void:
 if is_instance_valid(bubble122): return
 if not is_instance_valid(bubble_layer122):
  bubble_layer122=CanvasLayer.new();bubble_layer122.layer=14;add_child(bubble_layer122)
 var words: String=ROAM_LINES122[talk_index122%ROAM_LINES122.size()];talk_index122+=1
 var bubble := preload("res://scripts/combat/goose_speech112.gd").Bubble.new()
 bubble.anchor=weakref(actor.speech_anchor122);bubble.camera=camera;bubble.words=words;bubble.duration=3.3
 bubble_layer122.add_child(bubble);bubble122=bubble;actor.cheer122=.8
 talk_history122.append(words)
 if talk_history122.size()>16: talk_history122.pop_front()
func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(drops120): return
 if active114 or combat_paused:
  if is_instance_valid(bubble122): bubble122.queue_free();bubble122=null
  return
 if roam_left122>0:
  roam_spawn122-=delta
  if roam_spawn122<=0.:
   var occupied: Array[Vector2]=[]
   for actor in roamers122:
    if is_instance_valid(actor): occupied.append(Vector2(actor.position.x,actor.position.z))
   var offset: Vector2=[Vector2(-6.,-4.),Vector2(6.,-4.),Vector2(2.,4.)][3-roam_left122]
   var at := _pick_spawn114(meadow.landmarks.grove+offset,occupied)
   var actor := make_actor119(30+roam_left122,at);actor.home=at;actor.begin_roam122();roamers122.append(actor)
   roam_left122-=1;roam_spawn122=.65
 talk_wait122-=delta
 if talk_wait122>0. or is_instance_valid(bubble122): return
 var nearest: CharacterBody3D;var distance := 7.*7.
 for actor in roamers122:
  if not is_instance_valid(actor) or actor.spawn_age122<1.: continue
  var head: Vector3=actor.speech_anchor122.global_position+Vector3.UP*.45
  if camera.is_position_behind(head) or not get_viewport().get_visible_rect().grow(-30.).has_point(camera.unproject_position(head)): continue
  var d: float=actor.position.distance_squared_to(hero.position)
  if d<distance: nearest=actor;distance=d
 if is_instance_valid(nearest): say_roam122(nearest);talk_wait122=5.5
