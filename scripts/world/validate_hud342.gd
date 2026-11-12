extends SceneTree
class Trial:
 extends "res://scripts/world/woodland_world342.gd"
 func load_test226() -> void:pass
 func export_stats226() -> Error:return OK
var failures: Array[String]=[]
var config: Dictionary={}
func _initialize() -> void:call_deferred("run")
func check(ok: bool, label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func capture(tag: String) -> void:
 for i in 3:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/hud342-"+tag+".png")
func run() -> void:
 var folder:=ProjectSettings.globalize_path("user://")
 for file in DirAccess.get_files_at(folder):
  if file.ends_with(".cfg"):config[file]=FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()
 var w=Trial.new()
 root.add_child(w);current_scene=w
 var limit:=Time.get_ticks_msec()+180000
 while not is_instance_valid(w.combat_hud342) and Time.get_ticks_msec()<limit:await process_frame
 if not is_instance_valid(w.combat_hud342):quit(1);return
 w.set_process(false);w.set_physics_process(false);w.hero.set_physics_process(false)
 w.theatre314.set_process(false);w.theatre314.cancel();w.theatre314.sample(4.06);w.theatre314.finished=true
 w.waiting_intro314=false;w.core_phase326=true;w.fastener_hp321=108.
 w.active114=true;w.combat_paused=false
 w.levels226={"flashlight":1};w.cooldown288=0.
 var hud=w.combat_hud342
 hud.set_process(false)
 var enemy=w.spawn301();enemy.set_physics_process(false)
 enemy.hit_area.collision_layer=8;enemy.state301="idle";enemy.render301()
 enemy.health_time=0.;w.target114=null
 hud._process(.01)
 check(hud.bars342.is_empty(),"full unselected mob is hidden")
 enemy.hp=12.;hud._process(.01)
 check(hud.bars342.size()==1 and hud.bars342[0].trail>hud.bars342[0].ratio,"damage shows unified bar with trailing damage")
 check(enemy.health_fill.layers==0,"legacy actor bar suppressed")
 check(hud.slot342.state=="ready" and hud.slot342.id=="flashlight","flashlight ready")
 await capture("ready")
 check(not w.boss_bar326.visible and not w.state_hud288.visible,"legacy boss and Q panels removed")
 check(hud.boss_rect342.size.x>100. and not hud.boss_rect342.intersects(hud.slot_rect342),"boss and Q do not overlap")
 enemy.health_time=0.;w.target114=null;hud._process(3.)
 check(hud.bars342.is_empty(),"mob bar expires")
 w.target114=enemy;hud._process(.01)
 check(hud.bars342.size()==1,"targeting shows mob bar")
 w.cannon_hp326[0]=8.;w.cannon_hp326[1]=0.;w.rebuild_index334=1;w.rebuild_age334=3.5
 hud._process(.01)
 check(hud.bars342.size()==3 and hud.bars342[-1].repair and is_equal_approx(hud.bars342[-1].ratio,.5),"cannon damage and rebuild share renderer")
 w.cooldown288=12.;hud._process(.01)
 check(hud.slot342.state=="cooldown" and is_equal_approx(hud.slot342.ratio,.6),"Q cooldown progress")
 await capture("cooldown")
 w.skill288=true;w.ended288=false;w.transform288.playing=true;w.transform288.age=w.transform288.INTRO+1.
 hud._process(.01)
 check(hud.slot342.state=="active","Q active countdown")
 w.transform288.age=w.transform288.END_BEGIN-1.
 hud._process(.01)
 check(hud.slot342.state=="red","Q final red period")
 await capture("active")
 w.transform288.playing=false;w.skill288=false
 w.levels226={"hero_moment":1};w.moment161.left161=3.
 check(w.active_slot342().state=="active" and w.active_slot342().id=="hero_moment","same slot supports hero moment")
 w.moment161.left161=0.;w.moment161.cooldown161=10.
 check(is_equal_approx(w.active_slot342().ratio,.5),"hero moment cooldown")
 w.levels226={"homework":1};w.paper_memories146.pages146.clear()
 check(w.active_slot342().state=="collect","notebook waits for pages rather than fake cooldown")
 w.paper_memories146.pages146.append({})
 check(w.active_slot342().state=="ready","notebook ready")
 w.paper_memories146.writing146=true
 check(w.active_slot342().state=="active","notebook writing")
 w.paper_memories146.writing146=false;w.levels226={}
 check(w.active_slot342().state=="empty","no equipped active hides slot")
 w.combat_paused=true;hud._process(.01)
 check(not hud.visible,"pause hides battle HUD")
 w.combat_paused=false;enemy.dead=true;w.fastener_hp321=0.;hud._process(.01)
 check(hud.boss342.is_empty(),"castle defeated clears boss bar")
 for file in config:check(FileAccess.get_file_as_bytes(folder+file).hex_encode().sha256_text()==config[file],"config unchanged "+file)
 FileAccess.open("res://docs/hud342-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"complete":true,"failures":failures,"screenshots":["hud342-ready.png","hud342-cooldown.png","hud342-active.png"]},"\t"))
 print("HUD342_DONE ",failures)
 quit(0 if failures.is_empty() else 1)
