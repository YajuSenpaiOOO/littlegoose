extends "res://scripts/art/station_kit83.gd"
func shadow81(parent: Node3D,visual: Sprite3D) -> void:
	var shadow := preload("res://scripts/art/station_shadow84.gd").new()
	shadow.world=world;shadow.visual=visual;parent.add_child(shadow);shadow.update_shadow()
func bed83(label: String) -> void:
	super.bed83(label)
	var root: Node3D=beds83[-1]
	var stone: MeshInstance3D=root.get_child(0)
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side in [-1.,1.]:
		for i in 12:
			var h := .22+.025*sin(i*1.7+side)
			world.rail72.bevel79(st,Vector3(side*(.64+.018*sin(i*2.1)),h*.5,-2.475+i*.45),Vector3(.24,h,.44))
	for z in [-2.6,2.6]:
		for i in 4:
			var h := .22+.018*sin(i*2.2)
			world.rail72.bevel79(st,Vector3(-.4875+i*.325,h*.5,z),Vector3(.318,h,.24))
	stone.mesh=st.commit();stone.material_override=world.rail72.material79()
func _ready() -> void:
	super._ready()
	var hall: Sprite3D=visuals81[0]
	# Seat the stone facade at its sill rather than anchoring the whole building
	# to the two long foreground timber feet in the original 2D composition.
	hall.offset.y=795.-hall.texture.get_height()*.5
	print("STATION84_FACADE_SEATED_AND_PAINTED_STONE_READY")
