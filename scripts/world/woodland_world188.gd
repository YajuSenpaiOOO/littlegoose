extends "res://scripts/world/woodland_world173.gd"
const FOREST188=preload("res://scripts/world/forest_plan188.gd")
var forest188: Node3D
var forest_mood188: Node
var forest_ready188 := false
var removed_trees188 := 0
var connection188 := PackedVector2Array()
class YardRoute188:
 extends "res://scripts/combat/woodland_navigation21.gd"
 func grid_half_extent21() -> Vector2i: return Vector2i(42,38)
func _init() -> void:
 super._init();memory_save116="user://forest188_preview.cfg"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 188 · 大地图 / 南移森林 / 重画像素摆件")
func _build_lab_floor() -> void:
 super._build_lab_floor()
 var old_bounds: Rect2=meadow.world_bounds
 meadow=preload("res://scripts/world/world_surface188.gd").new()
 # world19 authored four invisible perimeter boxes before derived worlds swap
 # their surface. Move the old south wall and lengthen the two side walls;
 # otherwise z=18.38 remains an invisible fence through the new approach.
 for child in get_children():
  if not child is MeshInstance3D or not child.mesh is BoxMesh: continue
  var box_mesh: BoxMesh=child.mesh
  if absf(child.position.z-old_bounds.end.y)<.02 and box_mesh.size.z<.5 and box_mesh.size.x>old_bounds.size.x*.9:
   child.position.z=meadow.world_bounds.end.y
  elif box_mesh.size.x<.5 and box_mesh.size.z>old_bounds.size.y*.9 and (absf(child.position.x-old_bounds.position.x)<.02 or absf(child.position.x-old_bounds.end.x)<.02):
   child.position.z=meadow.world_bounds.get_center().y;box_mesh.size.z=meadow.world_bounds.size.y
   for collider in child.find_children("*","CollisionShape3D",true,false):
    if collider.shape is BoxShape3D: collider.shape.size.z=meadow.world_bounds.size.y
func _rock_surfaces_script91() -> Script: return preload("res://scripts/art/rock_surfaces188.gd")
func _hero_script() -> Script: return preload("res://scripts/combat/hero188.gd")
func _forest_art_script188() -> Script: return preload("res://scripts/art/forest_art188.gd")
func _forest_mood_script188() -> Script: return preload("res://scripts/art/forest_mood188.gd")
func _build_woodland() -> void:
 super._build_woodland()
 var keep: Array[Dictionary]=[]
 for tree in trees:
  var at := Vector2(tree.root.position.x,tree.root.position.z)
  var cliff := FOREST188.region188(at) and meadow.normal_at(at.x,at.y,true).y<.92
  if FOREST188.tree_clear188(at) or cliff:
   tree.root.free();removed_trees188+=1
  else: keep.append(tree)
 trees.assign(keep)
func _grass_growth92(at: Vector2) -> float:
 if FOREST188.region188(at) and meadow.normal_at(at.x,at.y,true).y<.90: return 0.
 if FOREST188.affects188(at) and preload("res://scripts/world/forest_dressing188.gd").distance188(at-FOREST188.CENTER)<1.: return 0.
 if FOREST188.affects188(at):
  return .0 if FOREST188.path_sample(at-FOREST188.CENTER).x<1.9 else .24
 return super._grass_growth92(at)
func _ready() -> void:
 super._ready()
 while not is_instance_valid(arc_shadows167): await get_tree().physics_frame
 # Later inherited scenery passes also plant trees. Keep references valid for
 # their lighting services, while clearing only the new bowl and yard approach.
 for tree in trees:
  var at := Vector2(tree.root.position.x,tree.root.position.z)
  if FOREST188.tree_clear188(at) or (FOREST188.region188(at) and meadow.normal_at(at.x,at.y,true).y<.92):
   tree.root.hide()
   for child in tree.root.find_children("*","CollisionObject3D",true,false): child.collision_layer=0
 # Existing decorative rocks in the new bowl must not float at the old grade.
 for rock in forest87.rocks87:
  if FOREST188.tree_clear188(rock.at) or (FOREST188.region188(rock.at) and meadow.normal_at(rock.at.x,rock.at.y,true).y<.90):
   rock.visual.hide();rock.body.collision_layer=0;rock.shadow.hide()
 for plant in forest87.plants87:
  var at := Vector2(plant.position.x,plant.position.z)
  if FOREST188.tree_clear188(at) or (FOREST188.region188(at) and meadow.normal_at(at.x,at.y,true).y<.92): plant.hide()
 forest188=_forest_art_script188().new();forest188.world=self;add_child(forest188)
 await get_tree().physics_frame;await get_tree().physics_frame
 var route := YardRoute188.new();route.bake(get_world_3d().direct_space_state,meadow,Vector2(-13.,0.))
 connection188=route.path(Vector2(-4.7,-2.6),FOREST188.CENTER+FOREST188.ENTRY)
 # A short stepping-stone trail follows the existing workshop's real collision
 # gaps, instead of moving its biscuit tin, pot, benches or low stone edging.
 var last := Vector2.INF
 for point in connection188:
  if point.distance_to(last)<1.15 or point.x> -6.: continue
  last=point;var local := point-FOREST188.CENTER
  forest188.box(Vector3(.24,.025,.16),Vector3(local.x,floor_height(point)+.025,local.y),forest188.ink("a59978"))
 # Cached grass poses predate the new worn trail. Trim only this local strip,
 # including the stair mouths, so blades do not poke through the tread art.
 for batch in grass_batches:
  for i in batch.points.size():
   var at: Vector3=batch.points[i].origin;var p := Vector2(at.x,at.z)
   if not FOREST188.region188(p): continue
   if meadow.normal_at(p.x,p.y,true).y<.90:
    var cliff_pose: Transform3D=batch.node.multimesh.get_instance_transform(i);cliff_pose.basis=Basis(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO);batch.node.multimesh.set_instance_transform(i,cliff_pose);continue
   if preload("res://scripts/world/forest_dressing188.gd").distance188(p-FOREST188.CENTER)>1.0: continue
   var pose: Transform3D=batch.node.multimesh.get_instance_transform(i);pose.basis=Basis(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO);batch.node.multimesh.set_instance_transform(i,pose)
 forest_mood188=_forest_mood_script188().new();forest_mood188.world=self;forest_mood188.art=forest188;add_child(forest_mood188)
 forest_ready188=true;_teleport15(FOREST188.CENTER+Vector2(10.,6.8));_title35()
 var canvas := CanvasLayer.new();canvas.layer=12;add_child(canvas)
 var text := Label.new();text.text="188 南移森林 / 重画像素摆件 / 断面净空\nF8 样板 / F6 入口 / F7 小屋 / F3 小院\nF9 阴影对照 / F10 森林光色";text.position=Vector2(24,200);text.add_theme_font_size_override("font_size",17);text.add_theme_color_override("font_shadow_color",Color.BLACK);text.add_theme_constant_override("shadow_outline_size",5);text.mouse_filter=Control.MOUSE_FILTER_IGNORE;canvas.add_child(text)
func _input(event: InputEvent) -> void:
 if forest_ready188 and event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed and event.physical_keycode==KEY_F10:
  forest_mood188.enabled=not forest_mood188.enabled;get_viewport().set_input_as_handled();return
 if forest_ready188 and event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed and event.physical_keycode==KEY_F9:
  forest188.set_grounding184(not forest188.grounding_on184);get_viewport().set_input_as_handled();return
 if forest_ready188 and not active114 and event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed:
  if event.physical_keycode==KEY_F8:
   _teleport15(FOREST188.CENTER+Vector2(10.,6.8));get_viewport().set_input_as_handled();return
  if event.physical_keycode in [KEY_F6,KEY_F7]:
   _teleport15(FOREST188.CENTER+(FOREST188.ENTRY if event.physical_keycode==KEY_F6 else Vector2(-10.4,-8.1)));get_viewport().set_input_as_handled();return
 super._input(event)




