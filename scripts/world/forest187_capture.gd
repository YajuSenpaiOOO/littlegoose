extends "res://scripts/world/forest186_probe.gd"
class Trial187:
 extends "res://scripts/world/woodland_world187.gd"
 func _hero_script() -> Script: return Walker186
func shot187(tag: String) -> void:
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/forest187_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000);var s := Trial187.new();s.memory_save116="user://forest187_capture_tmp.cfg";root.add_child(s)
 while not s.forest_ready187: await physics_frame
 var route187: Array[Vector2]=[]
 for p in D.TRAIL: route187.append(P.CENTER+p)
 verify(await walk(s,route187),"hero walks from entrance to cottage across revised visual route")
 var seams187 := true
 for i in range(1,s.forest187.joins187.size()):
  var before: Array=s.forest187.joins187[i-1];var after: Array=s.forest187.joins187[i]
  seams187=seams187 and before[2].distance_to(after[0])<.00001 and before[3].distance_to(after[1])<.00001
 verify(seams187,"every adjacent road section shares both corner edge vertices")
 s._teleport15(P.CENTER+Vector2(-10.4,-7.5));await settle(100);await shot187("cottage")
 s._teleport15(P.CENTER+Vector2(4.,3.));await settle(100);await shot187("central")
 s.forest187.set_grounding184(false);await settle(3);await shot187("central_shadow_off")
 s.forest187.set_grounding184(true);await settle(3);await shot187("central_shadow_on")
 s._teleport15(P.CENTER+P.PATH[2]);await settle(150);await shot187("stairs_transition")
 s._teleport15(Vector2(-4.7,-2.6));await settle(180);await shot187("home")
 verify(s.forest_mood187.amount<.001,"home resets forest grade after soft foreground fade")
 verify(s.forest187.grounded187.size()==2,"house and tree have separate terrain-conforming lower layers")
 verify(s.forest187.joins187.size()>8,"continuous joined road cross sections constructed")
 FileAccess.open("res://docs/forest187-final-visual.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures}," "))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("FOREST187_FINAL_DONE ",JSON.stringify({"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
