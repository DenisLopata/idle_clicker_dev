class_name AutoClicker
extends Node

@export var target_button: NodePath
@export var clicks_per_tick: int = 1
@export var tick_interval: float = 1.0
@export var enabled: bool = false

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.wait_time = tick_interval
	timer.timeout.connect(_on_tick)

	if enabled:
		timer.start()

func enable_auto_click() -> void:
	enabled = true
	timer.start()

func disable_auto_click() -> void:
	enabled = false
	timer.stop()

func _on_tick() -> void:
	if not enabled:
		return

	var btn: ActionButton = get_node_or_null(target_button)
	if btn and btn.unlocked_action:
		# simulate N clicks
		for i in range(clicks_per_tick):
			btn._on_pressed()
