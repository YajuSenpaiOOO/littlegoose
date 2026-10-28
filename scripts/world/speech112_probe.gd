extends "res://scripts/world/combat111_probe.gd"
class Battle112:
 extends "res://scripts/world/woodland_world112.gd"
 var permit := false
 func _hero_script() -> Script: return Fighter
 func fire_input_held() -> bool: return false
 func start_combat(reposition := true) -> void:
  if permit: super.start_combat(reposition)
func run() -> void:
 root.size=Vector2i(1600,1000);DisplayServer.window_set_size(root.size)
 var s := Battle112.new();root.add_child(s)
 while not s.woodland_ready112: await physics_frame
 s.permit=true;s.start_combat();await settle72(15);disable_enemies(s)
 var speech: CanvasLayer=s.speech112
 var card: Dictionary=preload("res://scripts/combat/cards110.gd").POOL[0]
 s.buffs.apply("slingshot");s.wave_reward_pending=true;s._continue_after_buff(card);disable_enemies(s)
 await settle72(60)
 verify(is_instance_valid(speech.live) and speech.live.words==card.line,"single card line appears as goose speech")
 verify(speech.live.anchor.get_ref()==s.goose and speech.live.body.visible_characters>0,"bubble follows primary goose with typewriter text")
 verify(s.encounter_hud.notice_sub.text!=card.line,"quote is removed from centered descriptive notification")
 var image := await snapshot();image.save_png("res://docs/captures/world_restart/speech112_single.png")
 var before: Vector2=speech.live.position;s.goose.position.x+=1.;speech.live._process(.2)
 verify(speech.live.position.distance_to(before)>2.,"screen bubble tracks its moving 3D speaker")
 s.buffs.apply("forest_fireboy");s._apply_owned_buffs();speech.say_card(preload("res://scripts/combat/cards110.gd").POOL[4].line)
 verify(speech.live.words=="我要玩火娃！" and speech.pending.size()==1,"two goose dialogue strips speaker tags and queues the second response")
 speech.wait_left=0.;speech._process(.01)
 verify(speech.live.words=="哼，让给你了！" and speech.live.anchor.get_ref()==s.skills110.geese110[0],"second goose speaks its own original line")
 await settle72(30);image=await snapshot();image.save_png("res://docs/captures/world_restart/speech112_second.png")
 s.buffs.apply("three_player");s._apply_owned_buffs();speech.say_card(preload("res://scripts/combat/cards110.gd").POOL[5].line)
 verify(speech.pending.size()==2,"three player card schedules all three speakers")
 speech.say_card("不要一心二用呀")
 verify(speech.pending.is_empty() and speech.live.words=="不要一心二用呀","new speech cancels old reply chain")
 s.draft_open=true;speech._process(.01)
 verify(speech.live==null and speech.pending.is_empty(),"opening a draft cancels speech")
 s.draft_open=false;speech.say_card(card.line);s.start_combat()
 verify(speech.live==null and speech.pending.is_empty(),"retry clears pending and visible speech together")
 disable_enemies(s);s.wave_reward_pending=false;s.wave_state="cleared";s.reward_offered=true;s._continue_after_buff(card)
 verify(is_instance_valid(speech.live) and speech.live.words==card.line and s.result_open,"final reward still speaks alongside victory result")
 speech.say_card("测试锚点");var temporary := Node3D.new();s.add_child(temporary);speech.live.anchor=weakref(temporary);temporary.queue_free()
 for i in 4: await process_frame
 verify(not is_instance_valid(speech.live),"freed speaker removes bubble without stale references")
 speech.say_card(card.line);speech.live.duration=.01
 for i in 4: await process_frame
 verify(not is_instance_valid(speech.live),"expired speech removes itself without leaking a layer")
 speech.say_card(card.line);s._leave_encounter()
 verify(speech.live==null and speech.pending.is_empty(),"leaving encounter dismisses all speech")
 var data := {"checks":checks,"failures":failures}
 var file := FileAccess.open("res://docs/speech112-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));print("SPEECH112_DONE ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
