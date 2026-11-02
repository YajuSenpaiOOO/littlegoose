extends "res://scripts/combat/tuantuan121.gd"
var ready220 := false
var phase220 := "chase"
var clock220 := 0.
var next_roll220 := 2.
var roll_dir220 := Vector2.ZERO
var roll_origin220 := Vector2.ZERO
var locked220 := Vector2.ZERO
var roll_count220 := 0
var contact_count220 := 0
var rolled_hits220 := 0
var lane220: MeshInstance3D
var walk220: Array[AtlasTexture]=[]
var rolls220: Array[AtlasTexture]=[]
var walk_data220: Dictionary
var roll_data220: Dictionary
var ink220: ShaderMaterial
var walk_sheet220: Texture2D
var roll_sheet220: Texture2D
var clock_anim220 := 0.
var facing_right220 := false
func _ready() -> void:
 super._ready()
 collision_mask=1|2;collision_layer=16;physics_interpolation_mode=Node.PHYSICS_INTERPOLATION_MODE_OFF
 var physical: CapsuleShape3D=get_child(0).shape;physical.radius=.95;physical.height=1.9;get_child(0).position.y=.95
 var target: CapsuleShape3D=hit_area.get_child(0).shape;target.radius=1.;target.height=2.;hit_area.position.y=.7
 cue.set_process(false);cue.hide();small_cue.set_process(false);small_cue.hide();health_fill.hide();shadow.hide()
 walk_data220=JSON.parse_string(FileAccess.get_file_as_string("res://assets/fat_cat216/frames.json"))
 roll_data220=JSON.parse_string(FileAccess.get_file_as_string("res://assets/fat_cat220/roll_frames.json"))
 walk_sheet220=load("res://assets/fat_cat216/walk_sheet.png");roll_sheet220=load("res://assets/fat_cat220/roll_sheet.png")
 for f in walk_data220.frames:walk220.append(atlas220(walk_sheet220,f.region))
 for f in roll_data220.frames:rolls220.append(atlas220(roll_sheet220,f.region))
 visual.billboard=BaseMaterial3D.BILLBOARD_DISABLED;visual.shaded=true
 ink220=ShaderMaterial.new();ink220.shader=preload("res://scripts/art/fat_cat220.gdshader");visual.material_override=ink220
 shadow=preload("res://scripts/combat/actor_shadow105.gd").new();shadow.battle=battle;shadow.visual=visual;shadow.opacity_scale=.6;add_child(shadow);battle.actor_shadows.append(shadow)
 lane220=MeshInstance3D.new();lane220.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var mat=StandardMaterial3D.new();mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;mat.albedo_color=Color("e4a28d");mat.cull_mode=BaseMaterial3D.CULL_DISABLED;lane220.material_override=mat;add_child(lane220);lane220.top_level=true;lane220.global_transform=Transform3D.IDENTITY
 ready220=true;_render_legacy(0.)
func atlas220(sheet: Texture2D,rect: Array) -> AtlasTexture:
 var atlas=AtlasTexture.new();atlas.atlas=sheet;atlas.region=Rect2(rect[0],rect[1],rect[2],rect[3]);atlas.filter_clip=true;return atlas
func enter220(next: String) -> void:
 phase220=next;clock220=0.;attack_connected=false
 attack_phase="lunge" if next=="roll" else ("windup" if next=="windup" else "recover" if next=="recover" else "approach")
 if next=="windup":
  roll_origin220=Vector2(position.x,position.z);locked220=Vector2(battle.hero.position.x,battle.hero.position.z)
  roll_dir220=(locked220-roll_origin220).normalized();build_lane220()
 if next=="roll":roll_count220+=1
 if next=="chase":next_roll220=2.8
func build_lane220() -> void:
 var st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var side=Vector2(-roll_dir220.y,roll_dir220.x)*.95
 for i in 12:
  var a=roll_origin220+roll_dir220*float(i)*.38;var b=a+roll_dir220*.38
  if absf(battle.floor_height(a)-battle.floor_height(b))>.25:break
  for point in [a-side,a+side,b+side,a-side,b+side,b-side]:st.add_vertex(Vector3(point.x,battle.floor_height(point)+.04,point.y))
 lane220.mesh=st.commit()
func receive_hit(damage: float,direction: Vector3) -> void:
 if dead or not battle.active114:return
 var before=hp
 hp=maxf(0.,hp-damage);hit_count+=1;flash=.08;health_time=1.
 if battle.has_method("record_enemy_damage226"):battle.record_enemy_damage226(self,before-hp)
 # Keep weapon contact feedback while avoiding the old jelly creature response.
 var contact=impact_contact if impact_contact.is_finite() else visual.global_position+Vector3.UP*.65
 battle.on_legacy_contact(self,contact,direction,false);impact_contact=Vector3.INF
 if hp<=0.:
  dead=true;hit_area.collision_layer=0;enter220("down");velocity=Vector3.ZERO
  _render_legacy(0.);battle.cat_down220(self)
func deflect(contact: Vector3) -> void:
 parried_count+=1;enter220("recover");velocity=Vector3.ZERO
 battle.parry_success(contact,Vector3(-roll_dir220.x,0.,-roll_dir220.y))
func repair220() -> void:
 dead=false;hp=max_hp110;hit_area.collision_layer=8;active_ai=true;enter220("chase");battle.rebuild_cells110()
func _physics_process(delta: float) -> void:
 if not ready220 or battle.combat_paused or not battle.active114:return
 clock_anim220+=delta;clock220+=delta;flash=maxf(0.,flash-delta)
 if phase220=="down":_render_legacy(0.);return
 var at=Vector2(position.x,position.z);var player=Vector2(battle.hero.position.x,battle.hero.position.z)
 var motion=Vector2.ZERO
 if phase220=="chase":
  next_roll220-=delta;path_clock-=delta
  if path_clock<=0.:route=battle.navigation.path(at,player);path_clock=.4
  while route.size()>1 and at.distance_to(route[0])<.6:route.remove_at(0)
  var toward=(route[0]-at).normalized() if not route.is_empty() else (player-at).normalized()
  for angle in [0.,.65,-.65,1.25,-1.25,1.7,-1.7]:
   var dir=toward.rotated(angle)
   if not test_move(global_transform,Vector3(dir.x,0.,dir.y)*.65) and absf(battle.floor_height(at+dir*.5)-position.y)<.25:
    motion=dir*.78;break
  if next_roll220<=0. and at.distance_to(player)<7.:enter220("windup");motion=Vector2.ZERO
 elif phase220=="windup":
  if clock220>=.8:enter220("roll")
 elif phase220=="roll":
  motion=roll_dir220*4.6
  if clock220>=.96:enter220("recover");motion=Vector2.ZERO
 elif phase220=="recover":
  if clock220>=1.35:enter220("chase")
 var was_roll=phase220=="roll"
 var before=position
 var next=at+motion*delta
 var h: float=battle.floor_height(next)
 if absf(h-position.y)>.25:
  if phase220=="roll":enter220("recover")
  motion=Vector2.ZERO;h=position.y
 velocity=Vector3(motion.x,0.,motion.y)
 var hit=move_and_collide(Vector3(motion.x*delta,h-position.y,motion.y*delta))
 var struck_hero=hit!=null and hit.get_collider()==battle.hero
 if hit!=null and phase220=="roll" and not struck_hero:enter220("recover")
 # Contact is swept so a fast roll cannot skip a player between physics ticks.
 var closest=Geometry2D.get_closest_point_to_segment(player,Vector2(before.x,before.z),Vector2(position.x,position.z))
 if closest.distance_to(player)<1.30 and absf(position.y-battle.hero.position.y)<.75:
  if was_roll and battle.hero.can_parry():deflect(battle.hero.position+Vector3.UP*.6)
  elif battle.invulnerability<=0. and battle.hero.dodge_invulnerability<=0.:
   var before_hp: float=battle.player_hp
   battle.hurt_player(22. if was_roll else 12.,Vector2(position.x,position.z))
   if battle.player_hp<before_hp:
    contact_count220+=1
    if was_roll:rolled_hits220+=1
 if struck_hero and phase220=="roll":enter220("recover")
 _render_legacy(0.)
func roll_frame220() -> int:
 return int(clock220/.16)%6
func attachment_frame154() -> Dictionary:
 return preload("res://scripts/combat/plush_surface221.gd").frame(visual)
func _render_legacy(lift: float) -> void:
 if not ready220:
  super._render_legacy(lift);return
 var is_roll=phase220 in ["roll","down"]
 var frame=3 if phase220=="down" else roll_frame220() if phase220=="roll" else int(clock_anim220*14.)%6
 var f: Dictionary=roll_data220.frames[frame] if is_roll else walk_data220.frames[frame]
 visual.texture=rolls220[frame] if is_roll else walk220[frame]
 var foot=Vector2(f.anchor[0],f.anchor[1]) if is_roll else Vector2(float(f.anchor[0])-25.,float(f.anchor[1])+295.)
 var size=visual.texture.get_size();visual.pixel_size=3./(502. if is_roll else 558.)
 visual.offset=Vector2(size.x*.5-foot.x,foot.y-size.y*.5)
 # Preparation has zero velocity; face the intended roll and retain it while resting.
 var facing_motion=Vector3(roll_dir220.x,0.,roll_dir220.y) if phase220 in ["windup","roll"] else velocity if phase220=="chase" else Vector3.ZERO
 var screen_motion=facing_motion.dot(battle.camera.global_basis.x)
 if absf(screen_motion)>.1:facing_right220=screen_motion>0.
 visual.flip_h=facing_right220
 if visual.flip_h:visual.offset.x=-visual.offset.x
 ink220.set_shader_parameter("paint",roll_sheet220 if is_roll else walk_sheet220)
 ink220.set_shader_parameter("alpha_cut220",.98 if is_roll else .6)
 visual.scale=Vector3(1.,.90,1.) if phase220=="windup" else Vector3.ONE
 visual.modulate=Color(1.1,.9,.94) if flash>0. else Color.WHITE
 lane220.visible=phase220=="windup"
func _process(_delta: float) -> void:
 if not ready220:return
 visual.global_basis=battle.camera.global_basis;visual.global_position=position+Vector3.UP*.03
 ink220.set_shader_parameter("foot199",position);ink220.set_shader_parameter("camera199",battle.camera.global_position)
 var normal=battle.camera.global_basis.z;normal.y=0.;ink220.set_shader_parameter("plane_normal199",normal.normalized())
 ink220.set_shader_parameter("receiver_normal207",(battle.hero.visual.global_basis*Vector3(0.,sin(deg_to_rad(25.)),cos(deg_to_rad(25.)))).normalized())
