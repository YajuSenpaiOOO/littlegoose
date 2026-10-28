extends "res://scripts/world/woodland_world146.gd"
func _paper_manager_script146() -> Script: return preload("res://scripts/combat/paper_glide148.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/paper_hud148.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 148 · 手抛滑翔 / 空中释放")
func _ready() -> void:
 super._ready()
 while not hill_ready146: await get_tree().physics_frame
 if "--glide148" in OS.get_cmdline_user_args(): paper_trial129=true;start_combat()
func capture146(target: Vector3,charged: bool,ratio: float) -> void:
 if buffs.level("paper_plane")>0 and (paper_memories146.gliders148.size()>=3 or not paper_memories146.pending146.is_empty()): return
 super.capture146(target,charged,ratio)
func _flush_splits113() -> void:
 var room := maxi(0,(256-shots.size())/6)
 if pending_splits110.size()>room: pending_splits110.resize(room)
 super._flush_splits113()
func start_combat(reposition := true) -> void:
 super.start_combat(reposition)
 if hill_ready146 and paper_trial129: encounter_hud.announce("手抛滑翔 · 空中释放","左键放飞 · 1普通弹先看手感 · 2—5看载荷组合 · 6直接弹弓 · Q笔记",3.)
