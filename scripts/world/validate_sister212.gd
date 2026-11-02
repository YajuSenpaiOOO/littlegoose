extends SceneTree
var checks: Array[Dictionary]=[]
var w: Node3D
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
 checks.append({"name":label,"pass":ok});print("212 ",ok," ",label)
func shot(tag: String) -> void:
 for i in 4: await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/sister212-"+tag+".png")
func run() -> void:
 w=load("res://scenes/world/world212.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready212: await process_frame
 var r=w.transport206;var d=w.drops206
 r.manual=true;d.manual206=true
 var hp: float=w.player_hp
 check(not w.active114 and not w.context202,"isolated preview preserves forest/combat context")
 r.restart();r.advance(1.5);r.advance(.7);r.advance(.9)
 check(d.spawned206==2,"two toys per pass")
 for i in 26: d.advance206(.1)
 check(d.records[0].locked,"pounce locks target")
 r.change212("pounce");r.advance(3.1)
 check(r.phase212=="recall" and d.recalling212,"automatic pounce to recall")
 var at: Vector2=d.records[0].at
 d.advance206(.8)
 check(d.records[0].at==at,"recall waits one full second before movement")
 r._process(0.);d._process(0.)
 await shot("recall")
 d.advance206(.6)
 check(d.records[0].at.distance_to(at)>.01,"toy returns after warning")
 r.advance(2.7);r.advance(1.1)
 check(r.phase212=="open" and d.records.is_empty(),"lower clears toys and opens counter window")
 w._teleport15(r.person_at+Vector2(0,1.2))
 for i in 4: await physics_frame
 check(r.counter212() and r.hp212==5,"nearby counter damages preview boss")
 check(not r.counter212(),"counter cooldown prevents key spam")
 r._process(0.);await shot("open")
 r.change212("send");r.clock212=.5;r.evaluate();var before: Vector2=r.person_at
 r.parried212();r.advance(.01)
 check(r.phase212=="lower" and r.person_at.distance_to(before)<.01,"parry lowers in place without teleport")
 check(d.records.is_empty(),"parry clears active attacks")
 r.running=false;var clock: float=r.clock212;r.advance(5.)
 check(r.clock212==clock,"pause freezes phase")
 r.running=true;r.change212("open");w._teleport15(r.person_at+Vector2(0,1.2))
 for i in 4: await physics_frame
 for i in 5: r.hit_gate212=0.;r.counter212()
 check(r.phase212=="done" and r.hp212==0,"counter loop reaches victory")
 check(w.player_hp==hp,"formal HP unchanged")
 r.restart();d.clear206()
 check(r.hp212==6 and r.phase212=="prepare" and d.records.is_empty(),"restart resets encounter")
 FileAccess.open("res://docs/sister212-validation.json",FileAccess.WRITE).store_string(JSON.stringify(checks,"\t"))
 quit(0 if checks.all(func(c):return c.pass) else 1)
