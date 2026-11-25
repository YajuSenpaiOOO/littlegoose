extends "res://scripts/world/woodland_world201.gd"
var ready405:=false
var model405: Node3D
var kit405: Node3D
var mode405:=2
var overview405:=true
var panel405: Label
var old_layer405:=2
var old_mask405: Texture2D
var new_mask405: Texture2D
var root_y405:=0.
var ramp_drop405:=.1
var ramp405: MeshInstance3D
var ramp_body405: StaticBody3D
var plinth405: MeshInstance3D
var plinth_body405: StaticBody3D
var reports405: Dictionary={}
var path_report405: Array=[]
func _init() -> void:
 super._init();memory_save116="user://home_fit405_preview.cfg"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 405 · 大地图小屋占地对照")
func _ready() -> void:
 Engine.max_fps=60
 await super._ready()
 old_layer405=cottage_body.collision_layer
 model405=preload("res://scripts/room/home_yard404.gd").new();model405.name="FullSizeCottage405";add_child(model405)
 kit405=preload("res://scripts/room/geometry_kit405.gd").new();model405.add_child(kit405);model405.build_house404(kit405)
 model405.door404.collision_layer=2|(1<<25)
 # This preview relocates the whole building. A closed static leaf must follow
 # the new parent transform instead of replaying its prior physics-world pose.
 model405.door404.sync_to_physics=false
 for side in [-1.,1.]:
  wall405(Vector3(side*3.8,1.78,2.88),Vector3(5.45,3.56,.20))
  wall405(Vector3(side*6.51,1.8,-.93),Vector3(.16,3.6,7.76))
 wall405(Vector3(0,1.8,-4.76),Vector3(13.1,3.6,.18))
 plinth405=kit405.box(model405,Vector3(0,-.12,-.95),Vector3(13.4,.24,8.0),"9d9d8a")
 plinth_body405=kit405.collider(model405,Vector3(0,-.12,-.95),Vector3(13.4,.24,8.0))
 ramp405=MeshInstance3D.new();model405.add_child(ramp405)
 ramp_body405=StaticBody3D.new();model405.add_child(ramp_body405);ramp_body405.add_child(CollisionShape3D.new())
 old_mask405=shade_texture
 var image:=shade_texture.get_image()
 for y in image.get_height():
  for x in image.get_width():
   var color:=image.get_pixel(x,y);color.b=0.;image.set_pixel(x,y,color)
 new_mask405=ImageTexture.create_from_image(image)
 var canvas:=CanvasLayer.new();canvas.layer=90;add_child(canvas)
 var bg:=PanelContainer.new();bg.position=Vector2(18,18);canvas.add_child(bg)
 var style:=StyleBoxFlat.new();style.bg_color=Color(.10,.12,.10,.90);style.content_margin_left=14;style.content_margin_right=14;style.content_margin_top=12;style.content_margin_bottom=12;bg.add_theme_stylebox_override("panel",style)
 panel405=Label.new();panel405.add_theme_font_size_override("font_size",18);panel405.modulate=Color("f1e4c5");bg.add_child(panel405)
 # Hide inherited trial instruction text, retaining its services and gameplay state.
 for layer in get_children():
  if layer is CanvasLayer and layer!=canvas:
   for label_node in layer.find_children("*","Label",true,false):
    if label_node.text.begins_with("19") or label_node.text.begins_with("20") or label_node==label or label_node==time55.guide:label_node.hide()
 ready405=true;set_mode405(2);home405();_title35()
 print("FIT405_READY ",JSON.stringify({"old_door":cottage_root.position,"new_origin":model405.position,"old_fit":house_fits[house_variant],"tree_count":trees.size(),"nodes":get_tree().get_node_count()}))
func wall405(at: Vector3,size: Vector3) -> void:
 var body: StaticBody3D=kit405.collider(model405,at,size);body.collision_layer=2|(1<<25)
func terrain405(at: Vector2) -> float:return super.floor_height(at)
func door405() -> Vector2:return Vector2(cottage_root.position.x,cottage_root.position.z-(3. if mode405==3 else 0.))
func set_mode405(value: int) -> void:
 mode405=value
 if value!=1:
  var door:=door405();var origin:=Vector2(door.x,door.y-2.88);var high: float=-INF;var low: float=INF
  for iz in 5:
   for ix in 7:
    var h:=terrain405(origin+Vector2(-6.7+float(ix)*13.4/6.,-4.95+float(iz)*2.));high=maxf(high,h);low=minf(low,h)
  root_y405=high+.035;model405.position=Vector3(origin.x,root_y405,origin.y)
  model405.door404.position=Vector3(-1.015,.025,2.88);model405.door404.rotation=Vector3.ZERO;model405.door404.reset_physics_interpolation()
  var depth: float=root_y405-low+.20;plinth405.mesh.size.y=depth;plinth405.position.y=-depth*.5;plinth_body405.get_child(0).shape.size.y=depth;plinth_body405.position.y=-depth*.5
  ramp_drop405=maxf(.04,root_y405-terrain405(door+Vector2(0,2.47)))
  var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
  for p in [Vector3(-1.05,0,3.05),Vector3(-1.05,-ramp_drop405,5.35),Vector3(1.05,0,3.05),Vector3(1.05,0,3.05),Vector3(-1.05,-ramp_drop405,5.35),Vector3(1.05,-ramp_drop405,5.35)]:st.set_normal(Vector3.UP);st.set_uv(Vector2(p.x,p.z));st.add_vertex(p)
  ramp405.mesh=st.commit();ramp405.material_override=kit405.material("b6b39c");ramp405.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  ramp_body405.get_child(0).shape=ramp405.mesh.create_trimesh_shape()
 cottage_root.visible=value==1;house_art.visible=value==1;cottage_body.collision_layer=old_layer405 if value==1 else 0
 model405.visible=value!=1
 for body in model405.find_children("*","CollisionObject3D",true,false):
  if not body.has_meta("layer405"):body.set_meta("layer405",body.collision_layer)
  body.collision_layer=0 if value==1 else body.get_meta("layer405")
 for material in ground_materials+meadow_materials:material.set_shader_parameter("forest_mask",old_mask405 if value==1 else new_mask405)
 # Moving the trial building must not trap a roaming actor inside its new footprint.
 if value!=1 and footprint405().has_point(Vector2(hero.position.x,hero.position.z)):home405()
 for foot in house_contacts:foot.mark.visible=value==1 and contact_enabled
 call_deferred("audit405")
func footprint405() -> Rect2:return Rect2(Vector2(model405.position.x-6.7,model405.position.z-4.95),Vector2(13.4,8.0))
func floor_height(at: Vector2) -> float:
 var ground_height: float=super.floor_height(at)
 if not ready405 or mode405==1:return ground_height
 if footprint405().has_point(at):return maxf(ground_height,root_y405)
 var local:=at-Vector2(model405.position.x,model405.position.z)
 if absf(local.x)<=1.05 and local.y>=3.05 and local.y<=5.35:return maxf(ground_height,root_y405-ramp_drop405*(local.y-3.05)/2.3)
 return ground_height
func audit405() -> void:
 if not ready405:return
 await get_tree().physics_frame
 var rect:=footprint405();var tree_hits: Array=[];var prop_hits: Array=[]
 if mode405==1:
  var old_shape: CollisionShape3D=cottage_body.get_child(0);var old_size: Vector3=old_shape.shape.size
  rect=Rect2(Vector2(old_shape.global_position.x-old_size.x*.5,old_shape.global_position.z-old_size.z*.5),Vector2(old_size.x,old_size.z))
 for tree in trees:
  var at: Vector3=tree.root.global_position
  if tree.root.visible and rect.grow(.35).has_point(Vector2(at.x,at.z)):tree_hits.append(str(at))
 var shape:=BoxShape3D.new();shape.size=Vector3(rect.size.x,1.2,rect.size.y)
 var q:=PhysicsShapeQueryParameters3D.new();q.shape=shape;q.collision_mask=2|16
 var excludes: Array[RID]=[hero.get_rid(),cottage_body.get_rid()]
 for body in model405.find_children("*","CollisionObject3D",true,false):excludes.append(body.get_rid())
 q.exclude=excludes;q.transform=Transform3D(Basis.IDENTITY,Vector3(rect.get_center().x,root_y405+.60,rect.get_center().y))
 for hit in get_world_3d().direct_space_state.intersect_shape(q,64):prop_hits.append(str(hit.collider.get_path()))
 var row:={"mode":mode405,"door":str(door405()),"footprint":str(rect),"floor_y":root_y405,"ramp_drop":ramp_drop405,"tree_roots":tree_hits,"overlapping_bodies":prop_hits}
 reports405[str(mode405)]=row;print("FIT405_SITE ",JSON.stringify(row));refresh405(tree_hits.size(),prop_hits.size())
 FileAccess.open("res://docs/home405-sites.json",FileAccess.WRITE).store_string(JSON.stringify(reports405,"\t"))
func refresh405(tree_count: int=0,body_count: int=0) -> void:
 panel405.text="405 · 大地图小屋占地对照\n1旧2D · 2新屋原门位 · 3新屋后退3米\nF8全院观察 · F9普通跟随 · F7回屋前\nWASD走动 · 8昼夜对照\n当前："+["","旧贴图与原碰撞","实体屋 / 原门位","实体屋 / 后退3米"][mode405]+"\n新屋保持室内原尺寸，周围树和工坊未挪\n占地内树根 %d · 碰撞体 %d\n本轮仅看外屋落位，室内体验保留404"%[tree_count,body_count]
func home405() -> void:
 _teleport15(door405()+Vector2(0,4.3))
func _update_camera(delta: float,snap: bool=false) -> void:
 if ready405 and overview405:
  camera.rotation_degrees=Vector3(-25,0,0);camera.fov=42.
  var at: Vector3=cottage_root.position+Vector3(0,2.0,-1.6)
  camera.position=at+camera.global_basis.z*27.;return
 super._update_camera(delta,snap)
func _update_prop_contacts() -> void:
 super._update_prop_contacts()
 if ready405 and mode405!=1:
  for foot in house_contacts:foot.mark.hide()
func _process(delta: float) -> void:
 super._process(delta)
 if ready405 and overview405:camera.fov=42.
 if ready405:
  for material in model405.glow404:material.emission_energy_multiplier=.45 if time55.visual_hour>18. else .10
func _input(event: InputEvent) -> void:
 if ready405 and event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed:
  if event.physical_keycode in [KEY_1,KEY_2,KEY_3]:set_mode405(event.physical_keycode-KEY_0);get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_F7:home405();get_viewport().set_input_as_handled();return
  if event.physical_keycode in [KEY_F8,KEY_F9]:overview405=event.physical_keycode==KEY_F8;follow_camera=not overview405;_update_camera(0,true);get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_8:time55.preview_at(20. if time55.visual_hour<18. else 10.);get_viewport().set_input_as_handled();return
 super._input(event)
