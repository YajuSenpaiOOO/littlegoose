extends RefCounted
# All clocks are unpaused game seconds. Hits are damage events, never projectiles.
var final_report := {}
var folder := "user://boss_records"
var id := ""
var mode := ""
var active := false
var result := "进行中"
var started := ""
var elapsed := 0.
var cat_seconds := 0.
var bat_seconds := 0.
var input_seconds := 0.
var distance := 0.
var hits := [0,0]
var last_position := Vector2.ZERO
var checkpoint := 0.
var frames := 0
var slow_frames := 0
var auto_seconds := 0.
var save_error := OK
var initial_pigs := true
var pigs_changed := false
var dash_start := 0
var dashes := 0
var guard_seconds := 0.
func begin(w: Node,kind: String) -> void:
 id="%s_%d"%[Time.get_datetime_string_from_system().replace(":","-").replace("T","_"),Time.get_ticks_usec()]
 mode=kind;active=true;result="进行中";started=Time.get_datetime_string_from_system()
 elapsed=0.;cat_seconds=0.;bat_seconds=0.;input_seconds=0.;distance=0.;hits=[0,0];checkpoint=0.;frames=0;slow_frames=0;auto_seconds=0.
 last_position=Vector2(w.hero.position.x,w.hero.position.z)
 initial_pigs=w.pigs_enabled220;pigs_changed=false;dash_start=w.hero.dash_count;dashes=0;guard_seconds=0.
func step(w: Node,delta: float,phase: String) -> void:
 if not active:return
 elapsed+=delta;frames+=1
 dashes=maxi(0,w.hero.dash_count-dash_start)
 if w.hero.guarding109:guard_seconds+=delta
 if w.pigs_enabled220!=initial_pigs:pigs_changed=true
 if delta>.05:slow_frames+=1
 if phase=="fight":cat_seconds+=delta
 if phase=="repair":bat_seconds+=delta
 if phase in ["fight","repair"] and w.fire_input_held():input_seconds+=delta
 if w.auto114:auto_seconds+=delta
 var at=Vector2(w.hero.position.x,w.hero.position.z)
 distance+=at.distance_to(last_position);last_position=at
 checkpoint+=delta
 if checkpoint>=5.:checkpoint=0.;save(w)
func hit(cat: bool,bat: bool) -> void:
 if not active:return
 if cat:hits[0]+=1
 if bat:hits[1]+=1
func enrich(w: Node,report: Dictionary) -> Dictionary:
 if not final_report.is_empty():return final_report.duplicate(true)
 if id=="":return report
 var cat_damage=float(report.get("cat_damage",0.))
 var bats: Array=report.get("bat_damage",[0.,0.])
 var bat_damage=float(bats[0])+float(bats[1])
 report["schema_version"]=1
 report["scene"]=w.scene_file_path
 report["effective_levels_at_export"]=w.buffs.levels.duplicate(true)
 report["recording"]={"dashes":dashes,"guard_seconds":guard_seconds,"pigs_enabled_at_start":initial_pigs,"pig_setting_changed":pigs_changed,"id":id,"started_local":started,"mode":mode,"active":active,"result":result,"game_seconds":elapsed,"cat_targetable_seconds":cat_seconds,"bat_targetable_seconds":bat_seconds,"cat_phase_dps":cat_damage/maxf(cat_seconds,.001),"bat_phase_dps":bat_damage/maxf(bat_seconds,.001),"encounter_dps":(cat_damage+bat_damage)/maxf(elapsed,.001),"attack_input_seconds":input_seconds,"attack_input_ratio":input_seconds/maxf(cat_seconds+bat_seconds,.001),"movement_metres":distance,"hit_events_cat":hits[0],"hit_events_bats":hits[1],"accuracy":null,"accuracy_note":"未统一发射/穿透/持续命中口径；命中事件数不能作为命中率。","auto_fire_seconds":auto_seconds,"frames":frames,"frames_over_50ms":slow_frames,"mean_fps":frames/maxf(elapsed,.001),"pigs_enabled_at_export":w.pigs_enabled220,"player_hp_at_export":w.player_hp,"save_error":save_error}
 for round_data in report.get("rounds",[]):round_data["dps"]=float(round_data.damage)/maxf(float(round_data.seconds),.001)
 var windows: Array=report.get("windows",[]).duplicate()
 if report.has("current_window"):windows.append(report.current_window)
 for window in windows:window["dps"]=(float(window.damage[0])+float(window.damage[1]))/maxf(float(window.seconds),.001)
 var cards=[]
 for key in report.get("loadout",{}):
  cards.append({"id":key,"name":str(w.memory_kit116.card(key).name),"count":report.loadout[key]})
 report["cards"]=cards
 return report
func save(w: Node) -> Error:
 if id=="":return OK
 var error=DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
 if error!=OK:save_error=error;return error
 var file=FileAccess.open(folder+"/"+id+".json",FileAccess.WRITE)
 if file==null:save_error=FileAccess.get_open_error();return save_error
 file.store_string(JSON.stringify(w.report_stats226(),"\t"));file.flush();save_error=file.get_error()
 return save_error
func finish(w: Node,reason: String) -> void:
 if not active:return
 result=reason;active=false;final_report=w.report_stats226();save(w)
func summary(w: Node) -> String:
 if id=="":return "点击「开始记录」可保存逐场样本；普通重开不自动采样。"
 var text="采样：%s · %s · %s\n"%[mode,result,"记录中" if active else "已归档"]
 text+="猫 %.1fs / %.2f DPS · 蝙蝠 %.1fs / %.2f DPS\n"%[cat_seconds,float(w.stats226.get("cat_damage",0.))/maxf(cat_seconds,.001),bat_seconds,(float(w.stats226.get("bat_damage",[0.,0.])[0])+float(w.stats226.get("bat_damage",[0.,0.])[1]))/maxf(bat_seconds,.001)]
 text+="攻击输入 %.1fs · 移动 %.1fm · 命中事件 %d / %d\n"%[input_seconds,distance,hits[0],hits[1]]
 text+="命中率暂未统计；每5秒自动保存，暂停不计时。"
 if save_error!=OK:text+="\n文件保存失败：%d"%save_error
 return text
