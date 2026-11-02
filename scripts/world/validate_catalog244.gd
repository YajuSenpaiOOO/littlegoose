extends "res://scripts/world/validate_plush220.gd"
class World:
 extends "res://scripts/world/woodland_world244.gd"
 func export_stats226() -> Error:return OK
func run() -> void:
 var P=preload("res://scripts/combat/balance_profile244.gd")
 check(P.error({"distract":1})!="","removed card rejected by profile")
 check(preload("res://scripts/combat/balance_profile241.gd").error({"distract":1})=="","old preview profile preserved")
 var book=preload("res://scripts/combat/buff_book244.gd").new()
 check(book.eligible().all(func(c):return c.id!="distract"),"removed card absent from random choices")
 book.levels={"eye_exercise":1};check(abs(book.rate()-1.25)<.00001,"eye balance retained")
 w=World.new();root.add_child(w);current_scene=w
 while not w.ready228:await process_frame
 check(not w.console226.rows.has("distract"),"console row removed")
 check(w.console226.rows.has("red_banner") and w.console226.rows.has("music_class"),"other card rows retained")
 check(w.levels226.get("distract",0)==0 and w.buffs.level("distract")==0,"saved loadout sanitized")
 FileAccess.open("res://docs/catalog244-validation.json",FileAccess.WRITE).store_string(JSON.stringify(checks,"\t"))
 print("CATALOG244_VALIDATION ",JSON.stringify(checks));quit(1 if checks.any(func(c):return not c["pass"]) else 0)
