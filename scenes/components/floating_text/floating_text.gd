extends Label
class_name FloatingText

var velocity := Vector2(0, -50)
var lifetime := 1.0
var _elapsed := 0.0

func setup(text_value: String, color: Color, start_pos: Vector2) -> void:
	text = text_value
	modulate = color
	global_position = start_pos

func _process(delta: float) -> void:
	_elapsed += delta
	position += velocity * delta

	# Fade out
	var alpha := 1.0 - (_elapsed / lifetime)
	modulate.a = alpha

	if _elapsed >= lifetime:
		queue_free()
