extends Node

signal resource_changed(resource_type: int, new_value: float)

var resources: Dictionary[int, ResourceEntry] = {}

func _ready() -> void:
	_register_resources()
	# Register with SaveManager for save/load
	SaveManager.register(self)

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

# Save/Load interface
func get_save_data() -> Dictionary:
	var data := {}
	for type in resources.keys():
		data[str(type)] = resources[type].amount
	return data

func load_save_data(data: Dictionary) -> void:
	for type_str in data.keys():
		var type := int(type_str)
		if resources.has(type):
			set_resource(type, data[type_str])

func reset() -> void:
	for type in resources.keys():
		set_resource(type, 0.0)
