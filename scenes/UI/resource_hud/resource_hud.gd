extends Control
class_name ResourceHUD

@export var resource_row_scene: PackedScene

@onready var container: VBoxContainer = $VBoxContainer

var _rows: Dictionary = {} # ResourceType -> ResourceRow
var _game_state: GameState

func initialize(game_state: GameState) -> void:
	_game_state = game_state
	_game_state.resource_changed.connect(_on_resource_changed)

	for rtype in ResourceTypes.ResourceType.values():
		_create_row(rtype)

func _create_row(rtype: ResourceTypes.ResourceType) -> void:
	var row := resource_row_scene.instantiate() as ResourceRow
	row.resource_type = rtype
	
	container.add_child(row)
	#await row.ready
	
	row.name_label.text = ResourceTypes.ResourceType.keys()[rtype]
	row.set_amount(_game_state.get_resource(rtype))
	row.efficiency_label.text = ""

	_rows[rtype] = row

func _on_resource_changed(
	type: ResourceTypes.ResourceType,
	new_value: float
) -> void:
	if not _rows.has(type):
		return

	_rows[type].set_amount(new_value)
