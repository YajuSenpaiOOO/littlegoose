extends "res://scripts/world/woodland_world264.gd"
var cushion265: Node3D
var rest_at265 := Vector2.ZERO
var rest_selected265 := false
var awake265 := false
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 265 · 山脚小憩 / 团团增援")
func roster_script264() -> Script:return preload("res://scripts/combat/encounter_roster265.gd")
func speech_script264() -> Script:return preload("res://scripts/combat/goose_speech265.gd")
func boss_script251() -> Script:return preload("res://scripts/combat/tuantuan_rest265.gd")
func minion_cap261() -> int:return roster264.live_cap() if mode264=="ordinary" else 3
func ambient_offsets264() -> Array:return [Vector2(-1.6,.6),Vector2(0,-.35),Vector2(1.6,.6)]
func select_rest265() -> Vector2:
 var centre: Vector2=meadow.landmarks.grove
 var shape=CylinderShape3D.new();shape.radius=1.;shape.height=.45
 var query=PhysicsShapeQueryParameters3D.new();query.shape=shape;query.collision_mask=1|2;query.margin=.001
 for offset in [Vector2(-4.5,-6.),Vector2(-2.5,-7.),Vector2(1.,-7.5),Vector2(3.,-7.),Vector2(-7.5,-5.),Vector2(-8.,-2.5),Vector2(7.5,-5.),Vector2(-6.8,0.),Vector2(7.,1.)]:
  var at: Vector2=entry_navigation261.origin+Vector2(entry_navigation261.nearest(centre+offset))*entry_navigation261.CELL
  if at.distance_to(centre)<6.5 or absf(floor_height(at)-floor_height(centre))>.5:continue
  var path: PackedVector2Array=entry_navigation261.path(centre,at)
  if path.is_empty() or path[-1].distance_to(at)>.8:continue
  query.transform.origin=Vector3(at.x,floor_height(at)+.24,at.y)
  if not get_world_3d().direct_space_state.intersect_shape(query,1).is_empty():continue
  var flat=true
  for edge in [Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1)]:
   if absf(floor_height(at+edge*.8)-floor_height(at))>.16:flat=false
  if flat:return at
 push_error("265 no clear resting footprint at the arena margin")
 return centre+Vector2(-7.,0.)
func place_rest265(sleeping: bool) -> void:
 if not rest_selected265:rest_at265=select_rest265();rest_selected265=true
 if not is_instance_valid(cushion265):
  cushion265=preload("res://scripts/art/rest_cushion265.gd").new();cushion265.battle=self;add_child(cushion265)
 cushion265.position=Vector3(rest_at265.x,floor_height(rest_at265)+.025,rest_at265.y-.35)
 boss247.position=Vector3(rest_at265.x,floor_height(rest_at265)+.03,rest_at265.y);boss247.reset_physics_interpolation();boss247.rest265(sleeping);time55.apply_look()
func yard264() -> void:
 super.yard264();awake265=boss_unlocked264;place_rest265(not awake265)
func finish_ordinary264(victory: bool) -> void:
 var was_ordinary=mode264=="ordinary"
 super.finish_ordinary264(victory)
 if victory and was_ordinary and mode264=="ready":
  awake265=true;boss247.wake265();say264("咦，山脚下的大团团醒了！")
func finish251(victory: bool) -> void:
 var was_boss=mode264=="boss"
 super.finish251(victory)
 if was_boss and mode264 in ["won","boss_failed"]:awake265=true;place_rest265(false)
func interact264() -> void:
 if combat_paused or mode264 in ["ordinary","boss","away"]:return
 if is_instance_valid(boss247) and Vector2(hero.position.x,hero.position.z).distance_to(Vector2(boss247.position.x,boss247.position.z))<3.5:
  if not awake265 or boss247.wake_left265>0.:
   say264("它还睡得正香呢。先去和小团团玩吧。" if not awake265 else "它刚睡醒，伸个懒腰就好。")
   return
 super.interact264()
func _physics_process(delta: float) -> void:
 if ready264 and mode264=="ordinary":roster264.incoming=live_minions260().filter(func(m):return m.state260 in ["rustle","arrive"]).size()
 super._physics_process(delta)
func _process(delta: float) -> void:
 super._process(delta)
 if not ready264:return
 if mode264=="boss":guide206.text=guide206.text.replace("264 大团团挑战","265 大团团挑战");return
 var line={"ambient":"E 和3只小团团打个招呼 · 大团团在山脚休息","ordinary":"小团团 %d / 15 · 场上 %d / %d · 第%d / 4批"%[roster264.defeated,live_minions260().size(),roster264.live_cap(),roster264.wave+1],"ready":"大团团醒了 · 去山脚找它，靠近按E","ordinary_failed":"这次没站稳 · 可以再试","boss_failed":"挑战资格保留 · F7直接重试","won":"大团团回软垫休息了 · 靠近按E再比一场"}.get(mode264,"")
 guide206.text="265 林间空地
"+line+"
C装配 · %d决心 / %d槽
F7重试 / F8再约普通战 / F6暂停 / F3回院"%[int(max_player_health()),capacity257()]
func summary_stats226() -> String:
 if mode264=="boss":return super.summary_stats226()
 return "林间空地 · %s
%d决心 / %d槽
普通战 %d / 15 · 入场 %d / 15
第%d / 4批 · 场上上限%d
有效战斗 %.1f秒 · 输出 %.1f
大团团：%s"%[loadout_name226,int(max_player_health()),capacity257(),roster264.defeated,roster264.spawned,roster264.wave+1,roster264.live_cap(),roster264.seconds,ordinary_damage264,"已醒来，可挑战" if awake265 else "在山脚睡觉"]
func report_stats226() -> Dictionary:
 var report=super.report_stats226()
 if not report.has("encounter265"):report["encounter265"]={"initial":3,"batches":[3,4,5],"total":15,"rest_at":[rest_at265.x,rest_at265.y],"awake":awake265}
 return report
