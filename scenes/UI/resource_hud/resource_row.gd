extends HBoxContainer
class_name ResourceRow

var resource_type: ResourceTypes.ResourceType
var discovered: bool = false

@onready var name_label: Label = $Name
@onready var amount_label: Label = $Amount
@onready var rate_label: Label = $Rate
@onready var efficiency_label: Label = $Efficiency

func setup(type: ResourceTypes.ResourceType, start_hidden: bool = true) -> void:
	resource_type = type
	var color := ResourceTypes.get_color(type)
	name_label.modulate = color
	amount_label.modulate = color

	if start_hidden:
		hide()

func reveal() -> void:
	if not discovered:
		discovered = true

		# Animate reveal: slide in from left and fade in
		modulate.a = 0.0
		position.x -= 30
		show()

		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position:x", position.x + 30, 0.2).set_ease(Tween.EASE_OUT)

func set_amount(value: float) -> void:
	amount_label.text = NumberFormat.format(value)

func set_rate(value: float) -> void:
	rate_label.text = NumberFormat.format_rate(value)

func set_efficiency(value: float) -> void:
	efficiency_label.text = "%d%%" % int(value * 100)
