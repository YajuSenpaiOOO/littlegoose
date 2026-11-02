extends "res://scripts/world/woodland_world256.gd"
var determination_level257 := 1
func _init() -> void:
 super._init();memory_save116="user://tuantuan_boss257_preview.cfg"
func test_config_path226() -> String:return "user://boss_balance257.cfg"
func boss_script251() -> Script:return preload("res://scripts/combat/tuantuan_boss257.gd")
func _encounter_hud_script37() -> Script:return preload("res://scripts/combat/boss_hud257.gd")
func health_at257(level: int) -> int:return 11+level
func slots_at257(level: int) -> int:return 3+level
func max_player_health() -> float:return float(health_at257(determination_level257))
func capacity257() -> int:return slots_at257(determination_level257)
func loadout_error257(levels: Dictionary,level: int) -> String:
 if level<1 or level>20:return "测试决心等级范围为1—20"
 return balance_profile226().error(levels,slots_at257(level))
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 257 · 团团Boss / 初始决心与贴身判定")
func _ready() -> void:
 await super._ready()
 console226.queue_free();console226=preload("res://scripts/combat/boss_console257.gd").new();console226.world=self
 var layer=CanvasLayer.new();layer.layer=70;add_child(layer);layer.add_child(console226)
func begin251() -> void:
 super.begin251()
 boss247.touch110=3.
func load_test226() -> void:
 var cfg=ConfigFile.new()
 if cfg.load(test_config_path226())!=OK:return
 var level=int(cfg.get_value("test","determination_level",1))
 var saved=cfg.get_value("test","levels",{})
 if saved is Dictionary and loadout_error257(saved,level)=="":
  determination_level257=level;levels226=saved.duplicate(true);loadout_name226=name_for226(levels226)
 cat_health226=clampf(float(cfg.get_value("test","cat_hp",90.)),10.,10000.)
 bat_health226=clampf(float(cfg.get_value("test","bat_hp",32.)),10.,10000.)
func commit_console226(levels: Dictionary,cat_hp: float,bat_hp: float,restart: bool) -> String:
 return commit_progress257(levels,cat_hp,bat_hp,restart,determination_level257)
func commit_progress257(levels: Dictionary,cat_hp: float,bat_hp: float,restart: bool,level: int) -> String:
 var error=loadout_error257(levels,level)
 if error!="":return error
 if not is_finite(cat_hp) or not is_finite(bat_hp) or cat_hp<10. or bat_hp<10. or cat_hp>10000. or bat_hp>10000.:return "血量范围为10—10000"
 var cfg=ConfigFile.new();cfg.set_value("test","levels",levels);cfg.set_value("test","cat_hp",cat_hp);cfg.set_value("test","bat_hp",bat_hp);cfg.set_value("test","determination_level",level)
 if cfg.save(test_config_path226())!=OK:return "测试配置保存失败，原配置未改变"
 recording226.finish(self,"更换装配中止");export_stats226()
 determination_level257=level;levels226=levels.duplicate(true);loadout_name226=name_for226(levels226);cat_health226=cat_hp;bat_health226=bat_hp
 player_hp=minf(player_hp,max_player_health())
 _clear_combat_shots();_cancel_charge();apply_levels226();close_console226()
 if restart:start_battle225(false)
 else:reset_stats226(true)
 return ""
func boss_hurt257(damage: float,at: Vector2,source: String) -> void:
 damage_source226=source;hurt_player(damage,at);damage_source226="other"
func reset_stats226(partial: bool) -> void:
 super.reset_stats226(partial)
 stats226.determination_level=determination_level257;stats226.max_determination=max_player_health();stats226.capacity=capacity257()
func summary_stats226() -> String:
 return super.summary_stats226().replace("/ 6槽","/ %d槽"%capacity257())+"\n决心等级 %d（初始为1级）"%determination_level257
func export_stats226() -> Error:
 var file=FileAccess.open("user://boss_balance257_last.json",FileAccess.WRITE)
 if file==null:return FileAccess.get_open_error()
 file.store_string(JSON.stringify(report_stats226(),"  "));return recording226.save(self)
func _process(delta: float) -> void:
 super._process(delta)
 if ready251:guide206.text=guide206.text.replace("256 团团Boss · 越弹越急","257 团团Boss · 初始决心 / 贴身判定").replace("/ 6槽","/ %d槽"%capacity257())+"\n决心等级 %d"%determination_level257

func announce152() -> void:
 if ready226 and is_instance_valid(encounter_hud):encounter_hud.announce("团团Boss · "+loadout_name226,"%d决心 / %d槽 · C装配与等级"%[int(max_player_health()),capacity257()],2.)
func _input(event: InputEvent) -> void:
 if ready251 and is_instance_valid(console226) and not console226.visible and event is InputEventKey and event.pressed and not event.echo and not event.alt_pressed and not event.ctrl_pressed and event.physical_keycode>=KEY_1 and event.physical_keycode<=KEY_9:
  notice219("按C选择%d槽测试组合"%capacity257());get_viewport().set_input_as_handled();return
 super._input(event)
