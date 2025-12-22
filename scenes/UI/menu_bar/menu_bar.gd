extends HBoxContainer
class_name GameMenuBar

signal stats_pressed
signal upgrades_pressed
signal options_pressed

@onready var stats_button: Button = $StatsButton
@onready var upgrades_button: Button = $UpgradesButton
@onready var options_button: Button = $OptionsButton

func _ready() -> void:
	stats_button.pressed.connect(_on_stats_pressed)
	upgrades_button.pressed.connect(_on_upgrades_pressed)
	options_button.pressed.connect(_on_options_pressed)

func _on_stats_pressed() -> void:
	stats_pressed.emit()

func _on_upgrades_pressed() -> void:
	upgrades_pressed.emit()

func _on_options_pressed() -> void:
	options_pressed.emit()
