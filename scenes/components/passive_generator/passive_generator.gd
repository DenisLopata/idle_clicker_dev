extends Button
class_name PassiveGenerator

signal unlocked(action_id: String)

@export var action_id: String = "gen_1"
@export var display_name: String = ""

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
@onready var title_label = $TitleLabel
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

	title_label.text = display_name if display_name else action_id

	# Register for save/load
	SaveManager.register(self)

func reveal() -> void:
	AnimationHelper.play_reveal(self)
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
		modulate = ThemeColors.UNLOCKED
		return

	# Locked: check affordability
	if GameState.get_resource(unlock_cost_type) >= unlock_cost:
		modulate = ThemeColors.AFFORDABLE
	else:
		modulate = ThemeColors.NOT_AFFORDABLE


func _update_cost_label() -> void:
	if not unlocked_generator:
		cost_label.text = "Unlock: %s" % NumberFormat.format(unlock_cost)
	else:
		cost_label.text = "+%s / %.1fs" % [NumberFormat.format(resource_per_tick), tick_interval]

func _update_tooltip() -> void:
	var res_name := ResourceTypes.get_type_name(resource_type)

	if not unlocked_generator:
		tooltip_text = "Unlock for %s %s\nProduces +%s %s every %.1fs" % [
			NumberFormat.format(unlock_cost), ResourceTypes.get_type_name(unlock_cost_type), NumberFormat.format(resource_per_tick), res_name, tick_interval
		]
	else:
		tooltip_text = "Produces +%s %s every %.1fs" % [NumberFormat.format(resource_per_tick), res_name, tick_interval]

func _on_tick() -> void:
	if unlocked_generator:
		GameState.add_resource(resource_type, resource_per_tick)
		FloatingTextSpawner.spawn(resource_per_tick, resource_type, _get_spawn_position())
		AnimationHelper.play_pulse(self)

func _get_spawn_position() -> Vector2:
	return global_position + Vector2(size.x / 2, 0)

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
