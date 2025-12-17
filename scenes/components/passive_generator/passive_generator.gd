extends Button
class_name PassiveGenerator

signal unlocked(action_id: String)

@export var action_id: String = "gen_1"

# What resource this generator produces
@export var resource_type: ResourceTypes.ResourceType = ResourceTypes.ResourceType.LOC
@export var resource_per_tick: float = 1.0
@export var tick_interval: float = 1.0

# Unlock requirements
@export var unlock_cost_type: ResourceTypes.ResourceType = ResourceTypes.ResourceType.LOC
@export var unlock_cost: float = 20.0
@export var unlocked_generator: bool = false

@onready var cost_label = $CostLabel
@onready var timer: Timer = $Timer


func _ready() -> void:
	if not unlocked_generator:
		disabled = true

	pressed.connect(_on_pressed)
	GameState.resource_changed.connect(_on_resource_changed)

	# Timer setup
	timer.wait_time = tick_interval
	timer.timeout.connect(_on_tick)

	_update_visual_state()
	_update_cost_label()


func _on_pressed() -> void:
	if unlocked_generator:
		return
	_try_unlock()


func _try_unlock() -> void:
	var available := GameState.get_resource(unlock_cost_type)
	if available >= unlock_cost:
		GameState.add_resource(unlock_cost_type, -unlock_cost)
		unlocked_generator = true
		disabled = false
		unlocked.emit(action_id)

		timer.start()

		_update_visual_state()
		_update_cost_label()


func _on_resource_changed(type: int, _new_value: float) -> void:
	# Only react if the resource type affects unlock state
	if type == unlock_cost_type:
		disabled = GameState.get_resource(unlock_cost_type) < unlock_cost
		_update_visual_state()
		_update_cost_label()


func _update_visual_state() -> void:
	if unlocked_generator:
		modulate = Color(0.8, 1.0, 0.8) # Active
		return

	# Locked: check affordability
	if GameState.get_resource(unlock_cost_type) >= unlock_cost:
		modulate = Color(1, 1, 1)       # Affordable
	else:
		modulate = Color(0.6, 0.6, 0.6) # Not affordable


func _update_cost_label() -> void:
	if not unlocked_generator:
		cost_label.text = "Unlock: %d" % unlock_cost
	else:
		cost_label.text = "+%d / %.1fs" % [resource_per_tick, tick_interval]


func _on_tick() -> void:
	if unlocked_generator:
		GameState.add_resource(resource_type, resource_per_tick)
