extends "res://scripts/world/room_world404.gd"
signal exit406
func _ready() -> void:
 await super._ready()
 auto_door404=false;yard403.set_open404(true);inside403=true;camera403(false);apply400();reset355()
 help367="406 · 原尺寸室内\nWASD走动 · E查看/睡起 · F3出门\nF2昼夜 · F12跟随 · 家具布局保持"
 refresh367()
func leave371() -> void:exit406.emit()
func switch_zone403(value: bool,animate: bool=true) -> void:
 if not value:exit406.emit();return
 super.switch_zone403(value,animate)
