extends Node2D
class_name ProgrammerScene

signal typing_started
signal typing_finished

@onready var programmer: Node2D = $Programmer
@onready var hands: ColorRect = $Programmer/Hands

var is_typing := false
var idle_tween: Tween
var typing_tween: Tween

func _ready() -> void:
	_start_idle_animation()
	_connect_to_action_buttons()

func _connect_to_action_buttons() -> void:
	# Wait for scene tree to be ready
	await get_tree().process_frame
	for button in get_tree().get_nodes_in_group("action_buttons"):
		if button.has_signal("performed"):
			button.performed.connect(_on_action_performed)

func _on_action_performed(_action_id: String) -> void:
	play_typing(0.4)

func play_typing(duration: float) -> void:
	if is_typing:
		return

	is_typing = true
	typing_started.emit()

	# Stop idle animation
	if idle_tween and idle_tween.is_valid():
		idle_tween.kill()

	# Reset programmer position
	programmer.position.y = programmer.position.y

	# Create typing animation - hands move up/down rapidly
	typing_tween = create_tween()
	var base_y := hands.position.y
	var cycles := 5
	var cycle_duration := duration / cycles

	for i in range(cycles):
		typing_tween.tween_property(hands, "position:y", base_y - 2, cycle_duration * 0.5)
		typing_tween.tween_property(hands, "position:y", base_y, cycle_duration * 0.5)

	typing_tween.tween_callback(_on_typing_finished)

func _on_typing_finished() -> void:
	is_typing = false
	typing_finished.emit()
	_start_idle_animation()

func _start_idle_animation() -> void:
	if idle_tween and idle_tween.is_valid():
		idle_tween.kill()

	# Subtle breathing/bobbing animation
	idle_tween = create_tween()
	idle_tween.set_loops()

	var base_y := programmer.position.y
	idle_tween.tween_property(programmer, "position:y", base_y - 1, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	idle_tween.tween_property(programmer, "position:y", base_y, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
