extends "res://scripts/world/woodland105_final_ab.gd"
class Enemy:
 extends "res://scripts/combat/tuantuan36.gd"
 func _physics_process(delta: float) -> void:
  var t := Time.get_ticks_usec();super._physics_process(delta)
  if battle.timing: battle.sum105("enemy_physics",t)
 func _render_legacy(lift: float) -> void:
  var t := Time.get_ticks_usec();super._render_legacy(lift)
  if battle.timing: battle.sum105("enemy_render",t)
 func _pose(key: String,lift: float) -> void:
  var t := Time.get_ticks_usec();super._pose(key,lift)
  if battle.timing: battle.sum105("enemy_pose",t)
class Hero:
 extends LivingActor
 func _physics_process(delta: float) -> void:
  var t := Time.get_ticks_usec();super._physics_process(delta)
  if battle.timing: battle.sum105("hero_physics",t)
class Shadow:
 extends "res://scripts/combat/actor_shadow105.gd"
 func _physics_process(delta: float) -> void:
  var t := Time.get_ticks_usec();super._physics_process(delta)
  if battle.timing: battle.sum105("shadow_physics",t)
 func _process(delta: float) -> void:
  var t := Time.get_ticks_usec();super._process(delta)
  if battle.timing: battle.sum105("shadow_process",t)
class FX:
 extends "res://scripts/combat/material_fx33.gd"
 func _process(delta: float) -> void:
  var t := Time.get_ticks_usec();super._process(delta)
  if battle.timing: battle.sum105("material_fx_process",t)
class Sample:
 extends Cost105
 func _limit_prop_shadows() -> void:
  var t := Time.get_ticks_usec();super._limit_prop_shadows()
  if timing: sum105("limit_prop_shadows",t)
 func _sync_tracks() -> void:
  var t := Time.get_ticks_usec();super._sync_tracks()
  if timing: sum105("sync_tracks",t)
 func _update_grass() -> void:
  var t := Time.get_ticks_usec();super._update_grass()
  if timing: sum105("grass_upload",t)
 func _sync_root_fades15() -> void:
  var t := Time.get_ticks_usec();super._sync_root_fades15()
  if timing: sum105("root_fade_sync",t)
 func _update_tree_blending() -> void:
  var t := Time.get_ticks_usec();super._update_tree_blending()
  if timing: sum105("tree_blending",t)
 func _hero_script() -> Script: return Hero
 func _enemy_script() -> Script: return Enemy
 func _actor_shadow_script105() -> Script: return Shadow
 func _material_fx_script() -> Script: return FX
func run() -> void:
 print("BACKEND105 ",ProjectSettings.get_setting("physics/3d/physics_engine"))
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(),true)
 var sample := Sample.new();root.add_child(sample)
 while not sample.woodland_ready105: await physics_frame
 await settle72(30);sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 sample.allow_battle=true;sample.start_combat(true);sample.round_index=1;sample._spawn_next_round();sample.hero.controls_enabled=true;await settle72(80)
 var data := {}
 data.ai=await take105(sample,"components_ai",false,1.,180)
 data.fire=await take105(sample,"components_fire",true,1.,180)
 data.stress=await take105(sample,"components_rate8",true,8.,180)
 data.gpu_last=RenderingServer.viewport_get_measured_render_time_gpu(root.get_viewport_rid())
 sample.process_mode=Node.PROCESS_MODE_DISABLED;data.frozen=await measure104(sample,"frozen",false,180)
 var file := FileAccess.open("res://docs/woodland105-jolt.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));print("COMPONENTS_DONE");quit()
