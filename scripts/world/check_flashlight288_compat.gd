extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var old=preload("res://scripts/art/flashlight_transform287.gd").new()
 var fresh=preload("res://scripts/art/flashlight_transform288.gd").new()
 var a=preload("res://scripts/combat/red_alert263.gd").new();var b=preload("res://scripts/combat/red_alert288.gd").new()
 var ok=old.red_seconds()==2. and fresh.red_seconds()==3. and a.warning_text263().contains("×2") and b.warning_text263().contains("1.58")
 ok=ok and preload("res://scripts/combat/balance_profile275.gd").error({"flashlight":1,"homework":1},4)==""
 var script: Script=load("res://scripts/world/woodland_world288.gd");ok=ok and script.can_instantiate()
 old.free();fresh.free();a.free();b.free()
 var f=FileAccess.open("res://docs/flashlight288-compat.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":ok,"legacy287_red_seconds":2,"new288_red_seconds":3,"legacy_profile_and_hud_unchanged":true},"  "));f.close()
 print("FLASHLIGHT288_COMPAT ",ok);quit(0 if ok else 1)
