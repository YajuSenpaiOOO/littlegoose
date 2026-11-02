extends "res://scripts/combat/boss_console251.gd"
var determination257: SpinBox
const INITIAL257=[{"eye_exercise":1,"paper_plane":1,"exercise":1},{"hero_moment":1,"eye_exercise":1},{"pillow_hut":1,"paper_plane":1,"homework":1},{"slingshot":1,"homework":1,"exercise":1},{"balloon_sword":1,"paper_plane":1,"eye_exercise":1},{}]
func _ready() -> void:
 super._ready()
 var right=capacity.get_parent();var row=HBoxContainer.new();right.add_child(row);right.move_child(row,0)
 row.add_child(label226("决心等级"))
 determination257=SpinBox.new();determination257.min_value=1;determination257.max_value=20;determination257.step=1;determination257.custom_minimum_size.x=85;row.add_child(determination257)
 determination257.value_changed.connect(func(_v):refresh226())
 var hint=label226("1级：12决心 / 4槽；每级各＋1。原地应用不补血。",14);hint.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;right.add_child(hint);right.move_child(hint,1)
func draft_level257() -> int:return int(determination257.value) if is_instance_valid(determination257) else world.determination_level257
func open226() -> void:
 super.open226();determination257.value=world.determination_level257;refresh226()
func refresh226() -> void:
 var level=draft_level257();var slots=world.slots_at257(level)
 capacity.text="草稿 %d / %d槽 · 决心上限%d"%[profile226().cost(draft),slots,world.health_at257(level)]
 for id in rows:
  var count=int(draft.get(id,0));rows[id].count.text=str(count);rows[id].minus.disabled=count<=0
 var error=world.loadout_error257(draft,level)
 apply_button.disabled=error!="";restart_button.disabled=error!="";record_button.disabled=error!=""
 if error!="":feedback.text=error
 stats.text=world.summary_stats226()
func preset226(index: int) -> void:
 if world.slots_at257(draft_level257())>=6:super.preset226(index);return
 draft=INITIAL257[index].duplicate(true);feedback.text="初始4槽草稿，尚未应用。";refresh226()
func adjust226(id: String,amount: int) -> void:
 var proposal=draft.duplicate(true);proposal[id]=int(proposal.get(id,0))+amount
 if proposal[id]<=0:proposal.erase(id)
 var error=world.loadout_error257(proposal,draft_level257())
 if amount>0 and error!="":feedback.text=error;return
 draft=proposal;feedback.text="草稿已修改，尚未应用。";refresh226();focus226(id)
func commit226(restart: bool) -> void:
 var error=world.commit_progress257(draft,cat_hp.value,bat_hp.value,restart,draft_level257())
 if error!="":feedback.text=error
func record226() -> void:
 var error=world.commit_progress257(draft,cat_hp.value,bat_hp.value,true,draft_level257())
 if error!="":feedback.text=error;return
 world.recording226.begin(world,record_mode.get_item_text(record_mode.selected))
 if world.recording226.save(world)!=OK:world.notice219("记录文件写入失败，请检查数据目录")
func export226() -> void:
 feedback.text="统计已导出："+ProjectSettings.globalize_path("user://boss_balance257_last.json") if world.export_stats226()==OK else "导出失败"
