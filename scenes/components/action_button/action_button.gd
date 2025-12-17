extends Button
class_name ActionButton

signal unlocked(action_id: String)
signal performed(action_id: String)

@export var action_id: String = ""

@export var unlock_cost_type:  ResourceTypes.ResourceType = ResourceTypes.ResourceType.LOC
@export var unlock_cost: float = 10.0

@export var resource_type:  ResourceTypes.ResourceType = ResourceTypes.ResourceType.LOC
@export var resource_per_click: float = 1.0

@export var action_cost_type: ResourceTypes.ResourceType = ResourceTypes.ResourceType.LOC
@export var action_cost: float = 0.0

@export var unlocked_action: bool = false

@onready var cost_label: Label = $CostLabel if has_node("CostLabel") else null
@onready var name_label: Label = $NameLabel


func _ready() -> void:
	# Keep button clickable even when locked (important!)
	disabled = false

	pressed.connect(_on_pressed)
	GameState.resource_changed.connect(_on_resource_changed)

	_update_visual_state()
	_update_cost_label()
	
	name_label.text = action_id


func _on_pressed() -> void:
	if not unlocked_action:
		_try_unlock()
		return

	# Perform action
	#GameState.add_resource(resource_type, resource_per_click)
	if action_cost > 0.0:
		if GameState.get_resource(action_cost_type) < action_cost:
			return

		GameState.add_resource(action_cost_type, -action_cost)

	if resource_per_click != 0.0:
		GameState.add_resource(resource_type, resource_per_click)
	performed.emit(action_id)


func _try_unlock() -> void:
	var available := GameState.get_resource(unlock_cost_type)
	if available >= unlock_cost:
		unlocked_action = true
		GameState.add_resource(unlock_cost_type, -unlock_cost)
		unlocked.emit(action_id)

		_update_visual_state()
		_update_cost_label()


func _on_resource_changed(type: int, _new_value: float) -> void:
	# Only update if the relevant resource changed
	if type == unlock_cost_type:
		_update_visual_state()
		_update_cost_label()


func _update_visual_state() -> void:
	if unlocked_action:
		text = "Click"
		if cost_label:
			cost_label.hide()
		modulate = Color(0.8, 1.0, 0.8)
		return

	# Locked
	text = "Unlock"
	if cost_label:
		cost_label.show()

	if GameState.get_resource(unlock_cost_type) >= unlock_cost:
		modulate = Color(1, 1, 1)       # Affordable
	else:
		modulate = Color(0.6, 0.6, 0.6) # Not affordable


func _update_cost_label() -> void:
	if cost_label and not unlocked_action:
		var type_txt: String = ResourceTypes.ResourceType.keys()[unlock_cost_type]
		cost_label.text = "Cost: %d %s" % [unlock_cost, str(type_txt)]
