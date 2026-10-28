extends "res://scripts/combat/trial_ui114.gd"
func _ready() -> void:
 super._ready()
 var box: VBoxContainer=menu.get_child(0)
 box.get_child(2).text="A  方向辅助 · 手动射击（本次重点）"
 explanation.text="鼠标指大致方向 · 目标圈会保持 · 左键射击\n明显转向换目标 · 无需一直指在怪物身上"
func _draw() -> void:
 super._draw()
 if not battle.active114 or battle.combat_paused or battle.auto114: return
 if not is_instance_valid(battle.target114):
  var start: Vector2=battle.camera.unproject_position(battle.hero.global_position+Vector3.UP*.8)
  var direction := (get_viewport().get_mouse_position()-start).normalized()
  draw_line(start+direction*30.,start+direction*90.,Color(1.,.84,.42,.35),2.,true)
