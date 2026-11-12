extends "res://scripts/world/woodland_world345.gd"
var reconfigure346: Dictionary={}
var saved_level346:=2
func _init() -> void:
 super._init()
 memory_kit116=preload("res://scripts/combat/memory_kit346.gd").new()
func balance_profile226() -> Script:return preload("res://scripts/combat/balance_profile346.gd")
func _memory_ui_script116() -> Script:return preload("res://scripts/combat/notebook_ui346.gd")
func load_test226() -> void:
 super.load_test226()
 var cfg:=ConfigFile.new()
 if cfg.load(test_config_path226())!=OK:return
 var saved: Variant=cfg.get_value("test","levels",{})
 var level:=int(cfg.get_value("test","determination_level",determination_level257))
 if saved is Dictionary and level>=1 and level<=20 and balance_profile226().error(saved,100000)=="" and balance_profile226().cost(saved)>slots_at257(level):
  reconfigure346=saved.duplicate(true);saved_level346=level
  # Keep the old file untouched; it is a draft, never a free over-budget build.
  levels226={};determination_level257=level;loadout_name226="待重新装配"
func card_catalog273() -> Array:
 var cards:=super.card_catalog273().duplicate(true)
 for card in cards:
  if card.id in ["forest_fireboy","three_player"]:card.fx=memory_kit116.card(card.id).fx
 return cards
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 346 · 副鹅每只2槽")
func _ready() -> void:
 await super._ready()
 hint288.text="346 副鹅每只2槽\n单副鹅2槽 · 双副鹅4槽 · 每只仍40%伤害"
 if not reconfigure346.is_empty():
  toggle_console226()
  console226.determination257.value=saved_level346
  console226.draft=reconfigure346.duplicate(true)
  console226.refresh226()
  console226.feedback.text="副鹅成本更新：原装配超过槽位，请卸下一份后重新应用。原配置尚未改写。"
func report_stats226() -> Dictionary:
 var report:=super.report_stats226();report.runtime_preview=346
 if report.has("paper_theatre337"):report.paper_theatre337.preview=346
 report.geese346={"single_cost":2,"double_cost":4,"copy_damage":COPY_DAMAGE168}
 return report
func _process(delta: float) -> void:
 super._process(delta)
 if is_instance_valid(theatre314):guide206.text=guide206.text.replace("345 城防弹幕","346 城防弹幕")
