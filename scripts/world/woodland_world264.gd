extends "res://scripts/world/woodland_world263.gd"
var ready264 := false
var mode264 := "boot"
var boss_unlocked264 := false
var roster264=roster_script264().new()
var ordinary_damage264 := 0.
var last_ordinary264 := {}
var dialog264: ConfirmationDialog
var dialog_purpose264 := ""
var boss_entry_said264 := false
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 264 · 林间热身 / 大团团的挑战")
func _encounter_hud_script37() -> Script:return preload("res://scripts/combat/encounter_hud264.gd")
func minion_script260() -> Script:return preload("res://scripts/combat/tuantuan_minion264.gd")
func _trial_duration114() -> float:return 1000000000.
func _ready() -> void:
 await super._ready()
 speech112.dismiss();speech112.queue_free();speech112=speech_script264().new();speech112.battle=self;add_child(speech112)
 dialog264=ConfirmationDialog.new();dialog264.title="大团团";dialog264.get_cancel_button().text="等一会儿";dialog264.confirmed.connect(confirm264);dialog264.canceled.connect(cancel_dialog264);add_child(dialog264)
 ready264=true;yard264()
func say264(words: String) -> void:
 if is_instance_valid(speech112):speech112.say_card(words)
func close_dialog264() -> void:
 if is_instance_valid(dialog264):dialog264.hide()
 dialog_purpose264="";combat_paused=false;hero.controls_enabled=true
func passive_boss264() -> void:
 boss247.set_physics_process(false);boss247.collision_layer=16;boss247.hit_area.collision_layer=0;boss247.velocity=Vector3.ZERO;boss247.marker247.hide()
 enemies.erase(boss247);target114=null;aim_tick114=-1;rebuild_cells110()
func reset_player264() -> void:
 player_hp=max_player_health();hero.knocked_down=false;hero.reset_actions();hero.cancel_guard109();hero.controls_enabled=true;invulnerability=.8
func clear251() -> void:
 # The passive NPC is deliberately absent from the targeting roster; still reclaim it.
 if is_instance_valid(boss247) and boss247.get_parent()==self and boss247 not in enemies:enemies.append(boss247)
 super.clear251()
func yard264() -> void:
 if recording226.active:recording226.finish(self,"回到开场中止")
 close_dialog264();mode264="ambient";super.begin251();passive_boss264()
 active114=false;wave_state="waiting";stage225="waiting";result251="";reset_player264();roster264=roster_script264().new();ordinary_damage264=0.
 var at=safe_goal247(Vector2(boss247.position.x,boss247.position.z),meadow.landmarks.grove+Vector2(0.,-4.7))
 boss247.position=Vector3(at.x,floor_height(at)+.03,at.y);boss247.reset_physics_interpolation()
 for offset in ambient_offsets264():ambient_minion264(meadow.landmarks.grove+offset)
 speech112.dismiss();encounter_hud.reset_round();time55.apply_look()
func ambient_minion264(at: Vector2) -> void:
 var m=minion_script260().new();m.battle=self;m.poses=combat_poses;m.textures=combat_textures;m.home=meadow.landmarks.grove
 m.rank110=0;m.body_scale110=1.;m.max_hp110=6.;m.hp=6.;m.touch110=1.;m.role110=serial260+200;serial260+=1;m.playground264=true
 m.position=Vector3(at.x,floor_height(at)+.03,at.y);add_child(m);minions260.append(m);m.reset_physics_interpolation();_add_actor_shadow(m,m.visual);m.projection260=actor_shadows[-1]
func ordinary264() -> void:
 if mode264!="ambient":return
 close_dialog264();mode264="ordinary";roster264=roster_script264().new();ordinary_damage264=0.
 active114=true;wave_state="fighting";stage225="battle";battle_phase220="fight";result251="";elapsed114=0.;defeated_count=0;total_enemies=roster264.TOTAL;refill114=0.;pending260=0;attack_gate260=.65
 reset_stats226(false);telemetry260.data.minions.spawned=live_minions260().size();telemetry260.event("ordinary_start",{"total":roster264.TOTAL})
 for m in live_minions260():m.ground260()
 say264("小家伙们好像想跟我们玩一场！")
func begin251() -> void:
 if not ready264:super.begin251();return
 if mode264 in ["ordinary","ordinary_failed"]:yard264();ordinary264()
 elif boss_unlocked264 and mode264 in ["boss","boss_failed","won"]:boss264()
 else:yard264()
func boss264() -> void:
 if not boss_unlocked264:return
 if recording226.active:recording226.finish(self,"重新挑战中止")
 close_dialog264();speech112.dismiss();mode264="boss";boss_entry_said264=false;super.begin251()
func start_battle225(keep_player: bool) -> void:
 # Console apply-and-restart / record must start the ordinary battle before recording begins.
 if ready264 and mode264 in ["ambient","ready"]:yard264();ordinary264()
 else:super.start_battle225(keep_player)
func boss_phase260(old: String,next: String) -> void:
 if not ready264 or mode264=="boss":super.boss_phase260(old,next)
func spawn_minion260() -> CharacterBody3D:
 # All commentary in this preview belongs to the goose, not a narrator banner.
 entry_notes261=1
 var m=super.spawn_minion260()
 if is_instance_valid(m) and mode264=="boss" and not boss_entry_said264:
  boss_entry_said264=true;say264("小团团也来凑热闹了！")
 return m
func cancel_entry261(m: CharacterBody3D) -> void:
 if mode264=="ordinary":roster264.cancelled()
 super.cancel_entry261(m)
func enemy_defeated(actor: CharacterBody3D) -> void:
 if mode264=="ordinary" and actor in minions260:
  if actor.get_meta("counted264",false):return
  actor.set_meta("counted264",true);roster264.defeated+=1;defeated_count=roster264.defeated
 super.enemy_defeated(actor)
func record_enemy_damage226(actor: Node,damage: float) -> void:
 if mode264=="ordinary" and actor in minions260:ordinary_damage264+=maxf(0.,damage)
 super.record_enemy_damage226(actor,damage)
func finish_ordinary264(victory: bool) -> void:
 if mode264!="ordinary" or (victory and not roster264.complete()):return
 active114=false;wave_state="waiting";stage225="waiting";pending260=0;refill114=0.;combat_paused=false
 _cancel_charge();_clear_combat_shots();reset_impact248();hero.cancel_guard109();hero.controls_enabled=true
 mode264="ready" if victory else "ordinary_failed"
 if victory:boss_unlocked264=true;reset_player264()
 last_ordinary264=roster264.snapshot();last_ordinary264["victory"]=victory;last_ordinary264["damage"]=ordinary_damage264;last_ordinary264["reward"]="boss_challenge" if victory else "none"
 stats226.result="普通战清场" if victory else "普通战失败";telemetry260.finish(self,"ordinary_clear" if victory else "ordinary_failed");recording226.finish(self,stats226.result)
 clear_minions260()
 if victory:say264("呼，玩够啦！大团团好像也想跟你比一比。")
 else:open_dialog264("ordinary_retry")
func finish251(victory: bool) -> void:
 if not ready264:super.finish251(victory);return
 if mode264=="ordinary":finish_ordinary264(victory);return
 if mode264!="boss":return
 super.finish251(victory);mode264="won" if victory else "boss_failed";passive_boss264()
 if victory:say264("大团团认输啦！下次还想再跟它玩。")
 else:open_dialog264("boss")
func open_dialog264(purpose: String) -> void:
 if dialog264.visible:return
 dialog_purpose264=purpose;combat_paused=true;hero.controls_enabled=false;hero.velocity=Vector3.ZERO;hero.locomotion=Vector2.ZERO;hero.cancel_guard109();_cancel_charge()
 dialog264.title="再试一次？" if purpose=="ordinary_retry" else "大团团的挑战"
 dialog264.dialog_text="刚才没站稳……再和小团团玩一次？" if purpose=="ordinary_retry" else ("小家伙们玩得很开心。
要不要也和我比一场？" if mode264 not in ["boss_failed","won"] else "挑战资格还在。
准备好再来一场了吗？")
 dialog264.get_ok_button().text="再试一次" if purpose=="ordinary_retry" else "来比一场"
 dialog264.popup_centered(Vector2i(440,180))
func confirm264() -> void:
 var purpose=dialog_purpose264;close_dialog264()
 if purpose=="ordinary_retry":yard264();ordinary264()
 elif purpose=="boss":boss264()
func cancel_dialog264() -> void:
 var failed=mode264 in ["ordinary_failed","boss_failed"]
 close_dialog264()
 if mode264=="ordinary_failed":yard264()
 elif failed:reset_player264();say264("先歇一歇吧，准备好再挑战它。")
func interact264() -> void:
 if combat_paused or mode264 in ["ordinary","boss","away"]:return
 var at=Vector2(hero.position.x,hero.position.z)
 if is_instance_valid(boss247) and at.distance_to(Vector2(boss247.position.x,boss247.position.z))<3.5:
  if boss_unlocked264:open_dialog264("boss")
  else:say264("它好像在等我们和小团团玩完。")
  return
 if mode264=="ambient" and at.distance_to(meadow.landmarks.grove)<5.5:ordinary264()
func reset_stats226(partial: bool) -> void:
 super.reset_stats226(partial)
 if mode264=="ordinary":recording226.folder="user://encounter_records"
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 if not ready264 or mode264!="ordinary" or combat_paused or not active114:return
 roster264.seconds+=delta;roster264.retry_left=maxf(0.,roster264.retry_left-delta)
 if roster264.complete():finish_ordinary264(true);return
 if roster264.needs_entry(live_minions260().size()):
  var m=spawn_minion260()
  if is_instance_valid(m):
   if roster264.entered():say264("最后几个也跑过来了！")
  else:roster264.retry_left=.8
func _input(event: InputEvent) -> void:
 if not ready264:super._input(event);return
 if dialog264.visible:return
 if event is InputEventKey and event.pressed and not event.echo and not event.alt_pressed and not event.ctrl_pressed:
  if is_instance_valid(console226) and console226.visible:super._input(event);return
  if event.physical_keycode==KEY_E:interact264();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_F8:yard264();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_F3:
   super._input(event);close_dialog264();mode264="away";speech112.dismiss();return
 super._input(event)
func _unhandled_input(event: InputEvent) -> void:
 if ready264 and (dialog264.visible or (event is InputEventKey and event.physical_keycode in [KEY_E,KEY_F8])):return
 super._unhandled_input(event)
func _process(delta: float) -> void:
 super._process(delta)
 if not ready264:return
 guide206.visible=mode264!="away"
 if mode264=="boss":
  guide206.text=guide206.text.replace("263 团团Boss · 连续光线 / 红灯预警","264 大团团挑战");return
 var line={"ambient":"E 打个招呼，和小团团玩一场","ordinary":"小团团 %d / 6 · 场上 %d / 3"%[roster264.defeated,live_minions260().size()],"ready":"已解锁大团团挑战 · 靠近它按E","ordinary_failed":"这次没站稳 · 可以再试","boss_failed":"挑战资格保留 · F7直接重试","won":"大团团认输啦 · 靠近按E可以再比一场"}.get(mode264,"")
 guide206.text="264 林间空地
"+line+"
C装配 · %d决心 / %d槽
F7重试 / F8回开场 / F6暂停 / F3回院"%[int(max_player_health()),capacity257()]
func report_stats226() -> Dictionary:
 var report=super.report_stats226()
 if report.has("encounter264") and not recording226.final_report.is_empty():return report
 report["encounter264"]={"mode":mode264,"boss_unlocked":boss_unlocked264,"ordinary":roster264.snapshot(),"ordinary_damage":ordinary_damage264,"last_ordinary":last_ordinary264.duplicate(true),"progress_scope":"current preview session"};return report
func summary_stats226() -> String:
 if mode264=="boss":return super.summary_stats226()
 return "林间空地 · %s
%d决心 / %d槽
普通战 %d / 6 · 入场 %d / 6
有效战斗 %.1f秒 · 输出 %.1f
大团团挑战：%s
资格在本次试演中保留；尚未接正式奖励。"%[loadout_name226,int(max_player_health()),capacity257(),roster264.defeated,roster264.spawned,roster264.seconds,ordinary_damage264,"已解锁" if boss_unlocked264 else "未解锁"]

func roster_script264() -> Script:return preload("res://scripts/combat/encounter_roster264.gd")
func speech_script264() -> Script:return preload("res://scripts/combat/goose_speech264.gd")
func ambient_offsets264() -> Array:return [Vector2(-1.25,.5),Vector2(1.25,.5)]
