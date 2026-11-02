extends "res://scripts/world/perf226_combat.gd"
class IsolatedWorld:
 extends TimedWorld
 func _init() -> void:
  super._init();memory_save116="user://perf227_aircraft_preview.cfg"
 func export_stats226() -> Error:return OK
func run() -> void:
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(),true)
 w=IsolatedWorld.new();root.add_child(w);current_scene=w
 while not w.ready226:await process_frame
 for priority in [-1000,1,79,81,89,91,99,101,109,111,200]:
  var marker=Marker.new();marker.process_priority=priority;marker.key226=priority;marker.owner226=self;root.add_child(marker)
 w.levels226={"paper_plane":1,"balloon_sword":1,"three_player":1,"eye_exercise":1}
 w.paper_memories146.legacy_canvas227=true;w.loadout_name226="性能诊断（非手打）";w.start_battle225(false);w.auto114=true;w.pigs_enabled220=false;w.invulnerability=10000.;w.cat220.set_physics_process(false);w.hero.set_physics_process(false);w.cat220.hp=100000.;w.cat220.max_hp110=100000.
 await sample("full_combo_warmup",10.)
 await sample("full_combo",6.)
 # Disable all sword/pad projection nodes for diagnosis only; keep the same attack.
 for shadow in w.actor_shadows:
  if is_instance_valid(shadow) and w.swords153.is_ancestor_of(shadow):shadow.set_process(false);shadow.set_physics_process(false);shadow.hide()
 w.disable_sword_shadows226=true
 await sample("sword_shadows_off",6.)
 w.paper_memories146.art146.hide()
 await sample("old_canvas_markers_hidden",6.)
 w.swords153.hide()
 await sample("sword_visuals_hidden",6.)
 FileAccess.open("res://docs/perf227-aircraft.json",FileAccess.WRITE).store_string(JSON.stringify(results,"\t"))
 print("PERF227_AIRCRAFT_DONE");quit()
