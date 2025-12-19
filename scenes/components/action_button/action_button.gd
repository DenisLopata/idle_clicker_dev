extends Button
class_name ActionButton

signal unlocked(action_id: String)
signal performed(action_id: String)

const FLOATING_TEXT_SCENE = preload("res://scenes/components/floating_text/floating_text.tscn")

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

func reveal() -> void:
	# Animate reveal: fade in and scale up
	modulate.a = 0.0
	scale = Vector2(0.5, 0.5)
	show()

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	print("[ActionButton] Revealed: %s" % action_id)


func _on_pressed() -> void:
	if not unlocked_action:
		_try_unlock()
		return

	# Perform action
	if action_cost > 0.0:
		if GameState.get_resource(action_cost_type) < action_cost:
			_play_reject_animation()
			return

		GameState.add_resource(action_cost_type, -action_cost)
		_spawn_floating_text(-action_cost, action_cost_type)

	if resource_per_click != 0.0:
		GameState.add_resource(resource_type, resource_per_click)
		_spawn_floating_text(resource_per_click, resource_type)

	_play_press_animation()
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
		cost_label.text = "Cost: %s %s" % [NumberFormat.format(unlock_cost), type_txt]

func _update_tooltip() -> void:
	var lines := []

	if not unlocked_action:
		var cost_type: String = ResourceTypes.ResourceType.keys()[unlock_cost_type]
		lines.append("Unlock for %s %s" % [NumberFormat.format(unlock_cost), cost_type])
	else:
		if resource_per_click > 0:
			var res_type: String = ResourceTypes.ResourceType.keys()[resource_type]
			lines.append("+%s %s per click" % [NumberFormat.format(resource_per_click), res_type])
		if action_cost > 0:
			var cost_type: String = ResourceTypes.ResourceType.keys()[action_cost_type]
			lines.append("Costs %s %s" % [NumberFormat.format(action_cost), cost_type])

	tooltip_text = "\n".join(lines)

func _spawn_floating_text(amount: float, type: ResourceTypes.ResourceType) -> void:
	var floating := FLOATING_TEXT_SCENE.instantiate() as FloatingText
	get_tree().root.add_child(floating)

	var prefix := "+" if amount > 0 else ""
	var type_name: String = ResourceTypes.ResourceType.keys()[type]
	var display_text := "%s%s %s" % [prefix, NumberFormat.format(absf(amount)), type_name]
	var color := ResourceTypes.get_color(type)

	# Spawn above the button
	var spawn_pos := global_position + Vector2(size.x / 2, 0)
	floating.setup(display_text, color, spawn_pos)

func _play_press_animation() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.05)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_OUT)

func _play_reject_animation() -> void:
	var tween := create_tween()
	var original_x := position.x
	tween.tween_property(self, "position:x", original_x - 5, 0.05)
	tween.tween_property(self, "position:x", original_x + 5, 0.05)
	tween.tween_property(self, "position:x", original_x, 0.05)
