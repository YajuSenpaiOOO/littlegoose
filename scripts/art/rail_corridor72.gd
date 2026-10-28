extends Node3D
## Placeholder rail / tunnel massing uses the reserved northern corridor.
var world: Node3D
var sleeper_count72 := 45
var rail_mesh72: MeshInstance3D
var portal72: Node3D

func box72(st: SurfaceTool,at: Vector3,size: Vector3) -> void:
	var box := BoxMesh.new(); box.size=size
	st.append_from(box,0,Transform3D(Basis.IDENTITY,at))

func solid72(st: SurfaceTool,color: Color,label: String) -> MeshInstance3D:
	var node := MeshInstance3D.new(); node.name=label; node.mesh=st.commit()
	var material := StandardMaterial3D.new(); material.albedo_color=color; material.roughness=1.
	node.material_override=material; add_child(node); return node

func _ready() -> void:
	name="ReservedRailAndStationMassing72"
	var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var z: float=world.meadow.RAIL_Z72
	var y: float=world.meadow.RAIL72
	for side in [-.85,.85]: box72(st,Vector3(5.,y+.18,z+side),Vector3(54.,.14,.09))
	for i in sleeper_count72: box72(st,Vector3(-21.5+i*1.2,y+.055,z),Vector3(.18,.10,3.0))
	rail_mesh72=solid72(st,Color(.25,.27,.26),"TrackGaugeAndSleeperPlaceholder72")
	# A tunnel exit gives the west upper forest a coherent passage for the rail.
	# The opening faces east and sits well west of the platform, not behind it.
	var frame := SurfaceTool.new(); frame.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side in [-2.45,2.45]: box72(frame,Vector3(-22.3,y+1.65,z+side),Vector3(1.5,3.3,.65))
	box72(frame,Vector3(-22.3,y+3.45,z),Vector3(1.8,.40,5.55))
	portal72=solid72(frame,Color(.42,.43,.40),"TunnelExitMassing72")
	var dark := SurfaceTool.new(); dark.begin(Mesh.PRIMITIVE_TRIANGLES)
	box72(dark,Vector3(-22.65,y+1.5,z),Vector3(.06,3.,4.25))
	solid72(dark,Color(.08,.10,.09),"TunnelDepthPlaceholder72")
