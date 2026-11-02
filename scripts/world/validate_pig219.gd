extends SceneTree
var w: Node3D
var checks: Array[Dictionary]=[]
var metrics := {}
func _initialize() -> void:call_deferred("run")
func check(ok: bool,label: String) -> void:
 checks.append({"name":label,"pass":ok});print("219 ",ok," ",label)
func shot(tag: String) -> void:
 for i in 4:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/pig219-"+tag+".png")
func sample219(enabled: bool,stress: bool) -> Dictionary:
 var s=w.cotton219;var p=w.pig219
 s.clear219();s.enabled219=enabled;s.stress219=stress;s.cpu_samples.clear();s.peak_active=0;p.reset219();p.manual219=false;s.manual219=false
 var gaps: Array[float]=[];var uploads: Array[int]=[]
 var previous=Time.get_ticks_usec();var begin=previous
 while Time.get_ticks_usec()-begin<3500000:
  await process_frame
  var now=Time.get_ticks_usec()
  if now-begin>500000:gaps.append(float(now-previous)/1000.);uploads.append(s.upload_us)
  previous=now
 var total=0.;var cpu=0.;var upload=0.
 for value in gaps:total+=value
 for value in s.cpu_samples:cpu+=value
 for value in uploads:upload+=value
 gaps.sort()
 return {"mean_frame_ms":total/maxi(1,gaps.size()),"p95_frame_ms":gaps[int(gaps.size()*.95)] if not gaps.is_empty() else 0.,"mean_update_us":cpu/maxi(1,s.cpu_samples.size()),"mean_upload_us":upload/maxi(1,uploads.size()),"peak_active":s.peak_active,"samples":gaps.size()}
func run() -> void:
 w=load("res://scenes/world/world219.tscn").instantiate();root.add_child(w);current_scene=w
 var deadline=Time.get_ticks_msec()+180000
 while not w.ready219 and Time.get_ticks_msec()<deadline:await process_frame
 if not w.ready219:check(false,"world init deadline");finish();return
 var p=w.pig219;var s=w.cotton219
 p.manual219=true;s.manual219=true;w.hero.set_physics_process(false)
 p.reset219();s.clear219()
 check(w.hero.get_script().resource_path.ends_with("hero192.gd"),"hero192 retained")
 check(not w.active114 and not w.context202,"formal combat/context untouched")
 check(p.poses.size()==3 and s.batches.size()==3,"three pig states and three shared cotton batches")
 p._process(0.)
 check(p.nose219(0).distance_to(p.nose219(1))>.05,"independent calibrated nostril anchors")
 p.advance219(.8)
 check(s.active.is_empty(),"telegraph phase emits no hazards")
 await shot("warning")
 p.advance219(.2);p.advance219(.3)
 check(s.counts219().x==2 and s.nose_count[0]>0 and s.nose_count[1]>0,"both nostrils emit separate dangerous clumps")
 await shot("spray")
 s.clear219()
 var children=s.get_child_count()
 for i in 60:s.emit219(p.nose219(i%2),p.direction219,i%2)
 check(s.counts219()==Vector2i(16,32),"normal active cap 16 dangerous and 32 decorative")
 check(s.get_child_count()==children and children==3,"emission creates no scene nodes or physics bodies")
 s.clear219()
 check(s.free_danger.size()==48 and s.free_decor.size()==96,"clear recycles all fixed slots")
 s.emit219(p.nose219(0),p.direction219,0)
 var slot: int=s.active[0];var before: Vector3=s.records[slot].pos
 s.running=false;s.advance219(.5)
 check(s.records[slot].pos==before,"pause freezes cotton motion")
 s.running=true;s.clear219()
 var hp: float=w.player_hp
 var h=w.floor_height(w.spawn216)
 w.hero.position=Vector3(w.spawn216.x,h,w.spawn216.y)
 w.hero.dodge_invulnerability=0.;w.hero.parry_t=0.;w.hero.guarding109=false
 s.emit219(w.hero.position+Vector3(-.12,.35,0),Vector2.RIGHT,0)
 s.advance219(.08)
 check(w.hearts219==4 and w.player_hp==hp,"swept impact reduces preview hearts only")
 s.clear219();w.hero.dodge_invulnerability=.3
 check(s.contact219()=="dodge","existing dodge invulnerability respected")
 w.hero.dodge_invulnerability=0.;w.hero.guarding109=true;w.hero.parry_t=0.
 check(s.contact219()=="guard","existing sustained guard respected")
 w.hero.guarding109=false;w.hero.parry_t=.15;w.hero.dash_left=0.;w.invulnerability=0.
 check(s.contact219()=="parry","existing parry window respected")
 w.hero.cancel_guard109();w.hero.parry_t=0.
 s.clear219();w._teleport15(w.spawn216+Vector2(1.8,0.))
 # A temporary fixture checks actual scenery ray blocking, not just a branch flag.
 var wall=StaticBody3D.new();wall.collision_layer=1
 var shape=CollisionShape3D.new();var box=BoxShape3D.new();box.size=Vector3(.3,2.,2.)
 shape.shape=box;wall.add_child(shape);w.add_child(wall)
 wall.global_position=p.global_position+Vector3(-1.,.6,.3)
 for i in 3:await physics_frame
 var blocked: int=s.walls_count
 s.emit219(p.nose219(0),p.direction219,0)
 for i in 40:s.advance219(.02)
 check(s.walls_count>blocked,"world solid fixture stops cotton")
 wall.queue_free();s.clear219()
 p.phase219="spray";p.age219=0.;p.update_pose219()
 w._teleport15(w.spawn216+Vector2(-.8,0.))
 var e=InputEventKey.new();e.pressed=true;e.physical_keycode=KEY_E;w._input(e)
 check(p.phase219=="flat","temporary near E interrupts pig spray")
 await shot("flat")
 p.advance219(1.6)
 check(p.phase219=="gone" and not p.visual.visible and p.body.collision_layer==0,"deflated pig leaves no invisible blocking footprint")
 p.advance219(2.1)
 check(p.phase219=="idle" and p.body.collision_layer==1,"preview loops only after empty two-second interval")
 p.reset219();p.advance219(1.);p.advance219(4.3)
 check(p.phase219=="flat","pig automatically deflates after timed spray")
 s.clear219()
 for i in 100:s.emit219(p.nose219(0),p.direction219,0)
 for i in 100:s.advance219(.02)
 check(s.active.is_empty(),"all emitted cotton expires")
 w._teleport15(w.spawn216+Vector2(-1.8,-1.1))
 w.time55.preview_at(12.);w.time55.visual_hour=12.;w.time55.apply_look()
 metrics.off=await sample219(false,false)
 metrics.normal=await sample219(true,false)
 await shot("day")
 metrics.stress=await sample219(true,true)
 check(s.counts219().x<=48 and s.counts219().y<=96,"threefold stress respects hard caps")
 await shot("stress")
 w.time55.preview_at(20.);w.time55.visual_hour=20.;w.time55.apply_look();p.reset219()
 await create_timer(1.4).timeout;await shot("night")
 e.physical_keycode=KEY_F7;w._input(e)
 check(w.hearts219==5 and s.active.is_empty() and p.phase219=="idle","F7 clears and restores complete preview")
 finish()
func finish() -> void:
 var failures=checks.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/pig219-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failures.size(),"metrics":metrics,"scope":"isolated pig in real forest; timings are short local samples, not full boss balance/performance approval"},"\t"))
 print("219_RESULT ",checks.size()," checks ",failures.size()," failures ",metrics)
 quit(0 if failures.is_empty() else 1)
