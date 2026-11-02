extends SceneTree
class Stub:
 extends Node3D
 var levels226={"three_player":1,"eye_exercise":1,"paper_plane":1,"exercise":1}
 var cat_health226=160.
 var bat_health226=32.
 var memory_kit116=preload("res://scripts/combat/memory_kit168.gd").new()
 func close_console226() -> void:pass
 func summary_stats226() -> String:return "GUI validation"
 func export_stats226() -> Error:return OK
 func commit_console226(_levels: Dictionary,_cat_hp: float,_bat_hp: float,_restart: bool) -> String:return ""
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var stub=Stub.new();root.add_child(stub)
 var layer=CanvasLayer.new();layer.layer=70;stub.add_child(layer)
 var ui=preload("res://scripts/combat/balance_console226.gd").new();ui.world=stub;layer.add_child(ui);ui.open226()
 for i in 5:await process_frame
 var exact_hp=ui.cat_hp.value==160. and ui.bat_hp.value==32.
 print("GUI226 health roundtrip=",exact_hp," cat=",ui.cat_hp.value," bat=",ui.bat_hp.value)
 var button=ui.rows.three_player.minus
 var at: Vector2=button.get_global_rect().get_center()
 var motion=InputEventMouseMotion.new();motion.position=at;motion.global_position=at;root.push_input(motion,true)
 await process_frame
 print("GUI226 hover=",root.gui_get_hovered_control()," rect=",button.get_global_rect()," size=",root.size," viewport=",root.get_visible_rect())
 var press=InputEventMouseButton.new();press.button_index=MOUSE_BUTTON_LEFT;press.pressed=true;press.position=at;press.global_position=at;root.push_input(press,true)
 await process_frame
 press=press.duplicate();press.pressed=false;root.push_input(press,true)
 await process_frame
 print("GUI226 draft=",ui.draft)
 quit(0 if ui.draft.get("three_player",0)==0 and exact_hp else 1)
