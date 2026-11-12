extends "res://scripts/combat/goose_speech112.gd"
class PausedBubble:
 extends "res://scripts/combat/goose_speech112.gd".Bubble
 var battle264: Node3D
 func _ready() -> void:
  super._ready();body.text="小黑鹅："+words
 func _process(delta: float) -> void:
  if battle264.combat_paused:return
  super._process(delta)
func _advance() -> void:
 if pending.is_empty():return
 var next: Dictionary=pending.pop_front();var anchor: Node=next.anchor.get_ref()
 if not is_instance_valid(anchor) or not anchor.is_inside_tree():_advance();return
 if is_instance_valid(live):live.queue_free()
 var bubble=PausedBubble.new();bubble.battle264=battle;bubble.anchor=next.anchor;bubble.camera=battle.camera;bubble.words=next.text
 bubble.duration=maxf(3.,float(bubble.words.length())/22.+1.3);add_child(bubble);live=bubble;wait_left=bubble.duration
 history.append({"anchor":anchor.get_instance_id(),"text":bubble.words})
 if history.size()>16:history.pop_front()
func _process(delta: float) -> void:
 if battle.combat_paused:return
 super._process(delta)
