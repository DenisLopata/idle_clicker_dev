extends Button
class_name PassiveGenerator

signal unlocked(action_id: String)

const FLOATING_TEXT_SCENE = preload("res://scenes/components/floating_text/floating_text.tscn")

@export var action_id: String = "gen_1"

# What resource this generator produces
@export var resource_type: ResourceTypes.ResourceType = ResourceTypes.ResourceType.LOC
@export var resource_per_tick: float = 1.0
@export var tick_interval: float = 1.0

# Unlock requirements
@export var unlock_cost_type: ResourceTypes.ResourceType = ResourceTypes.ResourceType.LOC
@export var unlock_cost: float = 20.0
@export var unlocked_generator: bool = false
@export var hidden_on_start: bool = false

@onready var cost_label = $CostLabel
@onready var timer: Timer = $Timer


func _ready() -> void:
	# Hide if configured to start hidden (for progressive unlock)
	if hidden_on_start:
		hide()

	if not unlocked_generator:
		disabled = true

	pressed.connect(_on_pressed)
	GameState.resource_changed.connect(_on_resource_changed)

	# Timer setup
	timer.wait_time = tick_interval
	timer.timeout.connect(_on_tick)

	_update_visual_state()
	_update_cost_label()
	_update_tooltip()

	# Register for save/load
	SaveManager.register(self)

func reveal() -> void:
	show()
	# Optional: add animation later
	print("[PassiveGenerator] Revealed: %s" % action_id)

func _exit_tree() -> void:
	SaveManager.unregister(self)


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
		_update_tooltip()


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

func _update_tooltip() -> void:
	var res_type: String = ResourceTypes.ResourceType.keys()[resource_type]

	if not unlocked_generator:
		var cost_type: String = ResourceTypes.ResourceType.keys()[unlock_cost_type]
		tooltip_text = "Unlock for %d %s\nProduces +%d %s every %.1fs" % [
			int(unlock_cost), cost_type, int(resource_per_tick), res_type, tick_interval
		]
	else:
		tooltip_text = "Produces +%d %s every %.1fs" % [int(resource_per_tick), res_type, tick_interval]

func _on_tick() -> void:
	if unlocked_generator:
		GameState.add_resource(resource_type, resource_per_tick)
		_spawn_floating_text(resource_per_tick, resource_type)

func _spawn_floating_text(amount: float, type: ResourceTypes.ResourceType) -> void:
	var floating := FLOATING_TEXT_SCENE.instantiate() as FloatingText
	get_tree().root.add_child(floating)

	var prefix := "+" if amount > 0 else ""
	var type_name: String = ResourceTypes.ResourceType.keys()[type]
	var display_text := "%s%d %s" % [prefix, int(amount), type_name]
	var color := ResourceTypes.get_color(type)

	# Spawn above the generator
	var spawn_pos := global_position + Vector2(size.x / 2, 0)
	floating.setup(display_text, color, spawn_pos)

# Save/Load interface
func get_save_data() -> Dictionary:
	return {
		"unlocked": unlocked_generator
	}

func load_save_data(data: Dictionary) -> void:
	if data.has("unlocked") and data["unlocked"]:
		unlocked_generator = true
		disabled = false
		timer.start()
		_update_visual_state()
		_update_cost_label()
		_update_tooltip()
