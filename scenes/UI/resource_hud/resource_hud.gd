extends Control
class_name ResourceHUD

@export var resource_row_scene: PackedScene

@onready var container: VBoxContainer = $VBoxContainer

var _rows: Dictionary = {} # ResourceType -> ResourceRow
var _game_state: GameState
var _production_system: ProductionSystem

func initialize(game_state: GameState, production_system: ProductionSystem = null) -> void:
	_game_state = game_state
	_game_state.resource_changed.connect(_on_resource_changed)

	if production_system:
		_production_system = production_system
		_production_system.rates_updated.connect(_on_rates_updated)

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

func _on_rates_updated(rates: Dictionary) -> void:
	# Update rates for each resource
	for rtype in _rows.keys():
		var rate = rates.get(rtype, 0.0)
		_rows[rtype].set_rate(rate)

	# Update efficiency (bug penalty) on LOC row
	if _production_system and _rows.has(ResourceTypes.ResourceType.LOC):
		var penalty = _production_system.get_bug_penalty()
		_rows[ResourceTypes.ResourceType.LOC].set_efficiency(penalty)
