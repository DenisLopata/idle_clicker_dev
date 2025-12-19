extends VBoxContainer
class_name OptionsPopupContent

signal reset_requested

@onready var save_button: Button = $SaveButton
@onready var save_label: Label = $SaveButton/SavedLabel
@onready var reset_button: Button = $ResetButton

func _ready() -> void:
	save_button.pressed.connect(_on_save_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	save_label.hide()

func _on_save_pressed() -> void:
	SaveManager.save_game()
	_show_saved_feedback()

func _on_reset_pressed() -> void:
	reset_requested.emit()

func _show_saved_feedback() -> void:
	save_label.show()
	var tween := create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(save_label.hide)
