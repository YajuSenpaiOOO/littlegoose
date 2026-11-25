extends "res://scripts/world/room_world411.gd"
func camera_target403(value: bool) -> Transform3D:
 if value:return super.camera_target403(value)
 # Restore the close household shot from 410. Framing the whole roof is not
 # a requirement; keep the established pitch rather than raising the camera.
 var basis:=Basis.from_euler(Vector3(deg_to_rad(-25.),deg_to_rad(-18. if side_view404 else 0.),0))
 return Transform3D(basis,Vector3(0,1.1,2.0)+basis.z*16.5)
func _ready() -> void:
 await super._ready()
 help367="412 · 恢复近景小院镜头\nWASD实际穿门 · 靠近自动开门\nF3快捷进出 · F2昼夜 · F12跟随\n屋顶允许出画 · 外观A/B/C设计中\n家具与院子摆件暂不调整"
 DisplayServer.window_set_title("小白鹅 · 412 · 近景小院与外屋设计")
 refresh367()
