extends "res://scripts/world/woodland_world251.gd"
var echoes256: Array[CharacterBody3D]=[]
func boss_script251() -> Script:return preload("res://scripts/combat/tuantuan_boss256.gd")
func _porch_script() -> Script:return preload("res://scripts/art/woodland_palette255.gd")
func _lighting_script191() -> Script:return preload("res://scripts/art/forest_lighting254.gd")
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 256 · 团团Boss / 越弹越急")
func _ready() -> void:
 await super._ready()
 # Keep the approved255 protagonist base while returning to the actual combat world.
 hero.receiver192.albedo_color=Color.WHITE
func clear_echoes256() -> void:
 for ball in echoes256:
  if is_instance_valid(ball):ball.set_physics_process(false);ball.hide();ball.queue_free()
 echoes256.clear()
func clear251() -> void:
 clear_echoes256();super.clear251()
func finish251(victory: bool) -> void:
 clear_echoes256();super.finish251(victory)
func emit_echoes256(at: Vector2,forward: Vector2) -> void:
 echoes256=echoes256.filter(func(b):return is_instance_valid(b) and not b.is_queued_for_deletion())
 if echoes256.size()>2:return
 var side=forward.orthogonal().normalized()
 for sign256 in [-1.,1.]:
  var ball=preload("res://scripts/combat/echo_ball256.gd").new();ball.battle=self;ball.direction=side*sign256
  var origin=at+ball.direction*1.7
  origin=safe_goal247(at,origin)
  ball.position=Vector3(origin.x,floor_height(origin)+.19,origin.y)
  add_child(ball);echoes256.append(ball)
func _process(delta: float) -> void:
 super._process(delta)
 if ready251:
  guide206.text=guide206.text.replace("251 团团Boss · 246战斗基线","256 团团Boss · 越弹越急")
  if is_instance_valid(boss247):
   var labels={"angry":"急眼啦","squat":"憋住一口气","flight":"弹弹追击","rebound":"弹弹追击","flat":"弹瘪了 · 反击机会","bumper":"撞扁了","deflected":"反弹！"}
   guide206.text+="\n"+str(labels.get(boss247.phase247,"蓄势"))
