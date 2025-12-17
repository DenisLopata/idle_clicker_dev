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
	
	production_system.initialize(GameState)
	
	resource_hud.initialize(GameState)

func _on_resource_changed(_type: int, _new_value: float) -> void:
	# Update UI, show all resources in a single label or dedicated labels
	var text := ""
	for rtype in ResourceTypes.ResourceType.values():
		var amt := GameState.get_resource(rtype)
		text += "%s: %d  " % [str(rtype), int(amt)]
	resource_label.text = text

func _on_upgrade_purchased(id: String) -> void:
	match id:
		"auto_clicker_unlock":
			# AutoClicker upgrade bought, enable related generators
			print("AutoClicker unlocked")
