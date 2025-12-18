class_name ProgressionManager
extends Node

signal node_revealed(node_path: String)

@export var milestones: Array[Milestone] = []

var _revealed_paths: Array[String] = []
var _game_state: GameState
var _root: Node

func initialize(game_state: GameState, root: Node) -> void:
	_game_state = game_state
	_root = root
	_game_state.resource_changed.connect(_on_resource_changed)

	# Register with SaveManager
	SaveManager.register(self)

	# Check milestones based on current resources
	_check_milestones()

func _on_resource_changed(_type: int, _value: float) -> void:
	_check_milestones()

func _check_milestones() -> void:
	for milestone in milestones:
		# Skip if already revealed
		if milestone.reveal_node_path in _revealed_paths:
			continue

		# Check if requirement is met
		var current_amount := _game_state.get_resource(milestone.required_resource)
		if current_amount >= milestone.required_amount:
			_reveal_node(milestone.reveal_node_path)

func _reveal_node(path: String) -> void:
	if path in _revealed_paths:
		return

	_revealed_paths.append(path)
	node_revealed.emit(path)
	print("[Progression] Revealed: %s" % path)

# Save/Load interface
func get_save_data() -> Dictionary:
	return {"revealed": _revealed_paths}

func load_save_data(data: Dictionary) -> void:
	if data.has("revealed"):
		for path in data["revealed"]:
			if path not in _revealed_paths:
				_revealed_paths.append(path)
				node_revealed.emit(path)
