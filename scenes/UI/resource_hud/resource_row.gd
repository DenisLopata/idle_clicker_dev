extends HBoxContainer
class_name ResourceRow

var resource_type: ResourceTypes.ResourceType

@onready var name_label: Label = $Name
@onready var amount_label: Label = $Amount
@onready var rate_label: Label = $Rate
@onready var efficiency_label: Label = $Efficiency

func set_amount(value: float) -> void:
	amount_label.text = str(int(value))

func set_efficiency(value: float) -> void:
	efficiency_label.text = "%d%%" % int(value * 100)
