extends Control
class_name ResourceHUD

@export var resource_row_scene: PackedScene

@onready var container: VBoxContainer = $VBoxContainer

var _rows: Dictionary = {} # ResourceType -> ResourceRow
var _game_state: GameState
var _production_system: ProductionSystem

func _ready() -> void:
	# Register with SaveManager for save/load
	SaveManager.register(self)

func initialize(game_state: GameState, production_system: ProductionSystem = null) -> void:
	_game_state = game_state
	_game_state.resource_changed.connect(_on_resource_changed)

	if production_system:
		_production_system = production_system
		_production_system.rates_updated.connect(_on_rates_updated)

	for rtype in ResourceTypes.ResourceType.values():
		_create_row(rtype)

	# LOC is always visible from the start
	_rows[ResourceTypes.ResourceType.LOC].reveal()

func _create_row(rtype: ResourceTypes.ResourceType) -> void:
	var row := resource_row_scene.instantiate() as ResourceRow
	container.add_child(row)

	row.setup(rtype, true)  # start hidden
	row.name_label.text = ResourceTypes.get_type_name(rtype)
	row.set_amount(_game_state.get_resource(rtype))
	row.efficiency_label.text = ""

	_rows[rtype] = row

func _on_resource_changed(
	type: ResourceTypes.ResourceType,
	new_value: float
) -> void:
	if not _rows.has(type):
		return

	# Reveal the row when resource is first interacted with
	_rows[type].reveal()
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

# Save/Load interface
func get_save_data() -> Dictionary:
	var discovered: Array = []
	for rtype in _rows.keys():
		if _rows[rtype].discovered:
			discovered.append(rtype)
	return {"discovered": discovered}

func load_save_data(data: Dictionary) -> void:
	if data.has("discovered"):
		for rtype in data["discovered"]:
			if _rows.has(rtype):
				_rows[rtype].reveal()
