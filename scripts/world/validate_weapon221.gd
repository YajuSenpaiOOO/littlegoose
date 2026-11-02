extends "res://scripts/world/validate_plush220.gd"
func shoot221(target: Node3D,sword: bool) -> Dictionary:
 w._clear_combat_shots();w.jelly_fx.clear();w.build170=8;w.apply_paper_build129()
 if sword:w.buffs.levels["balloon_sword"]=1;w._apply_owned_buffs()
 var hp: float=target.hp;var peak=0;var layers=0
 for attempt in 6:
  w.fire_at(target.hit_area.global_position)
  for i in 9:
   await physics_frame
   peak=maxi(peak,w.jelly_fx.bits.size());layers=maxi(layers,w.swords153.layers153.get(target.get_instance_id(),[]).size())
  if target.hp<hp:break
 return {"damage":hp-target.hp,"sugar_peak":peak,"layers":layers}
func run() -> void:
 w=load("res://scenes/world/world221.tscn").instantiate();root.add_child(w);current_scene=w
 while not w.ready220:await process_frame
 w.auto114=false;w.pigs_enabled220=false;w.drop_wait220=999.
 var cat=w.cat220;cat.set_physics_process(false);cat.enter220("chase")
 w._teleport15(w.arena220+Vector2(-2.5,0.));w.hero.set_physics_process(false)
 await settle()
 metrics.normal=await shoot221(cat,false)
 check(metrics.normal.damage>0. and metrics.normal.sugar_peak>0,"real ordinary projectile damages cat and breaks into sugar")
 check(w.jelly_fx.drops.is_empty(),"plush contact does not emit blue jelly body droplets")
 check(cat.impact_contact==Vector3.INF,"contact point consumed after hit")
 metrics.sword=await shoot221(cat,true)
 check(metrics.sword.damage>0. and metrics.sword.layers>0,"real balloon projectile damages cat and attaches a layer")
 check(metrics.sword.sugar_peak==0,"balloon sword retains adhesive feedback instead of candy shatter")
 var frame: Dictionary=w.swords153.frame154(cat)
 check(is_equal_approx(frame.width,cat.visual.texture.get_width()*cat.visual.pixel_size*cat.visual.global_basis.get_scale().x),"cat attachment uses current atlas size rather than old jelly poses")
 if not w.swords153.resting153.is_empty():
  var entry: Dictionary=w.swords153.resting153[0];var at: Vector3=w.swords153.anchor154(entry)
  cat.position.x+=.5;cat._process(0.)
  check(is_equal_approx(w.swords153.anchor154(entry).x-at.x,.5),"attached sword follows actual cat movement")
  cat.enter220("roll");cat.clock220=.35;cat._render_legacy(0.);cat._process(0.)
  frame=w.swords153.frame154(cat)
  check(frame.width>1. and frame.height>0.,"rolling art supplies its own attachment surface")
 cat.enter220("chase");cat._render_legacy(0.);cat._process(0.)
 await shot("weapon221")
 w._clear_combat_shots()
 check(w.swords153.resting153.is_empty() and is_equal_approx(cat.get_meta("locomotion_scale153",1.),1.),"clear removes swords and slow layers")
 # A legacy enemy without the hook retains the existing mapping.
 var legacy=preload("res://scripts/combat/tuantuan121.gd").new();legacy.battle=w;legacy.poses=w.combat_poses;legacy.textures=w.combat_textures;w.add_child(legacy);legacy.set_physics_process(false)
 var old_frame: Dictionary=w.swords153.frame154(legacy)
 check(old_frame.width>0. and not legacy.has_method("attachment_frame154"),"ordinary enemy uses unchanged legacy attachment fallback")
 legacy.queue_free()
 var start: Vector3=cat.position
 cat.next_roll220=99.;cat.path_clock=99.;cat.route=[Vector2(start.x-2.,start.z)]
 cat.set_meta("locomotion_scale153",1.);cat._physics_process(.1)
 var full=Vector2(cat.position.x-start.x,cat.position.z-start.z).length()
 cat.position=start;cat.set_meta("locomotion_scale153",.6);cat._physics_process(.1)
 var slow=Vector2(cat.position.x-start.x,cat.position.z-start.z).length()
 metrics.chase={"full_distance":full,"slowed_distance":slow,"ratio":slow/maxf(full,.0001)}
 check(full>.01 and absf(slow/full-.6)<.005,"adhesive slow affects actual chase displacement")
 cat.position=start;cat.roll_dir220=Vector2.RIGHT;cat.enter220("roll");cat._physics_process(.01)
 check(is_equal_approx(cat.velocity.x,cat.ROLL_SPEED221),"committed roll retains its attack speed under adhesive slow")
 cat.position=start;cat.set_meta("locomotion_scale153",1.)
 cat.receive_hit(999.,Vector3.RIGHT);await create_timer(1.5).timeout
 var bat=w.bats220[0];bat.set_physics_process(false)
 w._teleport15(Vector2(bat.position.x-2.,bat.position.z));await settle()
 metrics.bat=await shoot221(bat,false)
 check(metrics.bat.damage>0. and metrics.bat.sugar_peak>0.,"repair-window bat also receives ordinary projectile break feedback")
 var bat_frame: Dictionary=w.swords153.frame154(bat)
 check(bat_frame.width>0. and bat_frame.width<2.,"bat attachment derives size from its actual displayed sprite")
 w.end220(false);finish()
func finish() -> void:
 var failures=checks.filter(func(c):return not c.pass)
 FileAccess.open("res://docs/weapon221-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failures.size(),"metrics":metrics},"\t"))
 print("WEAPON221_RESULT ",checks.size()," checks ",failures.size()," failures ",metrics)
 quit(0 if failures.is_empty() else 1)
