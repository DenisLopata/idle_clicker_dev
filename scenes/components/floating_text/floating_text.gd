extends Label
class_name FloatingText

var velocity := Vector2(0, -60)
var lifetime := 0.8
var _elapsed := 0.0

func setup(text_value: String, color: Color, start_pos: Vector2) -> void:
	text = text_value
	modulate = color
	global_position = start_pos

	# Add random horizontal drift
	velocity.x = randf_range(-20, 20)

	# Start with pop-in animation
	scale = Vector2(0.5, 0.5)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)

func _process(delta: float) -> void:
	_elapsed += delta
	position += velocity * delta

	# Slow down over time
	velocity.y *= 0.98

	# Fade out
	var alpha := 1.0 - (_elapsed / lifetime)
	modulate.a = alpha

	if _elapsed >= lifetime:
		queue_free()
