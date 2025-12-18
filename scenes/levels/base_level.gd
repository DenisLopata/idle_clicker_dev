extends Control

@onready var resource_label: Label = $ResourceLabel
@onready var upgrade_panel: UpgradePanel = $UpgradeContainer/UpgradePanel
@onready var production_system: ProductionSystem = $ProductionSystem
@onready var resource_hud: ResourceHUD = $UI/ResourceHUD

# Amount added per click (generic)
@export var click_value: float = 1.0


var upgrades_data := [
	preload("uid://5n5mx47rgyju") #"res://data/upgrades/auto_clicker_unlock.tres"
]

func _ready() -> void:
	# Listen to GameState resource changes
	GameState.resource_changed.connect(_on_resource_changed)

	# Init UI for all resources
	for type in ResourceTypes.ResourceType.values():
		_on_resource_changed(type, GameState.get_resource(type))

	# Add upgrades
	for upg in upgrades_data:
		upgrade_panel.add_upgrade(upg)

	# Listen to upgrade purchases
	upgrade_panel.upgrade_purchased.connect(_on_upgrade_purchased)

	# Listen for offline progress
	SaveManager.offline_progress_calculated.connect(_on_offline_progress)

	production_system.initialize(GameState)

	resource_hud.initialize(GameState, production_system)

	# Load saved game if exists
	SaveManager.load_game()

func _on_resource_changed(_type: int, _new_value: float) -> void:
	# Update UI, show all resources in a single label or dedicated labels
	var text := ""
	for rtype in ResourceTypes.ResourceType.values():
		var amt := GameState.get_resource(rtype)
		text += "%s: %d  " % [str(rtype), int(amt)]
	resource_label.text = text

func _on_upgrade_purchased(id: String) -> void:
	# Save on significant events
	SaveManager.save_game()

	match id:
		"auto_clicker_unlock":
			# AutoClicker upgrade bought, enable related generators
			print("AutoClicker unlocked")

func _on_offline_progress(elapsed_seconds: float) -> void:
	# Find all passive generators and calculate offline earnings
	var generators := get_tree().get_nodes_in_group("passive_generators")

	# Fallback: find by class if no group
	if generators.is_empty():
		generators = _find_nodes_by_class(self, "PassiveGenerator")

	for gen in generators:
		if gen is PassiveGenerator and gen.unlocked_generator:
			var ticks = elapsed_seconds / gen.tick_interval
			var earned = ticks * gen.resource_per_tick
			GameState.add_resource(gen.resource_type, earned)
			print("[Offline] %s earned %.1f of %s" % [gen.action_id, earned, gen.resource_type])

func _find_nodes_by_class(node: Node, class_name_str: String) -> Array:
	var result := []
	if node.get_class() == class_name_str or (node is PassiveGenerator):
		result.append(node)
	for child in node.get_children():
		result.append_array(_find_nodes_by_class(child, class_name_str))
	return result
