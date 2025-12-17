#extends Node
#
## Simple example resource (e.g., "points", "gold", "code", whatever)
#var resource_amount: float = 0.0
#
#signal resource_changed(new_value: float)
#
#func add_resource(amount: float) -> void:
	#resource_amount += amount
	#resource_changed.emit(resource_amount)
#
#func get_resource() -> float:
	#return resource_amount
extends Node

signal resource_changed(resource_type: int, new_value: float)

var resources: Dictionary[int, ResourceEntry] = {}

func _ready() -> void:
	_register_resources()

func _register_resources() -> void:
	
	# Initialize all resource types
	for type in ResourceTypes.ResourceType.values():
		var entry := ResourceEntry.new()
		entry.resource_type = type
		entry.amount = 0
		resources[type] = entry
		

func add_resource(type: int, amount: float) -> void:
	if not resources.has(type):
		printerr("Unknown resource type: ", type)
		return

	resources[type].add(amount)
	resource_changed.emit(type, resources[type].amount)


func set_resource(type: int, value: float) -> void:
	if not resources.has(type):
		printerr("Unknown resource type: ", type)
		return

	resources[type].set_value(value)
	resource_changed.emit(type, value)


func get_resource(type: int) -> float:
	return resources[type].amount if resources.has(type) else 0.0
