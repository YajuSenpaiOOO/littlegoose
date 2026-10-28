extends SceneTree
func _initialize() -> void:
 var skill=preload("res://scripts/combat/battle_skills167.gd").new()
 var checks := [skill.reserve_stop167(1),skill.reserve_stop167(2),not skill.reserve_stop167(1)]
 for i in range(3,22): skill.reserve_stop167(i)
 checks.append(skill.stopped_dashes167.size()==8);checks.append(not skill.reserve_stop167(21))
 var ok := checks.all(func(value: bool) -> bool: return value)
 var report := {"checks":checks.size(),"passed":ok,"note":"Overlapping dash IDs must not re-trigger hitstop; history remains bounded."}
 FileAccess.open("res://docs/dance-stop167-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 skill.free();print("DANCE_STOP167 ",report);quit(0 if ok else 1)
