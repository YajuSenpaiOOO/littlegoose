extends "res://scripts/world/woodland_world149.gd"
func _paper_manager_script146() -> Script: return preload("res://scripts/combat/paper_flyby150.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 150 · 连续掠过 / 弹幕三投")
func _ready() -> void:
 super._ready()
 while not hill_ready146: await get_tree().physics_frame
 if "--flyby150" in OS.get_cmdline_user_args(): paper_trial129=true;start_combat()
func emit_packet146(packet: Dictionary,origin: Vector3,target: Vector3,gain: float,generation := -1) -> void:
 if not packet.get("air150",false): super.emit_packet146(packet,origin,target,gain,generation);return
 var forward := (target-origin).normalized()
 var side := forward.cross(Vector3.FORWARD).normalized()
 if side.length_squared()<.01: side=Vector3.RIGHT
 var axis := forward.cross(side).normalized()
 for i in packet.specs.size():
  if shots.size()>=512: break
  var spec: Dictionary=packet.specs[i].duplicate(true)
  var direction := forward.rotated(axis,float(spec.angle));spec.angle=0.
  var one := packet.duplicate(false);one.specs=[spec]
  super.emit_packet146(one,origin,origin+direction*8.,gain,generation)
  if spec.stream110: shots[-1].stream_lane110=i
func start_combat(reposition := true) -> void:
 super.start_combat(reposition)
 if hill_ready146 and paper_trial129: encounter_hud.announce("连续掠过 · 当前弹幕三投","左键标记／按住连发 · 不等待投弹点 · 1—6换组合 · Q笔记",3.)
