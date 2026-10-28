extends "res://scripts/world/storybook_time89.gd"
func update_guide() -> void:
	super.update_guide()
	if is_instance_valid(guide): guide.text+="\n90：Ctrl+6 入口 · Ctrl+7 西岩肩 · Ctrl+8 后林台"
