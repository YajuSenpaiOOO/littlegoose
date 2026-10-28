extends "res://scripts/world/balloon_sword153_probe.gd"
class Trial154:
 extends "res://scripts/world/woodland_world154.gd"
 func _hero_script() -> Script: return Walker146
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func capture154(tag: String) -> void:
 var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/balloon_sword154_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial154.new();s.memory_save116="user://sword154_probe_tmp.cfg";root.add_child(s)
 while not is_instance_valid(s.swords153): await physics_frame
 s.hill_visited136=true;s.trial152=true;s.paper_trial129=false;s.start_combat();disable_enemies(s);s.clear_standby119();s.hero.controls_enabled=true
 var g: Vector2=s.meadow.landmarks.grove;s._teleport15(g+Vector2(0,4.));await settle72(15)
 s.time55.preview_at(12.);s.time55.visual_hour=12.;s.time55.apply_look()
 for e in s.enemies: e.hide();e.hit_area.collision_layer=0
 s.build153=0;s.apply_paper_build129();var m: Node3D=s.swords153
 # Real native collision against a vertical scene object, with a horizontal sword.
 var wall := StaticBody3D.new();wall.collision_layer=2
 var collision := CollisionShape3D.new();var shape := BoxShape3D.new();shape.size=Vector3(.3,1.6,1.1);collision.shape=shape;wall.add_child(collision)
 var box := MeshInstance3D.new();var geometry := BoxMesh.new();geometry.size=shape.size;box.mesh=geometry;wall.add_child(box)
 var at: Vector3=s.hero.position+Vector3(-2.2,.8,-3.);wall.position=at;s.add_child(wall)
 await settle72(3);s.data_shot110(at-Vector3(1.8,0,0),Vector3.RIGHT*8.,2.);await settle72(20)
 verify(not m.resting153.is_empty(),"a real horizontal sword collides and sticks to the scene prop")
 if m.resting153.is_empty(): quit(1);return
 var stuck: Dictionary=m.resting153[-1];var node: Sprite3D=stuck.node
 var actual: Vector2=s.camera.unproject_position(node.position+node.basis.y*.2)-s.camera.unproject_position(node.position)
 verify(actual.normalized().dot(s.screen_direction(node.position,Vector3.RIGHT).normalized())>.98,"scene adhesion retains the incoming horizontal orientation instead of standing upright")
 await capture154("horizontal_prop")
 var before: Vector3=m.anchor154(stuck);wall.position+=Vector3(.4,0,0);wall.rotate_y(.3);await process_frame
 verify(m.anchor154(stuck).distance_to(wall.to_global(stuck.surface_point154))<.001 and m.anchor154(stuck).distance_to(before)>.1,"scene adhesion uses a local surface anchor and follows moved props")
 s._clear_combat_shots();wall.queue_free()
 var enemy: CharacterBody3D=s.enemies[0];enemy.show();enemy.hp=10000.;enemy.max_hp110=10000.;enemy.hit_area.collision_layer=8
 enemy.position=s.hero.position+Vector3(0,0,-3.5);enemy.position.y=s.floor_height(Vector2(enemy.position.x,enemy.position.z))+.06
 enemy.hit_left=0.;enemy.landing_left=0.;enemy.hopping=false;enemy.attack_phase="approach";enemy._render_legacy(0.)
 var body: Dictionary=m.frame154(enemy);var tip: Vector3=body.origin+Vector3.UP*body.height*.86
 m.attach153(enemy,tip,Vector3.DOWN);stuck=m.resting153[-1]
 var idle_tip: Vector3=m.anchor154(stuck)
 await capture154("head_idle")
 enemy.attack_phase="windup";enemy.phase_clock=enemy.WINDUP*.8;enemy.hit_left=0.;enemy._render_legacy(0.)
 var squat_tip: Vector3=m.anchor154(stuck)
 print("ANCHOR154 idle=",idle_tip," squat=",squat_tip)
 verify(squat_tip.y<idle_tip.y-.18,"a sword on Tuantuan's head follows the authored crouching frame and its squash")
 await capture154("head_squat")
 enemy.attack_phase="approach";enemy.hopping=false;enemy._render_legacy(.55)
 verify(absf(m.anchor154(stuck).y-idle_tip.y-.55)<.04,"the same adhesion point rises with the visible airborne body rather than the ground hurt capsule")
 enemy._render_legacy(0.);s.set_physics_process(false)
 m.reset153();m.attach153(enemy,tip,Vector3.DOWN);stuck=m.resting153[-1]
 # Let the struck sword ring down in place, with the world and AI frozen.
 var bends := [];var squashes := [];var anchored: Vector3=m.anchor154(stuck)
 for i in 50:
  m.step153(1./60.);bends.append(stuck.bend154);squashes.append(stuck.squash154)
  if i==5: await capture154("elastic_rebound")
 verify(bends.min()<-.02 and bends.max()>.02 and maxf(absf(bends.min()),absf(bends.max()))>.1 and squashes.min()<-.02,"impact springs visibly overshoot and rebound instead of merely rotating a rigid quad")
 verify(m.mesh154.subdivide_depth>=24 and anchored.distance_to(m.anchor154(stuck))<.001,"subdivided geometry bends while the adhesive tip stays fixed")
 await process_frame
 var shade: Node=stuck.node.get_child(1)
 var ink: ShaderMaterial=m.ink154(stuck.node)
 verify(shade.visible and shade.ink.shader==preload("res://scripts/art/balloon_shadow154.gdshader") and is_equal_approx(shade.ink.get_shader_parameter("bend154"),ink.get_shader_parameter("bend154")),"the terrain shadow receives the same elastic deformation as the sword")
 s.set_physics_process(true);s._clear_combat_shots();enemy.hide();enemy.hit_area.collision_layer=0
 # Stand, slant and lie across the terrain at their actual incoming angles.
 for i in 3:
  var pos: Vector3=s.hero.position+Vector3((i-1)*1.7,0,-3.7);pos.y=s.floor_height(Vector2(pos.x,pos.z))+.09
  m.attach153(null,pos,[Vector3.DOWN,Vector3(.7,-1,0).normalized(),Vector3.RIGHT][i])
 await settle72(12);await capture154("angles_and_shadows")
 RenderingServer.force_draw(false);var shadow_on := root.get_texture().get_image()
 for entry in m.resting153: entry.node.get_child(1).hide()
 RenderingServer.force_draw(false);var shadow_off := root.get_texture().get_image()
 var dark_pixels := 0
 for y in range(300,650):
  for x in range(400,1100):
   var a := shadow_on.get_pixel(x,y);var b := shadow_off.get_pixel(x,y)
   if a.r+a.g+a.b<b.r+b.g+b.b-.025: dark_pixels+=1
 print("SHADOW_PIXELS154 ",dark_pixels)
 verify(dark_pixels>20,"rendered sword shadows visibly darken the surrounding terrain")
 verify(m.resting153.size()==3 and is_equal_approx(enemy.get_meta("locomotion_scale153",1.),1.),"visual revision keeps independent lifetimes and clears enemy slow on reset")
 var report := {"checks":checks,"failures":failures,"idle_tip_y":idle_tip.y,"squat_tip_y":squat_tip.y,"bend_min":bends.min(),"bend_max":bends.max(),"squash_min":squashes.min(),"shadow_pixels":dark_pixels,"note":"Only changed adhesion, elasticity and shadow behavior checked; no repeated map suite."}
 FileAccess.open("res://docs/balloon-sword154-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("BALLOON_SWORD154_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
