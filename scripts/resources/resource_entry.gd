class_name ResourceEntry
extends Resource

@export var resource_type: int
var amount: float = 0.0

func add(value: float) -> void:
	amount += value
	if amount < 0:
		amount = 0

func set_value(v: float) -> void:
	amount = max(v, 0)
