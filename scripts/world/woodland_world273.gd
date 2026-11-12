extends "res://scripts/world/woodland_world272.gd"
var ball_owned273 := false
var ball_pending273: Array=[]
var ball_stats273 := {"enemy_bounces":0,"wall_bounces":0,"rebound_hits":0}
var reward273: AcceptDialog
func reward_path273() -> String:return "user://tuantuan_ball273_reward.cfg"
func _init() -> void:
 super._init();memory_kit116=preload("res://scripts/combat/memory_kit273.gd").new()
 var cfg=ConfigFile.new()
 if cfg.load(reward_path273())==OK:ball_owned273=bool(cfg.get_value("reward","bouncy_ball",false))
func balance_profile226() -> Script:return preload("res://scripts/combat/balance_profile273.gd")
func test_config_path226() -> String:return "user://boss_balance273.cfg"
func load_test226() -> void:
 if FileAccess.file_exists(test_config_path226()):super.load_test226();return
 levels226={}
 var cfg=ConfigFile.new()
 if cfg.load("user://boss_balance257.cfg")!=OK:return
 var level=int(cfg.get_value("test","determination_level",1));var saved=cfg.get_value("test","levels",{})
 if saved is Dictionary and loadout_error257(saved,level)=="":determination_level257=level;levels226=saved.duplicate(true);loadout_name226=name_for226(levels226)
 cat_health226=clampf(float(cfg.get_value("test","cat_hp",90.)),10.,10000.)
 bat_health226=clampf(float(cfg.get_value("test","bat_hp",32.)),10.,10000.)
func card_catalog273() -> Array:
 var cards=preload("res://scripts/combat/cards168.gd").POOL.duplicate()
 cards.append(preload("res://scripts/combat/memory_kit273.gd").BALL273);return cards
func loadout_error257(levels: Dictionary,level: int) -> String:
 if int(levels.get("bouncy_ball",0))>0 and not ball_owned273:return "弹力球：首次战胜大团团后获得"
 return super.loadout_error257(levels,level)
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 273 · 弹力球碎片 / 首胜奖励")
func _ready() -> void:
 await super._ready()
 reward273=AcceptDialog.new();reward273.title="获得碎片 · 弹力球";reward273.ok_button_text="收下，看看装配";add_child(reward273)
 reward273.confirmed.connect(func():combat_paused=false;hero.controls_enabled=true;toggle_console226();console226.focus226("bouncy_ball"))
 reward273.canceled.connect(func():combat_paused=false;hero.controls_enabled=true)
func finish251(victory: bool) -> void:
 var grant=mode264=="boss" and victory and not ball_owned273
 super.finish251(victory)
 if not grant:return
 ball_owned273=true
 var cfg=ConfigFile.new();cfg.set_value("reward","bouncy_ball",true)
 if cfg.save(reward_path273())!=OK:notice219("弹力球本次已获得，但奖励记录保存失败。")
 combat_paused=true;hero.controls_enabled=false
 reward273.dialog_text="大团团送你一颗弹力球！\n\n弹力球碎片 · 占1槽\n弹丸命中后额外反弹一次，反弹伤害70%。\n可弹向另一只敌人，也能利用墙壁和岩石。\n\n收下后按C装配；槽满时需先卸下一份。"
 reward273.popup_centered(Vector2i(540,260))
func _apply_shot_hit(shot: Dictionary,hit: Dictionary) -> void:
 var rebound=shot.get("ball273",false)
 var eligible=not rebound and not shot.get("ball_spent273",false) and buffs.level("bouncy_ball")>0 and not shot.get("stream110",false) and int(shot.get("split_depth110",0))==0
 if eligible:shot.ball_spent273=true
 var damage=damage_for_shot(shot);var enemy: Object=hit.collider.get_meta("enemy") if hit.collider.has_meta("enemy") else null
 var before=float(enemy.hp) if is_instance_valid(enemy) else 0.
 super._apply_shot_hit(shot,hit)
 if rebound and is_instance_valid(enemy) and enemy.hp<before:ball_stats273.rebound_hits+=1
 if not eligible or not active114:return
 var direction=Vector3.ZERO
 var ignores: Array[RID]=[]
 for rid in shot.get("hit_rids",[]):ignores.append(rid)
 if is_instance_valid(enemy):
  ignores.append(hit.collider.get_rid());var nearest=6.5
  for target in enemies:
   if not is_instance_valid(target) or target==enemy or target.dead or not is_instance_valid(target.hit_area) or target.hit_area.collision_layer==0 or target.hit_area.get_rid() in ignores:continue
   var delta: Vector3=target.hit_area.global_position-hit.position
   if delta.length()<nearest:nearest=delta.length();direction=delta.normalized()
  if direction==Vector3.ZERO:
   # A lone or widely spaced enemy must still visibly bounce the projectile.
   var normal: Vector3=hit.get("normal",-shot.velocity.normalized())
   normal.y=0.
   direction=shot.velocity.normalized().bounce(normal.normalized()) if normal.length()>.1 else -shot.velocity.normalized()
   direction.y=0.;direction=direction.normalized()
  ball_stats273.enemy_bounces+=1
 else:
  if not hit.has("normal") or absf(hit.normal.y)>.65:return
  direction=shot.velocity.normalized().bounce(hit.normal).normalized();ball_stats273.wall_bounces+=1
 ball_pending273.append({"at":hit.position+direction*.08,"direction":direction,"damage":damage*.7,"ignores":ignores,"sword":shot.get("sword153",false)})
func _step_shots(delta: float) -> void:
 # New segments start next step, never mutate the parent's active projectile traversal.
 var queued=ball_pending273;ball_pending273=[]
 for bounce in queued:
  var shot=data_shot110(bounce.at,bounce.direction*Profile.BULLET_SPEED,.8)
  shot.ball273=true;shot.fixed_damage110=bounce.damage;shot.final_damage234=true;shot.split_depth110=99;shot.ignore_rids110=bounce.ignores
  tag_sword153(shot,bounce.sword,true)
  if not bounce.sword:shot.art.modulate=Color(1.,.85,.45);shot.art.scale_gain=1.35
 super._step_shots(delta)
func _clear_combat_shots() -> void:
 ball_pending273.clear();super._clear_combat_shots()
func _steer_shot(shot: Dictionary,delta: float) -> void:
 if not shot.get("ball273",false):super._steer_shot(shot,delta)
func report_stats226() -> Dictionary:
 var report=super.report_stats226();report["ball273"]={"owned":ball_owned273,"stats":ball_stats273.duplicate(true),"max_bounces":1,"damage_gain":.7};return report
func _process(delta: float) -> void:
 super._process(delta)
 if ready264:guide206.text=guide206.text.replace("272 林间空地","273 林间空地").replace("272 大团团挑战","273 大团团挑战")
