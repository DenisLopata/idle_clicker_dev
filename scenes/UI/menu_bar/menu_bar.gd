extends HBoxContainer
class_name GameMenuBar

signal stats_pressed
signal options_pressed

@onready var stats_button: Button = $StatsButton
@onready var options_button: Button = $OptionsButton

func _ready() -> void:
	stats_button.pressed.connect(_on_stats_pressed)
	options_button.pressed.connect(_on_options_pressed)

func _on_stats_pressed() -> void:
	stats_pressed.emit()

func _on_options_pressed() -> void:
	options_pressed.emit()
