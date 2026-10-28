extends "res://scripts/world/woodland_world173.gd"
const FOREST180=preload("res://scripts/world/forest_plan180.gd")
var forest180: Node3D
var forest_ready180 := false
var removed_trees180 := 0
var connection180 := PackedVector2Array()
class YardRoute180:
 extends "res://scripts/combat/woodland_navigation21.gd"
 func grid_half_extent21() -> Vector2i: return Vector2i(28,20)
func _init() -> void:
 super._init();memory_save116="user://forest180_preview.cfg"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 180 · 大地图 / 下沉森林与弧形岩岸")
func _build_lab_floor() -> void:
 super._build_lab_floor();meadow=preload("res://scripts/world/world_surface180.gd").new()
func _rock_surfaces_script91() -> Script: return preload("res://scripts/art/rock_surfaces180.gd")
func _hero_script() -> Script: return preload("res://scripts/combat/hero180.gd")
func _build_woodland() -> void:
 super._build_woodland()
 var keep: Array[Dictionary]=[]
 for tree in trees:
  if FOREST180.tree_clear180(Vector2(tree.root.position.x,tree.root.position.z)):
   tree.root.free();removed_trees180+=1
  else: keep.append(tree)
 trees.assign(keep)
func _grass_growth92(at: Vector2) -> float:
 if FOREST180.affects180(at):
  return .0 if FOREST180.path_sample(at-FOREST180.CENTER).x<1.9 else .24
 return super._grass_growth92(at)
func _ready() -> void:
 super._ready()
 while not is_instance_valid(arc_shadows167): await get_tree().physics_frame
 # Later inherited scenery passes also plant trees. Keep references valid for
 # their lighting services, while clearing only the new bowl and yard approach.
 for tree in trees:
  if FOREST180.tree_clear180(Vector2(tree.root.position.x,tree.root.position.z)):
   tree.root.hide()
   for child in tree.root.find_children("*","CollisionObject3D",true,false): child.collision_layer=0
 # Existing decorative rocks in the new bowl must not float at the old grade.
 for rock in forest87.rocks87:
  if FOREST180.tree_clear180(rock.at):
   rock.visual.hide();rock.body.collision_layer=0;rock.shadow.hide()
 for plant in forest87.plants87:
  if FOREST180.tree_clear180(Vector2(plant.position.x,plant.position.z)): plant.hide()
 forest180=preload("res://scripts/art/forest_art180.gd").new();forest180.world=self;add_child(forest180)
 await get_tree().physics_frame;await get_tree().physics_frame
 var route := YardRoute180.new();route.bake(get_world_3d().direct_space_state,meadow,Vector2(-13.,0.))
 connection180=route.path(Vector2(-4.7,-2.6),FOREST180.CENTER+FOREST180.ENTRY)
 # A short stepping-stone trail follows the existing workshop's real collision
 # gaps, instead of moving its biscuit tin, pot, benches or low stone edging.
 var last := Vector2.INF
 for point in connection180:
  if point.distance_to(last)<1.15 or point.x> -6.: continue
  last=point;var local := point-FOREST180.CENTER
  forest180.box(Vector3(.24,.025,.16),Vector3(local.x,floor_height(point)+.025,local.y),forest180.ink("a59978"))
 forest_ready180=true;_teleport15(Vector2(-4.7,-2.6));_title35()
 var canvas := CanvasLayer.new();canvas.layer=12;add_child(canvas)
 var text := Label.new();text.text="180 大地图预览 · 沿小石子向西进入森林\nF6 森林入口 / F7 小屋前 / F3 小院\n正式三鹅门禁与森林战斗尚未接入";text.position=Vector2(24,200);text.add_theme_font_size_override("font_size",17);text.add_theme_color_override("font_shadow_color",Color.BLACK);text.add_theme_constant_override("shadow_outline_size",5);text.mouse_filter=Control.MOUSE_FILTER_IGNORE;canvas.add_child(text)
func _input(event: InputEvent) -> void:
 if forest_ready180 and not active114 and event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed:
  if event.physical_keycode in [KEY_F6,KEY_F7]:
   _teleport15(FOREST180.CENTER+(FOREST180.ENTRY if event.physical_keycode==KEY_F6 else Vector2(-7.,-4.8)));get_viewport().set_input_as_handled();return
 super._input(event)
