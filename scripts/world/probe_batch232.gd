extends SceneTree
class Palette:
 extends RefCounted
 func sample(_hour: float) -> Dictionary:return {"daylight":1.}
class TimeStub:
 extends RefCounted
 var palette=Palette.new()
 var visual_hour=12.
class Field:
 extends RefCounted
 var revision=0
 func bind_shader(_ink: ShaderMaterial) -> void:pass
class DummyShadow:
 extends MeshInstance3D
 var battle
 var visual
 var enabled=false
class Manager:
 extends "res://scripts/combat/balloon_sword232.gd"
 func shadow_script154() -> Script:return DummyShadow
class Host:
 extends Node3D
 var camera: Camera3D
 var sun: DirectionalLight3D
 var actor_shadows=[]
 var fx_layer: Node2D
 var time55=TimeStub.new()
 var shadow_field113=Field.new()
 var combat_paused=true
 var silhouettes_enabled=false
 var contact_enabled=false
 var active114=true
 var player_hp=14.
 var shots=[]
 func screen_direction(at: Vector3,direction: Vector3) -> Vector2:return (camera.unproject_position(at+direction)-camera.unproject_position(at)).normalized()
func _initialize() -> void:call_deferred("run")
func run() -> void:
 RenderingServer.global_shader_parameter_set("combat_world_tint159",Color.WHITE)
 var host=Host.new();root.add_child(host);current_scene=host
 host.camera=Camera3D.new();host.add_child(host.camera);host.camera.position=Vector3(0,1.5,5);host.camera.look_at(Vector3(0,.5,0));host.camera.projection=Camera3D.PROJECTION_ORTHOGONAL;host.camera.size=4.;host.camera.current=true
 host.sun=DirectionalLight3D.new();host.add_child(host.sun)
 host.fx_layer=Node2D.new();host.add_child(host.fx_layer)
 var m=Manager.new();m.battle=host;host.add_child(m)
 m.attach153(null,Vector3(-.9,0.,0.),Vector3.DOWN,1.,{})
 var legacy=m.sprite153();m.orient153(legacy,Vector3(.9,0.,0.),Vector3.DOWN,1.)
 var ink=m.ink154(legacy);ink.set_shader_parameter("clip_tip158",.09);ink.set_shader_parameter("bend154",-.16);ink.set_shader_parameter("squash154",.24)
 for i in 5:await process_frame
 print("BATCH232_DEBUG ",m.bodies232.multimesh.get_instance_transform(0)," shape=",m.bodies232.multimesh.get_instance_custom_data(0)," clip=",m.bodies232.multimesh.get_instance_color(0)," entry=",m.resting153[0])
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://docs/batch232-debug.png")
 quit()
