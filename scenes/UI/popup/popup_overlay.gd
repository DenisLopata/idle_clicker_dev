extends CanvasLayer
class_name PopupOverlay

signal closed

@onready var background: ColorRect = $Background
@onready var content_container: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentContainer
@onready var panel_container: PanelContainer = $CenterContainer/PanelContainer
@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HeaderRow/TitleLabel
@onready var close_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HeaderRow/CloseButton

func _ready() -> void:
	background.gui_input.connect(_on_background_input)
	close_button.pressed.connect(close)
	hide()

func open(content: Control, title: String = "") -> void:
	# Clear any existing content
	for child in content_container.get_children():
		child.queue_free()

	# Add new content
	content_container.add_child(content)
	title_label.text = title

	# Show and animate
	show()
	panel_container.scale = Vector2(0.8, 0.8)
	panel_container.modulate.a = 0.0

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel_container, "modulate:a", 1.0, 0.15).set_ease(Tween.EASE_OUT)

func close() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel_container, "scale", Vector2(0.8, 0.8), 0.1).set_ease(Tween.EASE_IN)
	tween.tween_property(panel_container, "modulate:a", 0.0, 0.1).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(_finish_close)

func _finish_close() -> void:
	for child in content_container.get_children():
		child.queue_free()
	hide()
	closed.emit()

func _on_background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close()

func is_open() -> bool:
	return visible
