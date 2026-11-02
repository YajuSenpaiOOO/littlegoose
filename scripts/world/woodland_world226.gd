extends "res://scripts/world/woodland_world225.gd"
const PROFILE226=preload("res://scripts/combat/balance_profile226.gd")
var ready226 := false
var levels226: Dictionary=PROFILE226.PRESETS[0].levels.duplicate(true)
var loadout_name226 := "普通机队"
var cat_health226 := PROFILE226.CAT_HP
var bat_health226 := PROFILE226.BAT_HP
var console226: Control
var resume_pause226 := false
var resume_controls226 := true
var stats226 := {}
var fight_age226 := 0.
var round_damage226 := 0.
var window226 := {}
var damage_source226 := "other"
var cheat226 := false
var recording226=preload("res://scripts/combat/balance_recording226.gd").new()
func _init() -> void:
 super._init();memory_save116="user://plush_boss226_preview.cfg"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 226 · 14决心 / C原地装配 / 姐姐战数值测试")
func _encounter_hud_script37() -> Script:return preload("res://scripts/combat/balance_hud226.gd")
func _sword_manager153() -> Script:return preload("res://scripts/combat/balloon_sword226.gd")
func _paper_manager_script146() -> Script:return preload("res://scripts/combat/paper_squad226.gd")
func max_player_health() -> float:return balance_profile226().HEALTH
func _ready() -> void:
 await super._ready()
 player_hp=max_player_health();saved_hp220=player_hp;auto114=false
 # Keep loadout experiments separate from inventory, crafting and region progress.
 load_test226();apply_levels226();reset_stats226(false)
 var layer=CanvasLayer.new();layer.layer=70;add_child(layer)
 console226=preload("res://scripts/combat/balance_console226.gd").new();console226.world=self;layer.add_child(console226)
 ready226=true
func test_config_path226() -> String:return "user://boss_balance226.cfg"
func load_test226() -> void:
 var cfg=ConfigFile.new()
 if cfg.load(test_config_path226())!=OK:return
 var saved=cfg.get_value("test","levels",{})
 if saved is Dictionary and balance_profile226().error(saved)=="":levels226=saved.duplicate(true);loadout_name226=name_for226(levels226)
 cat_health226=clampf(float(cfg.get_value("test","cat_hp",cat_health226)),10.,10000.)
 bat_health226=clampf(float(cfg.get_value("test","bat_hp",bat_health226)),10.,10000.)
func apply_levels226() -> void:
 buffs.levels=levels226.duplicate(true);_apply_owned_buffs();aim_tick114=-1;target114=null
func name_for226(levels: Dictionary) -> String:
 for preset in balance_profile226().PRESETS:
  if preset.levels==levels:return preset.name
 return "自选组合"
func apply_paper_build129() -> void:
 # Native combat startup calls this hook; never substitute the old 1–9 trial builds.
 if not ready226:super.apply_paper_build129();return
 _cancel_charge();_clear_combat_shots();apply_levels226()
func announce152() -> void:
 if not ready226:return
 if is_instance_valid(encounter_hud):encounter_hud.announce("姐姐战 · "+loadout_name226,"14决心 / 6槽 · C原地装配与统计",2.)
func paper_aim146() -> Vector3:
 # Old ground-mark mode ignored autoaim and sent aircraft to the idle mouse cursor.
 if ready226 and buffs.level("paper_plane")>0:
  _refresh_aim114(get_viewport().get_mouse_position())
  if is_instance_valid(target114) and not target114.dead:
   var point: Vector3=target114.hit_area.global_position
   return Vector3(point.x,floor_height(Vector2(point.x,point.z))+.05,point.z)
 return super.paper_aim146()
func start_battle225(keep_player: bool) -> void:
 if not ready226:super.start_battle225(keep_player);return
 recording226.finish(self,"重开中止")
 var selected_auto=auto114
 super.start_battle225(keep_player)
 # Restarting an active fight calls stop225 inside the parent, which hides the rig.
 rig220.entering225=false;rig220.show();rig220.place220(rig_at220,rig_height220,0.);rig220._process(0.)
 player_hp=max_player_health();invulnerability=.8;cat220.max_hp110=cat_health226;cat220.hp=cat_health226
 for bat in bats220:bat.max_hp110=bat_health226;bat.hp=bat_health226
 apply_levels226();reset_stats226(false)
 encounter_hud.reset_round();auto114=selected_auto
func reset_stats226(partial: bool) -> void:
 recording226=preload("res://scripts/combat/balance_recording226.gd").new()
 stats226={"loadout":levels226.duplicate(true),"name":loadout_name226,"slots":balance_profile226().cost(levels226),"cat_hp":cat_health226,"bat_hp":bat_health226,"partial":partial,"debug":false,"seconds":0.,"cat_damage":0.,"bat_damage":[0.,0.],"rounds":[],"windows":[],"injuries":[],"result":"进行中"}
 fight_age226=0.;round_damage226=0.;window226={}
 if not active114:stats226.result="待开战"
 if active114 and battle_phase220=="repair":open_window226()
func open_window226() -> void:
 window226={"seconds":0.,"damage":[0.,0.],"first_hit":-1.,"partial":stats226.get("partial",false)}
func close_window226() -> void:
 if window226.is_empty():return
 stats226.windows.append(window226.duplicate(true));window226={}
func record_enemy_damage226(actor: Node,damage: float) -> void:
 if not ready226 or not active114 or combat_paused or damage<=0.:return
 if cheat226:stats226.debug=true;return
 recording226.hit(actor==cat220,actor in bats220)
 if actor==cat220:stats226.cat_damage+=damage;round_damage226+=damage
 elif actor in bats220:
  var i=bats220.find(actor);stats226.bat_damage[i]+=damage
  if not window226.is_empty():
   window226.damage[i]+=damage
   if window226.first_hit<0.:window226.first_hit=window226.seconds
func cat_down220(cat: CharacterBody3D) -> void:
 if ready226 and active114 and battle_phase220=="fight":
  stats226.rounds.append({"seconds":fight_age226,"damage":round_damage226,"partial":stats226.partial,"debug":cheat226});fight_age226=0.;round_damage226=0.
 super.cat_down220(cat)
func hurt_player_from(_damage: float,from: Vector2,source: String) -> void:
 damage_source226=source
 hurt_player({"roll":4.,"touch":2.,"cotton":1.}.get(source,_damage),from)
 damage_source226="other"
func hurt_player(damage: float,from: Vector2) -> void:
 var before=player_hp
 super.hurt_player(damage,from)
 if ready226 and player_hp<before and not stats226.is_empty():
  stats226.injuries.append({"time":stats226.seconds,"source":damage_source226,"loss":before-player_hp,"guard":hero.guarding109})
func export_stats226() -> Error:
 var report=report_stats226()
 report["current_cat_round_seconds"]=fight_age226;report["current_cat_round_damage"]=round_damage226
 if not window226.is_empty():report["current_window"]=window226.duplicate(true)
 var file=FileAccess.open("user://boss_balance226_last.json",FileAccess.WRITE)
 if file==null:return FileAccess.get_open_error()
 file.store_string(JSON.stringify(report,"\t"));return recording226.save(self)
func summary_stats226() -> String:
 if stats226.is_empty():return "尚无战斗记录"
 var text=recording226.summary(self)+"\n"
 text+="记录：%s%s\n战斗 %.1f秒 · 猫累计伤害 %.1f\n蝙蝠累计 %.1f / %.1f\n"%[stats226.result,"（中途装配片段）" if stats226.partial else "",stats226.seconds,stats226.cat_damage,stats226.bat_damage[0],stats226.bat_damage[1]]
 if stats226.debug:text+="含F9/F10预览，不作平衡样本\n"
 for i in stats226.rounds.size():text+="追猫%d：%.1f秒%s\n"%[i+1,stats226.rounds[i].seconds,"（预览）" if stats226.rounds[i].debug else ""]
 var windows=stats226.windows.duplicate()
 if not window226.is_empty():windows.append(window226)
 for i in windows.size():
  var win=windows[i];text+="修补%d：%.1f秒，伤害 %.1f / %.1f，首击%s\n"%[i+1,win.seconds,win.damage[0],win.damage[1],"未命中" if win.first_hit<0. else "%.1f秒"%win.first_hit]
 var losses={"roll":0.,"touch":0.,"cotton":0.,"other":0.}
 for injury in stats226.injuries:losses[injury.source]+=injury.loss
 return text+"损失决心：滚动 %.1f / 接触 %.1f / 棉絮 %.1f / 其它 %.1f"%[losses.roll,losses.touch,losses.cotton,losses.other]
func end220(victory: bool) -> void:
 if ready226 and active114:
  close_window226();stats226.result="胜利" if victory else ("失败" if player_hp<=0. else "中止")
  recording226.finish(self,stats226.result);export_stats226()
 super.end220(victory)
func restore_context220() -> void:
 super.restore_context220()
 if ready226:apply_levels226()
func stop225() -> void:
 if ready226 and active114:
  close_window226();stats226.result="失败" if player_hp<=0. else "中止";recording226.finish(self,stats226.result);export_stats226()
 super.stop225()
func toggle_console226() -> void:
 if console226.visible:close_console226();return
 resume_pause226=combat_paused;resume_controls226=hero.controls_enabled
 combat_paused=true;hero.controls_enabled=false;hero.reset_actions();hero.cancel_guard109();_cancel_charge()
 hero.velocity=Vector3.ZERO;hero.locomotion=Vector2.ZERO;hero.combat_impulse=Vector2.ZERO
 console226.open226()
func close_console226() -> void:
 console226.hide();combat_paused=resume_pause226;hero.controls_enabled=resume_controls226
 fire_needs_release=Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
func commit_console226(levels: Dictionary,cat_hp: float,bat_hp: float,restart: bool) -> String:
 var error=balance_profile226().error(levels)
 if error!="":return error
 if not is_finite(cat_hp) or not is_finite(bat_hp) or cat_hp<10. or bat_hp<10. or cat_hp>10000. or bat_hp>10000.:return "血量范围为10—10000"
 var cfg=ConfigFile.new();cfg.set_value("test","levels",levels);cfg.set_value("test","cat_hp",cat_hp);cfg.set_value("test","bat_hp",bat_hp)
 if cfg.save(test_config_path226())!=OK:return "测试配置保存失败，原配置未改变"
 recording226.finish(self,"更换装配中止");export_stats226()
 levels226=levels.duplicate(true);loadout_name226=name_for226(levels226);cat_health226=cat_hp;bat_health226=bat_hp
 _clear_combat_shots();_cancel_charge();apply_levels226()
 close_console226()
 if restart:start_battle225(false)
 else:reset_stats226(true)
 return ""
func _process(delta: float) -> void:
 if alternate_encounter251():super._process(delta);return
 if not ready226:super._process(delta);return
 var running=active114 and not combat_paused
 var old_phase=battle_phase220
 if running:
  stats226.seconds+=delta
  if old_phase=="fight":fight_age226+=delta
  if old_phase=="repair" and not window226.is_empty():window226.seconds+=delta
 if running:recording226.step(self,delta,old_phase)
 super._process(delta)
 if running and old_phase!=battle_phase220:
  if old_phase=="repair":close_window226()
  if battle_phase220=="repair":open_window226()
 if stage225=="battle":
  var phase_name={"fight":"肥猫追滚","lower":"姐姐下降","repair":"修补中 · 低空蝙蝠可锁定","rise":"姐姐升空","landing":"姐姐软落地","ended":"本场结束"}.get(battle_phase220,battle_phase220)
  guide206.text="226 姐姐战 · "+phase_name+"\n肥猫 %d／%d · 蝙蝠 %d／%d"%[ceili(cat220.hp),ceili(cat220.max_hp110),ceili(bats220[0].hp),ceili(bats220[1].hp)]
  guide206.text+="\nC装配与统计 · %d／6槽 · "%balance_profile226().cost(levels226)+("自动输出" if auto114 else "鼠标瞄准射击")
  guide206.text+="\nF4瞄准模式 · F5猪猪 · F6暂停\nF8重开战斗 · F7回门口 · F3回院\nF9修补预览 · F10落地预览"
  if active114:guide206.text+="\n本轮追猫 %.1f秒 · 修补已记录%d窗"%[fight_age226,stats226.windows.size()]
  if recording226.active:guide206.text+="\n【采样中】结束自动保存 · C查看DPS"
  if combat_paused:guide206.text+="\n【暂停】"
 else:guide206.text=guide206.text.replace("225","226")+"\nC装配与统计 · 14决心 / %d／6槽"%balance_profile226().cost(levels226)
func _input(event: InputEvent) -> void:
 # Time inspection shortcuts must precede the console's plain-number loadout guard.
 if event is InputEventKey and event.alt_pressed and not event.ctrl_pressed and is_instance_valid(time55) and time55.handle_input(event):
  get_viewport().set_input_as_handled();return
 if ready226 and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_C:
   toggle_console226();get_viewport().set_input_as_handled();return
  if console226.visible:
   if event.physical_keycode==KEY_ESCAPE:
    close_console226();get_viewport().set_input_as_handled()
   return
  if event.physical_keycode>=KEY_1 and event.physical_keycode<=KEY_9:
   notice219("按C选择6槽测试组合");get_viewport().set_input_as_handled();return
  if event.physical_keycode in [KEY_F9,KEY_F10]:
   cheat226=true;super._input(event);cheat226=false;return
 if ready226 and console226.visible:
  # Let Control receive mouse/text input; only bypass the world's gameplay handlers.
  return
 super._input(event)
func _unhandled_input(event: InputEvent) -> void:
 if ready226 and console226.visible:return
 super._unhandled_input(event)

func report_stats226() -> Dictionary:
 var report=stats226.duplicate(true)
 report["current_cat_round_seconds"]=fight_age226;report["current_cat_round_damage"]=round_damage226
 if not window226.is_empty():report["current_window"]=window226.duplicate(true)
 return recording226.enrich(self,report)
func start_recording226(levels: Dictionary,cat_hp: float,bat_hp: float,mode: String) -> String:
 var error=commit_console226(levels,cat_hp,bat_hp,true)
 if error!="":return error
 recording226.begin(self,mode)
 error="" if recording226.save(self)==OK else "记录文件写入失败，请检查数据目录"
 if error!="":notice219(error)
 return error

func _notification(what: int) -> void:
 if what==NOTIFICATION_WM_CLOSE_REQUEST and ready226:recording226.finish(self,"关闭窗口中止")

func balance_profile226() -> Script:return PROFILE226

func hidden_cards226() -> Array:return []
