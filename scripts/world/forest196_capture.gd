extends "res://scripts/world/forest194_capture.gd"
class Trial196:
 extends "res://scripts/world/woodland_world196.gd"
 func _hero_script() -> Script: return Walker194
func world_script192() -> Script: return Trial196
func result_prefix192() -> String: return "forest196"
func audit_card196(n: Sprite3D) -> Dictionary:
 return {"name":str(n.name),"texture":n.texture.resource_path if n.texture!=null else "","rotation_degrees":str(n.global_rotation_degrees),"billboard":n.billboard}
func extra_checks192() -> void:
 await super.extra_checks192()
 sample.hero.command=Vector2.ZERO;sample.hero.controls_enabled=false;sample.hero.set_physics_process(false)
 var audit: Array=[]
 audit.append(audit_card196(sample.hero.visual))
 audit.append(audit_card196(sample.trees[0].visual))
 audit.append(audit_card196(sample.forest188.cottage_sprite))
 audit.append(audit_card196(sample.forest188.stage_tree185))
 for record in sample.angle_cards196: audit.append(audit_card196(record.node))
 metrics.card_audit=audit;metrics.angle_card_count=sample.angle_cards196.size()
 verify(sample.angle_cards196.size()>=5,"station and forest post cards registered for reversible upright comparison")
 var all_upright := true
 for record in sample.angle_cards196: all_upright=all_upright and record.node.billboard==BaseMaterial3D.BILLBOARD_DISABLED and absf(record.node.rotation.x)<.0001
 verify(all_upright,"comparison cards upright without changing textures or scale")
 var post: Sprite3D=sample.angle_cards196[0].node
 var original_texture: Texture2D=post.texture;var original_size: float=post.pixel_size
 sample._teleport15(Vector2(post.global_position.x,post.global_position.z+.7));await hour(12.);await settle(120);await picture("post_upright")
 sample.set_upright196(false);await settle(30);await picture("post_camera_facing")
 var restored := true
 for record in sample.angle_cards196: restored=restored and record.node.billboard==record.billboard and record.node.rotation.is_equal_approx(record.rotation)
 verify(restored,"comparison restores original billboard and rotations exactly")
 verify(post.texture==original_texture and is_equal_approx(post.pixel_size,original_size),"upright comparison does not redraw or stretch source assets")
 sample.set_upright196(true)
 sample._teleport15(Vector2(-34.,27.));await settle(120);await picture("near_crown")
 verify(sample.whole67.precleared196>0,"camera proximity catches crowns independently of hero alpha overlap")
 var clear := true
 for entry in sample.whole67.entries.values():
  if entry.target: clear=clear and entry.opacity<.15
 verify(clear,"settled central camera threats have cleared instead of retaining half opacity")
 sample.hero.set_physics_process(true);sample.hero.controls_enabled=true
 sample._teleport15(sample.forest188.PLAN.CENTER+Vector2(23.,3.));await settle(60)
 var route: Array[Vector2]=[]
 for p in [Vector2(18.,3.),Vector2(14.,7.),Vector2(10.,8.),Vector2(6.,6.5)]: route.append(sample.forest188.PLAN.CENTER+p)
 verify(await walk(sample,route),"real southbound entrance traversal remains walkable with new camera policy")
 sample.hero.command=Vector2.ZERO
 metrics.max_camera_preclear=sample.whole67.max_precleared196
