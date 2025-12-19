class_name AnimationHelper
extends RefCounted

static func play_reveal(node: Control) -> void:
	node.modulate.a = 0.0
	node.scale = Vector2(0.5, 0.5)
	node.show()

	var tween := node.create_tween()
	tween.set_parallel(true)
	tween.tween_property(node, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

static func play_press(node: Control) -> void:
	var tween := node.create_tween()
	tween.tween_property(node, "scale", Vector2(0.9, 0.9), 0.05)
	tween.tween_property(node, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_OUT)

static func play_pulse(node: Control) -> void:
	var tween := node.create_tween()
	tween.tween_property(node, "scale", Vector2(1.05, 1.05), 0.1)
	tween.tween_property(node, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_OUT)

static func play_reject(node: Control) -> void:
	var tween := node.create_tween()
	var original_x := node.position.x
	tween.tween_property(node, "position:x", original_x - 5, 0.05)
	tween.tween_property(node, "position:x", original_x + 5, 0.05)
	tween.tween_property(node, "position:x", original_x, 0.05)
