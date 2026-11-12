extends "res://scripts/world/woodland_world336.gd"
var paper337: Dictionary={}
var source337:="weapon"
var checkpoint337:=0.
func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 337 · 纸剧场独立采样")
func restart301() -> void:
 if not paper337.is_empty() and paper337.get("active",false): finish_sample337("restart_abort")
 super.restart301()
func start_recording226(levels: Dictionary, cat_hp: float, bat_hp: float, mode: String) -> String:
 var error:=commit_console226(levels,cat_hp,bat_hp,true)
 if error!="": return error
 return begin_sample337(mode)
func begin_sample337(mode: String) -> String:
 # The paper encounter restart bypasses the old cat battle stats reset.
 reset_stats226(false)
 paper337={"schema":1,"active":true,"result":"in_progress","preview":337,"loadout_start":levels226.duplicate(true),"slots":balance_profile226().cost(levels226),"excluded_hero_moment":int(levels226.get("hero_moment",0))>0,"combat_seconds":0.,"castle_hp_start":CASTLE334,"cannon_hp_start":CANNON334,"castle_damage":0.,"cannon_damage":[0.,0.],"castle_by_source":{},"cannon_by_source":{},"injuries":[],"disables":[0,0],"events":[]}
 checkpoint337=0.
 recording226.begin(self,mode)
 paper337.id=recording226.id
 return "" if recording226.save(self)==OK else "记录文件写入失败"
func commit_console226(levels: Dictionary, cat_hp: float, bat_hp: float, restart: bool) -> String:
 if balance_profile226().error(levels)!="": return super.commit_console226(levels,cat_hp,bat_hp,restart)
 if not paper337.is_empty() and paper337.get("active",false): finish_sample337("loadout_change_abort")
 return super.commit_console226(levels,cat_hp,bat_hp,restart)
func finish_sample337(reason: String) -> void:
 if paper337.is_empty() or not paper337.get("active",false): return
 paper337.active=false
 paper337.result=reason
 stats226.result=reason
 paper337.castle_hp_end=fastener_hp321
 paper337.cannon_hp_end=cannon_hp326.duplicate()
 recording226.finish(self,reason)
func finish251(victory: bool) -> void:
 finish_sample337("victory" if victory else ("defeat" if player_hp<=0. else "abort"))
 super.finish251(victory)
func _physics_process(delta: float) -> void:
 if not paper337.is_empty() and paper337.get("active",false) and active114 and not combat_paused and not waiting_intro314:
  paper337.combat_seconds+=delta
  checkpoint337+=delta
  if checkpoint337>=5.:
   checkpoint337=0.
   recording226.save(self)
 super._physics_process(delta)
func add_damage337(target: String, amount: float, index := -1) -> void:
 if paper337.is_empty() or not paper337.get("active",false) or amount<=0.: return
 if target=="castle": paper337.castle_damage+=amount
 else: paper337.cannon_damage[index]+=amount
 var key: String="castle_by_source" if target=="castle" else "cannon_by_source"
 paper337[key][source337]=float(paper337[key].get(source337,0.))+amount
 if paper337.events.size()<1000: paper337.events.append({"time":paper337.combat_seconds,"target":target,"index":index,"source":source337,"damage":amount})
func damage_fastener321(shot: Dictionary, at: Vector3) -> void:
 var hp:=fastener_hp321
 super.damage_fastener321(shot,at)
 add_damage337("castle",hp-fastener_hp321)
func hurt_cannon326(index: int, damage: float) -> void:
 var hp:=cannon_hp326[index]
 var previous:=source337
 source337="cannon_disable_reward"
 super.hurt_cannon326(index,damage)
 source337=previous
 add_damage337("cannon",hp-cannon_hp326[index],index)
 if hp>0. and cannon_hp326[index]==0. and not paper337.is_empty() and paper337.get("active",false): paper337.disables[index]+=1
func _apply_shot_hit(shot: Dictionary, hit: Dictionary) -> void:
 var previous:=source337
 source337=str(shot.get("damage_source260","beam" if shot.get("stream110",false) else "weapon"))
 super._apply_shot_hit(shot,hit)
 source337=previous
func bomb_impact149(packet: Dictionary, mark: Vector3, gain: float) -> void:
 var previous:=source337
 source337="paper_plane_payload"
 super.bomb_impact149(packet,mark,gain)
 source337=previous
func tick_heavy330(delta: float) -> void:
 var previous:=source337
 source337="reflected_heavy"
 super.tick_heavy330(delta)
 source337=previous
func enemy_defeated(actor: CharacterBody3D) -> void:
 var previous:=source337
 source337="puppet_reward"
 super.enemy_defeated(actor)
 source337=previous
func hazard_hurt332(damage: float, from: Vector2, kind: String) -> void:
 var previous:=source337
 source337=kind
 super.hazard_hurt332(damage,from,kind)
 source337=previous
func hurt_player(damage: float, from: Vector2) -> void:
 var hp:=player_hp
 super.hurt_player(damage,from)
 if player_hp<hp and not paper337.is_empty() and paper337.get("active",false):
  paper337.injuries.append({"time":paper337.combat_seconds,"loss":hp-player_hp,"source":source337})
func report_stats226() -> Dictionary:
 var report:=super.report_stats226()
 if paper337.is_empty(): return report
 var data:=paper337.duplicate(true)
 data.castle_hp_current=data.get("castle_hp_end",fastener_hp321)
 data.cannon_hp_current=data.get("cannon_hp_end",cannon_hp326).duplicate()
 data.castle_dps=float(data.castle_damage)/maxf(.001,float(data.combat_seconds))
 report.paper_theatre337=data
 report.loadout=data.loadout_start.duplicate(true)
 report.slots=data.slots
 report.seconds=data.combat_seconds
 report.result=data.result
 if report.has("recording"):
  report.recording.game_seconds=data.combat_seconds
  report.recording.clock="paper combat scaled physics seconds; excludes intro and pause"
 return report
func _notification(what: int) -> void:
 if what==NOTIFICATION_WM_CLOSE_REQUEST: finish_sample337("window_close_abort")
 super._notification(what)
func _process(delta: float) -> void:
 super._process(delta)
 if is_instance_valid(theatre314):
  guide206.text=guide206.text.replace("336 城防弹幕","337 城防弹幕")
  if paper337.get("active",false): guide206.text+="\n纸剧场采样 %.1fs · 城堡伤害 %.1f" % [paper337.combat_seconds,paper337.castle_damage]

func summary_stats226() -> String:
 if paper337.is_empty(): return "纸剧场尚未采样；按开始记录后单独统计城堡与炮台，不使用肥猫DPS。"
 var t: float=paper337.combat_seconds
 return "纸剧场采样 · %s\n实际战斗 %.1fs · 城堡伤害 %.1f · %.2f DPS\n炮台伤害 左%.1f / 右%.1f · 压制 %d / %d 次\n受击 %d 次 · %s" % [paper337.result,t,paper337.castle_damage,float(paper337.castle_damage)/maxf(.001,t),paper337.cannon_damage[0],paper337.cannon_damage[1],paper337.disables[0],paper337.disables[1],paper337.injuries.size(),"含主角时刻：排除平衡样本" if paper337.excluded_hero_moment else "不含主角时刻"]

func _ready() -> void:
 await super._ready()
 hint288.text="337 纸剧场独立采样\nC开始记录 · 主角时刻样本单独排除"
