extends RefCounted
## Portable visual contract; no dependency on legacy combat classes.
static func is_character(actor: Node2D) -> bool:
	return actor.get_meta("sample_character",false)

static func lift(actor: Node2D,visual: Sprite2D) -> float:
	return maxf(0,-visual.position.y) if is_character(actor) else 0.0

static func opacity(actor: Node2D,visual: Sprite2D) -> float:
	return actor.modulate.a*actor.self_modulate.a*visual.modulate.a*visual.self_modulate.a
