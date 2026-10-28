extends "res://scripts/world/woodland_world117.gd"
var woodland_ready118 := false
var grounding118: Node3D
func _init() -> void:
 memory_kit116=preload("res://scripts/combat/memory_kit118.gd").new();memory_save116="user://memory_kit118.cfg"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 118 · 魔法笔记本 / 糖纸轻瞄准")
func _memory_ui_script116() -> Script: return preload("res://scripts/combat/notebook_ui118.gd")
func _candy_script117() -> Script: return preload("res://scripts/combat/candy_aim118.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time118.gd")
func _workshop_hint_text116() -> String: return "F  翻开魔法笔记本 · F5 林地试演"
func _ready() -> void:
 super._ready()
 while not woodland_ready117: await get_tree().physics_frame
 grounding118=preload("res://scripts/art/grounded_workshop118.gd").new();grounding118.world=self;add_child(grounding118)
 woodland_ready118=true;time55.update_guide();_title35();print("WOODLAND118_READY")
func _apply_kit116() -> void:
 buffs.levels.clear()
 for id in memory_kit116.equipped:
  buffs.levels[id]=mini(int(memory_kit116.card(id).max),int(buffs.levels.get(id,0))+1)
 _apply_owned_buffs();_cancel_charge();aim_tick114=-1
func close_memory116(commit: bool,trial := false) -> bool:
 if not is_instance_valid(memory_ui116) or not memory_ui116.visible: return false
 var previous_owned: Dictionary=memory_kit116.owned.duplicate();var previous_crafted: Dictionary=memory_kit116.crafted.duplicate()
 if commit:
  if not memory_kit116.stock_valid118(memory_ui116.working_owned,memory_ui116.working_crafted,memory_kit116.unlocked) or not memory_kit116.valid(memory_ui116.working,memory_ui116.working_owned):
   memory_ui116.feedback.text="数量或口袋容量不对，先检查一下笔记本。";return false
  memory_kit116.owned=memory_ui116.working_owned.duplicate();memory_kit116.crafted=memory_ui116.working_crafted.duplicate()
 var result := super.close_memory116(commit,trial)
 if not result: memory_kit116.owned=previous_owned;memory_kit116.crafted=previous_crafted
 return result
