extends RefCounted
static func resolve(w: Node,roller: CharacterBody3D,other: Object,normal: Vector2) -> bool:
 if other not in w.minions260 or not is_instance_valid(other) or other.dead or not other.has_method("bump271"):return false
 var ids=[roller.get_instance_id(),other.get_instance_id()];ids.sort();var key=str(ids)
 if float(w.pair_until271.get(key,-1.))>w.roster264.seconds:return true
 # move_and_slide removes the normal component after impact; use pre-impact rolling intent.
 var other_motion=Vector2(other.velocity.x,other.velocity.z)
 if other.has_method("enter269") and other.roll_state269=="rolling":other_motion=other.direction269*lerpf(7.2,5.8,clampf(other.distance269/14.,0.,1.))
 var relative=roller.direction269*lerpf(7.2,5.8,clampf(roller.distance269/14.,0.,1.))-other_motion
 if -relative.dot(normal)<1.8:return true
 w.pair_until271[key]=w.roster264.seconds+.4
 var head_on=other.has_method("enter269") and other.roll_state269=="rolling" and roller.direction269.dot(other.direction269)<-.6
 if head_on:
  roller.bump271(normal);other.bump271(-normal);w.mixed_stats271.head_ons+=1
 elif other.has_method("enter269") and other.roll_state269=="rolling":
  roller.direction269=roller.direction269.bounce(normal).normalized();other.direction269=other.direction269.bounce(-normal).normalized()
  roller.bounces269+=1;other.bounces269+=1;roller.wall_gate269=.14;other.wall_gate269=.14;w.mixed_stats271.glances+=1
 else:
  other.bump271(-normal);roller.direction269=roller.direction269.bounce(normal).normalized();roller.bounces269+=1;roller.wall_gate269=.14;w.mixed_stats271.ordinary_bumps+=1
 w.telemetry260.event("actor_collision",{"kind":"head_on" if head_on else "glance" if other.has_method("enter269") else "ordinary","actors":ids})
 return true
