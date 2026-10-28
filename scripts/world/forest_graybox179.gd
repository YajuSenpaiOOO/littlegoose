extends Node3D
const PLAN=preload("res://scripts/world/forest_plan179.gd")
var hero: CharacterBody3D
var camera: Camera3D
var terrain: Node3D
var ready179 := false
var overview := false
var shade := true
var combat_paused := false
var player_hp := 100.
var invulnerability := 0.
var enemies: Array=[]
var environment: Environment
var sun: DirectionalLight3D
var status: Label
var geese: Array[Sprite3D]=[]
var trail: Array[Vector3]=[]
var camera_distance := 22.
func hero_script() -> Script: return preload("res://scripts/combat/hero179.gd")
func _ready() -> void:
 DisplayServer.window_set_title("小白鹅 · 179 · 很吓人的森林！下沉森林 / 分段石阶")
 var env := WorldEnvironment.new();environment=Environment.new();env.environment=environment;add_child(env)
 environment.background_mode=Environment.BG_COLOR;environment.background_color=Color("202939");environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;environment.ambient_light_color=Color("a6b2d5");environment.ambient_light_energy=.35;environment.tonemap_mode=Environment.TONE_MAPPER_LINEAR
 sun=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-52.,-28.,0.);sun.light_color=Color("b2c0e8");sun.light_energy=.35;sun.shadow_enabled=true;sun.directional_shadow_max_distance=90.;add_child(sun)
 camera=Camera3D.new();camera.fov=42.;camera.far=180.;camera.current=true;add_child(camera)
 terrain=preload("res://scripts/art/forest_graybox179.gd").new();terrain.world=self;add_child(terrain)
 hero=hero_script().new();hero.position=Vector3(PLAN.CENTER.x+PLAN.ENTRY.x,PLAN.TOP+.08,PLAN.CENTER.y+PLAN.ENTRY.y);add_child(hero)
 hero.visual.shaded=false;hero.combat_enabled=true
 for i in 3:
  var goose := Sprite3D.new();goose.texture=preload("res://assets/black_goose_v2/flap_mid_v1.png");goose.pixel_size=.8/goose.texture.get_height();goose.billboard=BaseMaterial3D.BILLBOARD_FIXED_Y;goose.shaded=false;goose.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;goose.position=hero.position+Vector3((i+1)*.7,.5,0);add_child(goose);geese.append(goose)
 reset_trail();hud();update_camera(0.,true);await get_tree().physics_frame;await get_tree().physics_frame;ready179=true
func hud() -> void:
 var canvas := CanvasLayer.new();add_child(canvas)
 var panel := PanelContainer.new();panel.position=Vector2(20,18);panel.mouse_filter=Control.MOUSE_FILTER_IGNORE;canvas.add_child(panel)
 var style := StyleBoxFlat.new();style.bg_color=Color(.10,.12,.17,.88);style.content_margin_left=16;style.content_margin_right=16;style.content_margin_top=10;style.content_margin_bottom=10;style.corner_radius_top_left=8;style.corner_radius_bottom_right=8;panel.add_theme_stylebox_override("panel",style)
 var column := VBoxContainer.new();panel.add_child(column)
 var title := Label.new();title.text="179 · 很吓人的森林！ / 下沉森林 / 分段石阶";title.add_theme_font_size_override("font_size",24);title.modulate=Color("e1cbea");column.add_child(title)
 status=Label.new();status.add_theme_font_size_override("font_size",17);column.add_child(status)
 var note := Label.new();note.text="WASD / 方向键移动 · Shift闪避 · R回入口\nF1全景 · F2明暗 · F3小屋前 · 滚轮缩放\n独立场景 · 三段短石阶下降 · 无敌人 / 无存档";note.add_theme_font_size_override("font_size",16);column.add_child(note)
func reset_trail() -> void:
 trail.clear()
 for i in range(35,-1,-1): trail.append(hero.position+Vector3(i*.12,0,0))
func teleport(at: Vector2) -> void:
 var p := at-PLAN.CENTER;hero.position=Vector3(at.x,PLAN.height(p)+.08,at.y);hero.velocity=Vector3.ZERO;hero.locomotion=Vector2.ZERO;hero.combat_impulse=Vector2.ZERO;hero.reset_actions();hero.reset_physics_interpolation();reset_trail();update_camera(0.,true)
func update_camera(delta: float,snap := false) -> void:
 if overview:
  camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=64.;camera.position=Vector3(-39.,52.,30.);camera.look_at(Vector3(-39.,0.,-2.));return
 camera.projection=Camera3D.PROJECTION_PERSPECTIVE;camera.rotation_degrees=Vector3(-25.,0.,0.)
 var p: Vector3=hero.get_global_transform_interpolated().origin
 var target := p+Vector3(0.,.85,0.)+Vector3(0.,sin(deg_to_rad(25.)),cos(deg_to_rad(25.)))*camera_distance
 camera.position=target if snap else camera.position.lerp(target,1.-exp(-delta*9.))
func _process(delta: float) -> void:
 if not is_instance_valid(hero): return
 update_camera(delta)
 var p := Vector2(hero.position.x,hero.position.z)-PLAN.CENTER
 status.text=("北侧原地势" if p.y< -12. else ("入口小径 · 两次转弯" if p.x>14. else "森林低地 · 中央树根分两路"))+"   高度 %.1fm"%hero.position.y
 if trail.is_empty() or trail[-1].distance_to(hero.position)>.10: trail.append(hero.position)
 while trail.size()>256: trail.pop_front()
 for i in geese.size():
  var remain := .85+float(i)*.78;var wanted: Vector3=trail[0]
  for j in range(trail.size()-1,0,-1):
   var length := trail[j].distance_to(trail[j-1])
   if length>=remain: wanted=trail[j].lerp(trail[j-1],remain/maxf(.001,length));break
   remain-=length
  geese[i].position=geese[i].position.lerp(wanted+Vector3.UP*.52,1.-exp(-delta*14.));geese[i].flip_h=hero.facing=="left"
 if hero.position.y< -8.: teleport(PLAN.CENTER+PLAN.ENTRY)
func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo:
  match event.physical_keycode:
   KEY_R: teleport(PLAN.CENTER+PLAN.ENTRY)
   KEY_F3: teleport(PLAN.CENTER+Vector2(-7.,-4.8))
   KEY_F1: overview=not overview;update_camera(0.,true)
   KEY_F2:
    shade=not shade;sun.light_energy=.35 if shade else .9;environment.ambient_light_energy=.35 if shade else .72
 if event is InputEventMouseButton and event.pressed:
  if event.button_index==MOUSE_BUTTON_WHEEL_UP: camera_distance=maxf(15.,camera_distance/1.1)
  if event.button_index==MOUSE_BUTTON_WHEEL_DOWN: camera_distance=minf(32.,camera_distance*1.1)


