extends Button
class_name ActionButton

signal unlocked(action_id: String)
signal performed(action_id: String)

@export var action_id: String = ""
@export var display_name: String = ""

@export var unlock_cost_type:  ResourceTypes.ResourceType = ResourceTypes.ResourceType.LOC
@export var unlock_cost: float = 10.0

@export var resource_type:  ResourceTypes.ResourceType = ResourceTypes.ResourceType.LOC
@export var resource_per_click: float = 1.0

@export var action_cost_type: ResourceTypes.ResourceType = ResourceTypes.ResourceType.LOC
@export var action_cost: float = 0.0

@export var unlocked_action: bool = false
@export var hidden_on_start: bool = false

@onready var cost_label: Label = $CostLabel if has_node("CostLabel") else null
@onready var name_label: Label = $NameLabel


func _ready() -> void:
	add_to_group("action_buttons")

	# Register for save/load
	SaveManager.register(self)

	# Hide if configured to start hidden (for progressive unlock)
	if hidden_on_start:
		hide()

	# Keep button clickable even when locked (important!)
	disabled = false

	pressed.connect(_on_pressed)
	GameState.resource_changed.connect(_on_resource_changed)

	_update_visual_state()
	_update_cost_label()
	_update_tooltip()

	name_label.text = display_name if display_name else action_id

func _exit_tree() -> void:
	SaveManager.unregister(self)

func get_save_data() -> Dictionary:
	return {
		"unlocked": unlocked_action,
		"revealed": visible
	}

func load_save_data(data: Dictionary) -> void:
	if data.has("unlocked"):
		unlocked_action = data["unlocked"]
	if data.has("revealed") and data["revealed"]:
		show()
	_update_visual_state()
	_update_cost_label()
	_update_tooltip()

func reveal() -> void:
	AnimationHelper.play_reveal(self)
	print("[ActionButton] Revealed: %s" % action_id)


func _on_pressed() -> void:
	if not unlocked_action:
		_try_unlock()
		return

	GameStats.record_click()
	GameStats.record_action(action_id)

	# Perform action
	if action_cost > 0.0:
		if GameState.get_resource(action_cost_type) < action_cost:
			AnimationHelper.play_reject(self)
			return

		GameState.add_resource(action_cost_type, -action_cost)
		FloatingTextSpawner.spawn(-action_cost, action_cost_type, _get_spawn_position())

	if resource_per_click != 0.0:
		GameState.add_resource(resource_type, resource_per_click)
		FloatingTextSpawner.spawn(resource_per_click, resource_type, _get_spawn_position())

	AnimationHelper.play_press(self)
	performed.emit(action_id)


func _try_unlock() -> void:
	var available := GameState.get_resource(unlock_cost_type)
	if available >= unlock_cost:
		unlocked_action = true
		GameState.add_resource(unlock_cost_type, -unlock_cost)
		unlocked.emit(action_id)

		_update_visual_state()
		_update_cost_label()
		_update_tooltip()


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
		modulate = ThemeColors.UNLOCKED
		return

	# Locked
	text = "Unlock"
	if cost_label:
		cost_label.show()

	if GameState.get_resource(unlock_cost_type) >= unlock_cost:
		modulate = ThemeColors.AFFORDABLE
	else:
		modulate = ThemeColors.NOT_AFFORDABLE


func _update_cost_label() -> void:
	if cost_label and not unlocked_action:
		cost_label.text = "Cost: %s %s" % [NumberFormat.format(unlock_cost), ResourceTypes.get_type_name(unlock_cost_type)]

func _update_tooltip() -> void:
	var lines := []

	if not unlocked_action:
		lines.append("Unlock for %s %s" % [NumberFormat.format(unlock_cost), ResourceTypes.get_type_name(unlock_cost_type)])
	else:
		if resource_per_click > 0:
			lines.append("+%s %s per click" % [NumberFormat.format(resource_per_click), ResourceTypes.get_type_name(resource_type)])
		if action_cost > 0:
			lines.append("Costs %s %s" % [NumberFormat.format(action_cost), ResourceTypes.get_type_name(action_cost_type)])

	tooltip_text = "\n".join(lines)

func _get_spawn_position() -> Vector2:
	return global_position + Vector2(size.x / 2, 0)
