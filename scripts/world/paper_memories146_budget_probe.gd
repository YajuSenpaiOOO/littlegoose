extends SceneTree
func _initialize() -> void:
 var s := preload("res://scripts/world/woodland_world146.gd").new()
 s.buffs.levels={"paper_plane":1};var interval: float=s.attack_cooldown()
 assert(is_equal_approx(interval,1.))
 s.buffs.levels.eye_exercise=1
 assert(is_equal_approx(s.attack_cooldown(),1./1.5))
 # Packet final damage is already normalized and must not pass the old charge factor again.
 assert(is_equal_approx(s.damage_for_shot({"packet146":true,"fixed_damage110":4.941176,"charged":true}),4.941176))
 assert(is_equal_approx(s.damage_for_shot({"charged":true,"damage_multiplier":12.}),12.*s.Profile.FIRE_CD/s.START_INTERVAL113))
 var kit := preload("res://scripts/combat/memory_kit146.gd").new()
 var config := ConfigFile.new();config.set_value("memories","version",3);config.set_value("memories","owned","broken")
 config.save("user://memory146_invalid_tmp.cfg");kit.load_from("user://memory146_invalid_tmp.cfg")
 assert(kit.owned.paper_plane==1 and kit.owned.homework==1)
 DirAccess.remove_absolute(ProjectSettings.globalize_path("user://memory146_invalid_tmp.cfg"))
 s.free();print("MEMORY146_VALUE_SMOKE_PASS");quit()
